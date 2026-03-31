import SwiftUI

struct GuideView: View {
    let appModel: AppModel
    @Binding var selectedTab: AppTab

    @State private var selectedPartID: String?
    @State private var isShowingJumpList = false

    private var currentPart: ResolvedMassPart? {
        appModel.part(withID: selectedPartID)
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

private struct JumpToSectionView: View {
    let parts: [ResolvedMassPart]
    @Binding var selectedPartID: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(parts) { part in
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
            .navigationTitle("Jump to a Section")
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
