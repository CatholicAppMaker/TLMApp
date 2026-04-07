import SwiftUI

struct MassPartDetailView: View {
    let part: ResolvedMassPart
    let position: Int
    let totalCount: Int
    let orientation: GuideOrientation
    let isBookmarked: Bool
    let sourceReferences: [SourceReference]
    let quickGuidance: [QuickGuidance]
    let glossaryEntries: [GlossaryEntry]
    let pronunciationGuides: [PronunciationGuide]
    let chantGuides: [ChantGuide]
    let onToggleBookmark: () -> Void
    let onJump: (() -> Void)?
    let onOpenLearn: (LearnDestination) -> Void
    let topAccessory: AnyView?

    @State private var expandedNotes: Set<String> = []

    private var sourceLookup: [String: SourceReference] {
        Dictionary(uniqueKeysWithValues: sourceReferences.map { ($0.id, $0) })
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if let topAccessory {
                    topAccessory
                }

                HeroCard(
                    part: part,
                    position: position,
                    totalCount: totalCount,
                    isBookmarked: isBookmarked,
                    onToggleBookmark: onToggleBookmark,
                    onJump: onJump
                )

                OrientationCard(
                    orientation: orientation,
                    position: position,
                    totalCount: totalCount
                )

                if !quickGuidance.isEmpty {
                    SectionCard(
                        title: "Quick Follow",
                        subtitle: "Short in-Mass guidance for staying calm and keeping your place."
                    ) {
                        VStack(spacing: 12) {
                            ForEach(quickGuidance) { guidance in
                                QuickGuidanceCard(
                                    guidance: guidance,
                                    sourceReference: sourceLookup[guidance.sourceID ?? ""]
                                )
                            }
                        }
                    }
                }

                if !part.gestureCues.isEmpty {
                    SectionCard(title: "Posture and Gesture") {
                        VStack(spacing: 12) {
                            ForEach(part.gestureCues) { cue in
                                GestureCueRow(cue: cue)
                            }
                        }
                    }
                }

                SectionCard(title: "Latin and English") {
                    VStack(spacing: 14) {
                        ForEach(part.textBlocks) { block in
                            TextBlockCard(block: block)
                        }
                    }
                }

                if !glossaryEntries.isEmpty || !pronunciationGuides.isEmpty || !chantGuides.isEmpty {
                    SectionCard(title: "Learn This Section") {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(glossaryEntries) { entry in
                                LearnLinkButton(title: entry.term) {
                                    onOpenLearn(.glossary(entry.id))
                                }
                            }

                            ForEach(pronunciationGuides) { guide in
                                LearnLinkButton(title: guide.title) {
                                    onOpenLearn(.pronunciation(guide.id))
                                }
                            }

                            ForEach(chantGuides) { guide in
                                LearnLinkButton(title: guide.title) {
                                    onOpenLearn(.chant(guide.id))
                                }
                            }
                        }
                    }
                }

                if !part.explanationNotes.isEmpty {
                    SectionCard(
                        title: "Deeper Context",
                        subtitle: "Longer explanation for why this moment matters and how the tradition understands it."
                    ) {
                        VStack(spacing: 14) {
                            ForEach(part.explanationNotes) { note in
                                ExplanationCard(
                                    note: note,
                                    sourceReference: sourceLookup[note.sourceID ?? ""],
                                    isExpanded: expandedNotes.contains(note.id),
                                    toggle: {
                                        toggleNote(note.id)
                                    }
                                )
                            }
                        }
                    }
                }

                if !sourceReferences.isEmpty {
                    SectionCard(
                        title: "Sources",
                        subtitle: "Bundled references that anchor this section's texts and explanatory notes."
                    ) {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(sourceReferences) { source in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(source.title)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(AppTheme.ink)

                                            Text(source.note)
                                                .font(.caption)
                                                .foregroundStyle(AppTheme.mutedInk)
                                        }

                                        Spacer(minLength: 12)

                                        if let category = source.category {
                                            PrayerbookBadge(title: category.capitalized, tone: .neutral)
                                        }
                                    }

                                    if let attribution = source.attribution {
                                        Text(attribution)
                                            .font(.caption)
                                            .foregroundStyle(AppTheme.ink)
                                    }

                                    if let coverageNote = source.coverageNote {
                                        Text(coverageNote)
                                            .font(.caption)
                                            .foregroundStyle(AppTheme.mutedInk)
                                    }

                                    if let rights = source.rights {
                                        Text(rights)
                                            .font(.caption)
                                            .foregroundStyle(AppTheme.burgundy)
                                    }
                                }
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(AppTheme.insetPanelFill)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(AppTheme.border.opacity(0.85), lineWidth: 1)
                                )
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 30)
        }
    }

    private func toggleNote(_ noteID: String) {
        if expandedNotes.contains(noteID) {
            expandedNotes.remove(noteID)
        } else {
            expandedNotes.insert(noteID)
        }
    }
}

private struct OrientationCard: View {
    let orientation: GuideOrientation
    let position: Int
    let totalCount: Int

    var body: some View {
        SectionCard(title: "Follow Along") {
            VStack(alignment: .leading, spacing: 12) {
                ProgressView(value: Double(position), total: Double(totalCount))
                    .tint(AppTheme.burgundy)
                    .accessibilityLabel("Mass progress")
                    .accessibilityValue(orientation.positionText)

                HStack(alignment: .top, spacing: 12) {
                    OrientationPill(
                        title: orientation.phaseTitle,
                        systemImage: "flag",
                        identifier: "guide-phase-pill"
                    )
                    OrientationPill(
                        title: orientation.positionText,
                        systemImage: "list.number",
                        identifier: "guide-position-pill"
                    )
                    OrientationPill(
                        title: orientation.massFormTitle,
                        systemImage: "music.note.house",
                        identifier: "guide-form-pill"
                    )
                }

                if let liveNote = orientation.liveNote {
                    Text(liveNote)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.mutedInk)
                }

                if let participationNote = orientation.participationNote {
                    Text(participationNote)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.burgundy)
                }

                if let nextPartTitle = orientation.nextPartTitle {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Coming Next")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppTheme.burgundy)

                        Text(nextPartTitle)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.ink)
                            .accessibilityIdentifier("guide-next-part-title")

                        if let nextPartSummary = orientation.nextPartSummary {
                            Text(nextPartSummary)
                                .font(.caption)
                                .foregroundStyle(AppTheme.mutedInk)
                        }
                    }
                }
            }
        }
    }
}

private struct HeroCard: View {
    let part: ResolvedMassPart
    let position: Int
    let totalCount: Int
    let isBookmarked: Bool
    let onToggleBookmark: () -> Void
    let onJump: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Section \(position) of \(totalCount)")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppTheme.burgundy)

                    Text(part.title)
                        .font(.system(.title2, design: .serif).weight(.semibold))
                        .foregroundStyle(AppTheme.ink)
                        .accessibilityIdentifier("mass-part-title")

                    Text(part.summary)
                        .font(.body)
                        .foregroundStyle(AppTheme.mutedInk)

                    HStack(spacing: 8) {
                        PrayerbookBadge(title: part.libraryCategoryTitle, tone: .accent)
                        PrayerbookBadge(title: part.massForm.title, tone: .neutral)
                    }

                    if let celebrationTitle = part.celebrationTitle {
                        Text(celebrationTitle)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.burgundy)
                    }
                }

                Spacer(minLength: 16)

                Button(action: onToggleBookmark) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(AppTheme.burgundy)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(AppTheme.secondarySurface)
                        )
                }
                .accessibilityIdentifier("bookmark-button")
                .accessibilityLabel(isBookmarked ? "Remove bookmark" : "Bookmark section")
                .accessibilityValue(isBookmarked ? "Bookmarked" : "Not bookmarked")
            }

            if !part.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(part.tags, id: \.self) { tag in
                            PrayerbookBadge(title: tag, tone: .neutral)
                        }
                    }
                }
            }

            if let onJump {
                Button("Jump to Major Moments", action: onJump)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(AppTheme.burgundy)
                    )
                    .accessibilityIdentifier("jump-list-button")
                    .accessibilityLabel("Jump to major moments")
            }
        }
        .prayerbookPanel()
    }
}

private struct OrientationPill: View {
    let title: String
    let systemImage: String
    let identifier: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.caption.weight(.semibold))
            .foregroundStyle(AppTheme.ink)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(AppTheme.secondarySurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
            .accessibilityIdentifier(identifier)
    }
}

private struct SectionCard<Content: View>: View {
    let title: String
    let subtitle: String?
    @ViewBuilder let content: Content

    init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(AppTheme.ink)

                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.mutedInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            LiturgicalRule()
            content
        }
        .prayerbookPanel()
    }
}
