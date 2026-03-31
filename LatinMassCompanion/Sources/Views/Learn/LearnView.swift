import SwiftUI

private enum LearnCategory: String, CaseIterable, Identifiable {
    case glossary
    case pronunciation
    case participation

    var id: Self {
        self
    }

    var title: String {
        switch self {
        case .glossary:
            "Glossary"
        case .pronunciation:
            "Pronunciation"
        case .participation:
            "Participation"
        }
    }
}

struct LearnView: View {
    let appModel: AppModel

    @State private var selectedCategory: LearnCategory = .glossary

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            List {
                focusSection
                pickerSection
                contentSection
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Learn")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: syncCategoryWithFocus)
        .onChange(of: appModel.focusedLearningDestination) { _, _ in
            syncCategoryWithFocus()
        }
    }

    private var focusSection: some View {
        Group {
            if let focusedItem = focusedContent {
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("From the Guide")
                            .font(.headline)
                            .foregroundStyle(AppTheme.ink)

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
    }

    private var pickerSection: some View {
        Section {
            Picker("Category", selection: $selectedCategory) {
                ForEach(LearnCategory.allCases) { category in
                    Text(category.title).tag(category)
                }
            }
            .pickerStyle(.segmented)
            .listRowBackground(Color.clear)
        }
    }

    @ViewBuilder
    private var contentSection: some View {
        switch selectedCategory {
        case .glossary:
            Section {
                ForEach(appModel.glossaryEntries) { entry in
                    GlossaryEntryRow(entry: entry)
                        .listRowBackground(AppTheme.surface)
                }
            }
        case .pronunciation:
            Section {
                ForEach(appModel.pronunciationGuides) { guide in
                    PronunciationGuideRow(guide: guide)
                        .listRowBackground(AppTheme.surface)
                }
            }
        case .participation:
            Section {
                ForEach(appModel.participationGuides) { guide in
                    ParticipationGuideRow(guide: guide)
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
        case nil:
            return nil
        }

        return nil
    }

    private func syncCategoryWithFocus() {
        guard let destination = appModel.focusedLearningDestination else {
            return
        }

        switch destination {
        case .glossary:
            selectedCategory = .glossary
        case .pronunciation:
            selectedCategory = .pronunciation
        case .participation:
            selectedCategory = .participation
        }
    }
}

private struct GlossaryEntryRow: View {
    let entry: GlossaryEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.term)
                .font(.headline)
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
                .font(.headline)
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
                .font(.headline)
                .foregroundStyle(AppTheme.ink)
                .accessibilityIdentifier("learn-participation-\(guide.id)")

            Text(guide.body)
                .font(.body)
                .foregroundStyle(AppTheme.mutedInk)
        }
        .padding(.vertical, 8)
    }
}
