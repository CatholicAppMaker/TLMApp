import SwiftUI

struct GuideView: View {
    let appModel: AppModel
    @Binding var selectedTab: AppTab

    @AppStorage("latin.mass.guide.utility.dismissed") private var hasDismissedUtilityCard = false
    @State private var selectedPartID: String?
    @State private var isShowingJumpList = false

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
        guard let progress = appModel.progress else {
            return false
        }

        return progress.sectionID != selectedPartID && appModel.part(withID: progress.sectionID) != nil
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
        .onChange(of: selectedPartID) { _, _ in
            updateProgress()
        }
        .sheet(isPresented: $isShowingJumpList) {
            JumpToSectionView(
                majorMoments: appModel.majorMomentAnchors,
                parts: appModel.orderedParts,
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
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .background(AppTheme.backgroundWash.opacity(0.96))
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
            selectedPartID = appModel.orderedParts.first?.id
        }

        updateProgress()
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
                Button("Jump to Major Moments", action: onJump)
                    .buttonStyle(GuideUtilityPrimaryButtonStyle())
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

private struct JumpToSectionView: View {
    let majorMoments: [MajorMomentAnchor]
    let parts: [ResolvedMassPart]
    @Binding var selectedPartID: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                if !majorMoments.isEmpty {
                    Section("Major Moments") {
                        ForEach(majorMoments) { anchor in
                            Button {
                                selectedPartID = anchor.partID
                                dismiss()
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(anchor.title)
                                        .font(.headline)
                                        .foregroundStyle(AppTheme.ink)
                                    Text(anchor.summary)
                                        .font(.subheadline)
                                        .foregroundStyle(AppTheme.mutedInk)
                                        .lineLimit(2)
                                }
                                .padding(.vertical, 6)
                            }
                            .accessibilityIdentifier("jump-moment-\(anchor.partID)")
                        }
                    }
                }

                Section("All Sections") {
                    ForEach(parts) { part in
                        Button {
                            selectedPartID = part.id
                            dismiss()
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(part.title)
                                    .font(.headline)
                                    .foregroundStyle(AppTheme.ink)
                                Text(part.summary)
                                    .font(.subheadline)
                                    .foregroundStyle(AppTheme.mutedInk)
                                    .lineLimit(2)
                            }
                            .padding(.vertical, 6)
                        }
                        .accessibilityIdentifier("jump-to-\(part.id)")
                    }
                }
            }
            .navigationTitle("Jump to Major Moments")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

private struct GuideUtilityPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .font(.system(.headline, design: .serif))
            .foregroundStyle(.white)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppTheme.burgundy.opacity(configuration.isPressed ? 0.85 : 1.0))
            )
    }
}

private struct GuideUtilitySecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(AppTheme.ink)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppTheme.secondarySurface.opacity(configuration.isPressed ? 0.82 : 1.0))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
    }
}

private struct GuideNavigationBar: View {
    let previousTitle: String?
    let nextTitle: String?
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onPrevious) {
                Label(previousTitle ?? "Beginning", systemImage: "chevron.left")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(GuideNavButtonStyle())
            .disabled(previousTitle == nil)
            .accessibilityIdentifier("previous-section")
            .accessibilityLabel("Previous section")
            .accessibilityValue(previousTitle ?? "Beginning of Mass")

            Button(action: onNext) {
                Label(nextTitle ?? "End", systemImage: "chevron.right")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(GuideNavButtonStyle())
            .disabled(nextTitle == nil)
            .accessibilityIdentifier("next-section")
            .accessibilityLabel("Next section")
            .accessibilityValue(nextTitle ?? "End of Mass")
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(AppTheme.surface)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AppTheme.divider)
                .frame(height: 1)
        }
    }
}

private struct GuideNavButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(AppTheme.ink)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppTheme.surface.opacity(configuration.isPressed ? 0.82 : 1.0))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
    }
}
