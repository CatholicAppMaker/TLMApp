import SwiftUI

struct MassPartDetailView: View {
    let part: ResolvedMassPart
    let position: Int
    let totalCount: Int
    let orientation: GuideOrientation
    let isBookmarked: Bool
    let sourceReferences: [SourceReference]
    let glossaryEntries: [GlossaryEntry]
    let pronunciationGuides: [PronunciationGuide]
    let chantGuides: [ChantGuide]
    let onToggleBookmark: () -> Void
    let onJump: (() -> Void)?
    let onOpenLearn: (LearnDestination) -> Void

    @State private var expandedNotes: Set<String> = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
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

                SectionCard(title: "Why This Happens") {
                    VStack(spacing: 14) {
                        ForEach(part.explanationNotes) { note in
                            ExplanationCard(
                                note: note,
                                isExpanded: expandedNotes.contains(note.id),
                                toggle: {
                                    toggleNote(note.id)
                                }
                            )
                        }
                    }
                }

                if !sourceReferences.isEmpty {
                    SectionCard(title: "Sources") {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(sourceReferences) { source in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(source.title)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(AppTheme.ink)

                                    Text(source.note)
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.mutedInk)
                                }
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
                        Text(part.libraryCategoryTitle)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppTheme.gold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(AppTheme.burgundy)
                            )

                        Text(part.massForm.title)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppTheme.ink)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(AppTheme.secondarySurface)
                            )
                            .overlay(
                                Capsule(style: .continuous)
                                    .stroke(AppTheme.border, lineWidth: 1)
                            )
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
                .accessibilityValue(isBookmarked ? "Saved" : "Not saved")
            }

            if !part.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(part.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(AppTheme.burgundy)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(AppTheme.secondarySurface)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .stroke(AppTheme.border, lineWidth: 1)
                                )
                        }
                    }
                }
            }

            if let onJump {
                Button("Open jump list", action: onJump)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(AppTheme.burgundy)
                    )
                    .accessibilityIdentifier("jump-list-button")
                    .accessibilityLabel("Open jump list")
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
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(.headline, design: .serif))
                .foregroundStyle(AppTheme.ink)

            LiturgicalRule()
            content
        }
        .prayerbookPanel()
    }
}

private struct GestureCueRow: View {
    let cue: GestureCue

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: cue.systemImage)
                .foregroundStyle(AppTheme.burgundy)
                .font(.headline)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(cue.label)
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(AppTheme.ink)
                Text(cue.detail)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.mutedInk)
            }
        }
    }
}

private struct TextBlockCard: View {
    let block: TextBlock

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(block.speaker)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.burgundy)

                Spacer()

                if let rubric = block.rubric {
                    Text(rubric)
                        .font(.caption)
                        .foregroundStyle(AppTheme.mutedInk)
                        .multilineTextAlignment(.trailing)
                }
            }

            Text(block.latin)
                .font(.system(.body, design: .serif))
                .foregroundStyle(AppTheme.ink)

            LiturgicalRule()

            Text(block.english)
                .font(.body)
                .foregroundStyle(AppTheme.mutedInk)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(AppTheme.secondarySurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(AppTheme.border.opacity(0.85), lineWidth: 1)
        )
    }
}

private struct LearnLinkButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(AppTheme.ink)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppTheme.secondarySurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(AppTheme.border.opacity(0.85), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open learning note for \(title)")
    }
}

private struct ExplanationCard: View {
    let note: ExplanationNote
    let isExpanded: Bool
    let toggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: toggle) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(note.title)
                            .font(.system(.headline, design: .serif))
                            .foregroundStyle(AppTheme.ink)
                        if let sourceID = note.sourceID {
                            Text("Source: \(sourceID)")
                                .font(.caption)
                                .foregroundStyle(AppTheme.mutedInk)
                        }
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(AppTheme.burgundy)
                        .font(.subheadline.weight(.semibold))
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(note.title)
            .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")

            if isExpanded {
                Text(note.body)
                    .font(.body)
                    .foregroundStyle(AppTheme.mutedInk)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(AppTheme.secondarySurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(AppTheme.border.opacity(0.85), lineWidth: 1)
        )
    }
}
