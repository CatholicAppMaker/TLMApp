import Foundation

enum LearnDestination: Hashable, Sendable {
    case glossary(String)
    case pronunciation(String)
    case participation(String)
    case chant(String)
}

enum LearningSearchResult: Identifiable, Hashable, Sendable {
    case glossary(GlossaryEntry)
    case pronunciation(PronunciationGuide)
    case participation(ParticipationGuide)
    case chant(ChantGuide)

    var id: String {
        switch self {
        case let .glossary(entry):
            "glossary-\(entry.id)"
        case let .pronunciation(guide):
            "pronunciation-\(guide.id)"
        case let .participation(guide):
            "participation-\(guide.id)"
        case let .chant(guide):
            "chant-\(guide.id)"
        }
    }

    var title: String {
        switch self {
        case let .glossary(entry):
            entry.term
        case let .pronunciation(guide):
            guide.title
        case let .participation(guide):
            guide.title
        case let .chant(guide):
            guide.title
        }
    }

    var summary: String {
        switch self {
        case let .glossary(entry):
            entry.definition
        case let .pronunciation(guide):
            guide.note
        case let .participation(guide):
            guide.body
        case let .chant(guide):
            guide.summary
        }
    }

    var categoryTitle: String {
        switch self {
        case .glossary:
            "Glossary"
        case .pronunciation:
            "Pronunciation"
        case let .participation(guide):
            guide.kind.title
        case .chant:
            "Gregorian Chant"
        }
    }

    var destination: LearnDestination {
        switch self {
        case let .glossary(entry):
            .glossary(entry.id)
        case let .pronunciation(guide):
            .pronunciation(guide.id)
        case let .participation(guide):
            .participation(guide.id)
        case let .chant(guide):
            .chant(guide.id)
        }
    }
}

struct LibrarySearchResults: Hashable, Sendable {
    let parts: [ResolvedMassPart]
    let learningItems: [LearningSearchResult]

    var isEmpty: Bool {
        parts.isEmpty && learningItems.isEmpty
    }
}
