import SwiftUI

struct LearnView: View {
    let appModel: AppModel

    var body: some View {
        ZStack {
            Rectangle()
                .fill(AppTheme.backgroundWash)
                .ignoresSafeArea()

            List {
                introSection
                focusSection
                participationSection(kind: .orientation)
                participationSection(kind: .changes)
                participationSection(kind: .participation)
                chantSection
                pronunciationSection
                glossarySection
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Learn")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var introSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 10) {
                Text(
                    """
                    Use this area to learn the shape of the 1962 Mass,
                    understand what changes by day, and follow chant or
                    pronunciation without needing a network connection.
                    """
                )
                .font(.body)
                .foregroundStyle(AppTheme.mutedInk)

                Text(
                    """
                    The goal is practical confidence, not information overload.
                    You do not need to master every line in order to pray fruitfully.
                    """
                )
                .font(.subheadline)
                .foregroundStyle(AppTheme.mutedInk)
            }
            .padding(.vertical, 8)
            .listRowBackground(AppTheme.surface)
        }
    }

    @ViewBuilder
    private var focusSection: some View {
        if let focusedItem = focusedContent {
            Section("From the Guide") {
                VStack(alignment: .leading, spacing: 10) {
                    focusedItem

                    Button("Clear Highlight") {
                        appModel.clearLearnFocus()
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.burgundy)
                }
                .padding(.vertical, 8)
                .listRowBackground(AppTheme.surface)
            }
        }
    }

    @ViewBuilder
    private func participationSection(kind: ParticipationGuideKind) -> some View {
        let items = appModel.participationGuides.filter { $0.kind == kind }
        if !items.isEmpty {
            Section(kind.title) {
                ForEach(items) { guide in
                    ParticipationGuideRow(guide: guide)
                        .listRowBackground(AppTheme.surface)
                }
            }
        }
    }

    @ViewBuilder
    private var chantSection: some View {
        if !appModel.chantGuides.isEmpty {
            Section("Gregorian Chant") {
                ForEach(appModel.chantGuides) { guide in
                    ChantGuideRow(guide: guide)
                        .listRowBackground(AppTheme.surface)
                }
            }
        }
    }

    @ViewBuilder
    private var pronunciationSection: some View {
        if !appModel.pronunciationGuides.isEmpty {
            Section("Pronunciation") {
                ForEach(appModel.pronunciationGuides) { guide in
                    PronunciationGuideRow(guide: guide)
                        .listRowBackground(AppTheme.surface)
                }
            }
        }
    }

    @ViewBuilder
    private var glossarySection: some View {
        if !appModel.glossaryEntries.isEmpty {
            Section("Glossary") {
                ForEach(appModel.glossaryEntries) { entry in
                    GlossaryEntryRow(entry: entry)
                        .listRowBackground(AppTheme.surface)
                }
            }
        }
    }

    private var focusedContent: AnyView? {
        switch appModel.focusedLearningDestination {
        case let .glossary(id):
            if let entry = appModel.glossaryEntry(withID: id) {
                return AnyView(GlossaryEntryRow(entry: entry))
            }
        case let .pronunciation(id):
            if let guide = appModel.pronunciationGuide(withID: id) {
                return AnyView(PronunciationGuideRow(guide: guide))
            }
        case let .participation(id):
            if let guide = appModel.participationGuide(withID: id) {
                return AnyView(ParticipationGuideRow(guide: guide))
            }
        case let .chant(id):
            if let guide = appModel.chantGuide(withID: id) {
                return AnyView(ChantGuideRow(guide: guide))
            }
        case nil:
            return nil
        }

        return nil
    }
}

private struct GlossaryEntryRow: View {
    let entry: GlossaryEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.term)
                .font(.system(.headline, design: .serif))
                .foregroundStyle(AppTheme.ink)
                .accessibilityIdentifier("learn-glossary-\(entry.id)")

            Text(entry.definition)
                .font(.body)
                .foregroundStyle(AppTheme.mutedInk)

            if !entry.relatedTerms.isEmpty {
                Text("Related: \(entry.relatedTerms.joined(separator: ", "))")
                    .font(.caption)
                    .foregroundStyle(AppTheme.burgundy)
            }
        }
        .padding(.vertical, 8)
    }
}

private struct PronunciationGuideRow: View {
    let guide: PronunciationGuide

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(guide.title)
                .font(.system(.headline, design: .serif))
                .foregroundStyle(AppTheme.ink)
                .accessibilityIdentifier("learn-pronunciation-\(guide.id)")

            Text(guide.latin)
                .font(.system(.body, design: .serif))
                .foregroundStyle(AppTheme.ink)

            Text(guide.phonetic)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.burgundy)

            Text(guide.note)
                .font(.body)
                .foregroundStyle(AppTheme.mutedInk)
        }
        .padding(.vertical, 8)
    }
}

private struct ParticipationGuideRow: View {
    let guide: ParticipationGuide

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(guide.title)
                .font(.system(.headline, design: .serif))
                .foregroundStyle(AppTheme.ink)
                .accessibilityIdentifier("learn-participation-\(guide.id)")

            Text(guide.body)
                .font(.body)
                .foregroundStyle(AppTheme.mutedInk)
        }
        .padding(.vertical, 8)
    }
}

private struct ChantGuideRow: View {
    let guide: ChantGuide

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(guide.title)
                .font(.system(.headline, design: .serif))
                .foregroundStyle(AppTheme.ink)
                .accessibilityIdentifier("learn-chant-\(guide.id)")

            Text(guide.summary)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.burgundy)

            Text(guide.body)
                .font(.body)
                .foregroundStyle(AppTheme.mutedInk)
        }
        .padding(.vertical, 8)
    }
}
