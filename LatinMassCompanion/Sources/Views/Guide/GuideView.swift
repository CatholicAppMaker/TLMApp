import SwiftUI

struct GuideView: View {
    let appModel: AppModel
    @Binding var selectedTab: AppTab
    var showsInlineTools = true

    @AppStorage("latin.mass.guide.utility.dismissed") private var hasDismissedUtilityCard = false
    @State private var selectedPartID: String?
    @State private var isShowingJumpList = false
    @State private var isShowingFindMyPlace = false
    @State private var shouldSkipNextProgressRecord = false

    private var selectedMassFormBinding: Binding<MassForm> {
        Binding(
            get: { appModel.selectedMassForm },
            set: { appModel.selectMassForm($0) }
        )
    }

    private var currentPart: ResolvedMassPart? {
        appModel.part(withID: selectedPartID)
    }

    private var canResumeSavedPlace: Bool {
        guard let savedProgressContext = appModel.savedProgressContext else {
            return false
        }

        return savedProgressContext.progress.sectionID != selectedPartID
            || savedProgressContext.progress.dateKey != appModel.selectedDateKey
            || savedProgressContext.progress.massForm != appModel.selectedMassForm
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(AppTheme.backgroundWash)
                .ignoresSafeArea()

            if let errorMessage = appModel.errorMessage {
                ContentUnavailableView(
                    "Content Unavailable",
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )
            } else if let part = currentPart {
                MassPartDetailView(
                    part: part,
                    position: appModel.displayIndex(for: part),
                    totalCount: appModel.orderedParts.count,
                    orientation: appModel.guideOrientation(for: part),
                    isBookmarked: appModel.isBookmarked(part),
                    sourceReferences: appModel.sourceReferences(for: part),
                    quickGuidance: part.quickGuidance,
                    glossaryEntries: part.glossaryIDs.compactMap(appModel.glossaryEntry(withID:)),
                    pronunciationGuides: part.pronunciationIDs.compactMap(appModel.pronunciationGuide(withID:)),
                    chantGuides: appModel.chantGuides(for: part),
                    onToggleBookmark: {
                        appModel.toggleBookmark(for: part)
                    },
                    onJump: {
                        isShowingJumpList = true
                    },
                    onOpenLearn: { destination in
                        appModel.openLearn(destination)
                        selectedTab = .learn
                    }
                )
            } else {
                ProgressView("Loading Mass Guide")
                    .foregroundStyle(AppTheme.ink)
            }
        }
        .navigationTitle(appModel.guideHeaderTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text(appModel.guideHeaderTitle)
                        .font(.headline)
                    Text(appModel.guideHeaderSubtitle)
                        .font(.caption)
                        .foregroundStyle(AppTheme.mutedInk)
                }
            }
        }
        .onAppear(perform: syncSelection)
        .onChange(of: appModel.selectedDateKey) { _, _ in
            syncSelection()
        }
        .onChange(of: appModel.selectedMassForm) { _, _ in
            syncSelection()
        }
        .onChange(of: appModel.guideSelectionToken) { _, _ in
            syncSelection()
        }
        .onChange(of: selectedPartID) { _, _ in
            if shouldSkipNextProgressRecord {
                shouldSkipNextProgressRecord = false
                return
            }
            updateProgress()
        }
        .sheet(isPresented: $isShowingJumpList) {
            JumpToSectionView(
                majorMoments: appModel.majorMomentAnchors,
                parts: appModel.orderedParts,
                selectedPartID: $selectedPartID
            )
        }
        .sheet(isPresented: $isShowingFindMyPlace) {
            FindMyPlaceView(
                anchors: appModel.findMyPlaceAnchors,
                selectedPartID: $selectedPartID
            )
        }
        .safeAreaInset(edge: .bottom) {
            if let part = currentPart {
                GuideNavigationBar(
                    previousTitle: appModel.part(before: part)?.title,
                    nextTitle: appModel.part(after: part)?.title,
                    onPrevious: {
                        selectedPartID = appModel.part(before: part)?.id
                        updateProgress()
                    },
                    onNext: {
                        selectedPartID = appModel.part(after: part)?.id
                        updateProgress()
                    }
                )
            }
        }
        .safeAreaInset(edge: .top) {
            if showsInlineTools {
                VStack(spacing: 10) {
                    GuideMassFormSwitcher(selectedMassFormBinding: selectedMassFormBinding)

                    if !hasDismissedUtilityCard {
                        GuideUtilityCard(
                            bookmarkCountText: appModel.bookmarkCountText,
                            hasBookmarks: !appModel.bookmarkedParts.isEmpty,
                            canResumeSavedPlace: canResumeSavedPlace,
                            onResume: {
                                appModel.resumeMass()
                                syncSelection()
                            },
                            onFindMyPlace: {
                                isShowingFindMyPlace = true
                            },
                            onJump: {
                                isShowingJumpList = true
                            },
                            onOpenBookmarks: {
                                appModel.focusBookmarkedSections()
                                selectedTab = .library
                            },
                            onDismiss: {
                                hasDismissedUtilityCard = true
                            }
                        )
                    } else if canResumeSavedPlace || !appModel.bookmarkedParts.isEmpty {
                        GuideQuickAccessStrip(
                            canResumeSavedPlace: canResumeSavedPlace,
                            hasBookmarks: !appModel.bookmarkedParts.isEmpty,
                            onResume: {
                                appModel.resumeMass()
                                syncSelection()
                            },
                            onFindMyPlace: {
                                isShowingFindMyPlace = true
                            },
                            onSaved: {
                                appModel.focusBookmarkedSections()
                                selectedTab = .library
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .background(AppTheme.backgroundWash.opacity(0.96))
            }
        }
    }

    private func syncSelection() {
        if let pendingSectionID = appModel.consumePendingGuideSectionID(),
           appModel.part(withID: pendingSectionID) != nil
        {
            selectedPartID = pendingSectionID
        } else if let selectedPartID, appModel.part(withID: selectedPartID) != nil {
            // Keep the current position when the selected date still resolves this section.
        } else {
            if shouldPreserveResumePrompt {
                shouldSkipNextProgressRecord = true
            }
            selectedPartID = appModel.orderedParts.first?.id
        }

        if !shouldSkipNextProgressRecord {
            updateProgress()
        }
    }

    private var shouldPreserveResumePrompt: Bool {
        guard
            selectedPartID == nil,
            let firstPartID = appModel.orderedParts.first?.id,
            let savedProgressContext = appModel.savedProgressContext
        else {
            return false
        }

        return savedProgressContext.progress.sectionID != firstPartID
            || savedProgressContext.progress.dateKey != appModel.selectedDateKey
            || savedProgressContext.progress.massForm != appModel.selectedMassForm
    }

    private func updateProgress() {
        guard let part = currentPart else {
            return
        }

        appModel.recordMassProgress(for: part)
    }
}

private struct GuideUtilityCard: View {
    let bookmarkCountText: String
    let hasBookmarks: Bool
    let canResumeSavedPlace: Bool
    let onResume: () -> Void
    let onFindMyPlace: () -> Void
    let onJump: () -> Void
    let onOpenBookmarks: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Use This Guide in Real Time")
                        .font(.system(.headline, design: .serif))
                        .foregroundStyle(AppTheme.ink)
                        .accessibilityIdentifier("guide-utility-title")

                    Text("Follow the Mass, switch form above, jump to major moments, and save important sections for a quicker return.")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.mutedInk)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 12)

                LiturgicalMotifBadge(kind: .guide)

                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppTheme.mutedInk)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(AppTheme.secondarySurface)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("dismiss-guide-utility")
                .accessibilityLabel("Dismiss guide utility tips")
            }

            HStack(spacing: 8) {
                PrayerbookBadge(title: "Guide-first", tone: .accent)
                PrayerbookBadge(title: "Major moments", tone: .neutral)
                if hasBookmarks {
                    PrayerbookBadge(title: bookmarkCountText, tone: .neutral)
                }
            }

            VStack(spacing: 10) {
                Button("Find My Place", action: onFindMyPlace)
                    .buttonStyle(GuideUtilityPrimaryButtonStyle())
                    .accessibilityIdentifier("guide-find-my-place-button")

                Button("Jump to Major Moments", action: onJump)
                    .buttonStyle(GuideUtilitySecondaryButtonStyle())
                    .accessibilityIdentifier("guide-major-moments-button")

                HStack(spacing: 10) {
                    if canResumeSavedPlace {
                        Button("Resume Saved Place", action: onResume)
                            .buttonStyle(GuideUtilitySecondaryButtonStyle())
                            .accessibilityIdentifier("guide-resume-button")
                    }

                    Button(hasBookmarks ? "Open Saved Sections" : "Open Library") {
                        onOpenBookmarks()
                    }
                    .buttonStyle(GuideUtilitySecondaryButtonStyle())
                    .accessibilityIdentifier("guide-bookmarks-button")
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppTheme.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("guide-utility-card")
    }
}

private struct GuideQuickAccessStrip: View {
    let canResumeSavedPlace: Bool
    let hasBookmarks: Bool
    let onResume: () -> Void
    let onFindMyPlace: () -> Void
    let onSaved: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button("Find My Place", action: onFindMyPlace)
                .buttonStyle(GuideUtilitySecondaryButtonStyle())
                .accessibilityIdentifier("guide-find-my-place-quick-button")

            if canResumeSavedPlace {
                Button("Resume", action: onResume)
                    .buttonStyle(GuideUtilitySecondaryButtonStyle())
                    .accessibilityIdentifier("guide-resume-quick-button")
            }

            if hasBookmarks {
                Button("Saved", action: onSaved)
                    .buttonStyle(GuideUtilitySecondaryButtonStyle())
                    .accessibilityIdentifier("guide-saved-quick-button")
            }
        }
    }
}

private struct GuideMassFormSwitcher: View {
    let selectedMassFormBinding: Binding<MassForm>

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Mass Form")
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.mutedInk)

            Picker("Mass Form", selection: selectedMassFormBinding) {
                ForEach(MassForm.allCases) { massForm in
                    Text(massForm.title).tag(massForm)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("guide-mass-form-toggle")
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AppTheme.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }
}
