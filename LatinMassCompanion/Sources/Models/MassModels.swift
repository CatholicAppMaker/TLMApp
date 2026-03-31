import Foundation

struct MassCatalog: Codable, Sendable {
    let title: String
    let subtitle: String
    let coverageWindow: CoverageWindow
    let sources: [SourceReference]
    let parts: [MassPart]
    let celebrations: [Celebration]
    let dateIndex: [LiturgicalDateIndex]
    let glossaryEntries: [GlossaryEntry]
    let pronunciationGuides: [PronunciationGuide]
    let participationGuides: [ParticipationGuide]
}

struct SourceReference: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let description: String
    let note: String
    let url: String?
    let category: String?
    let rights: String?
    let attribution: String?
    let coverageNote: String?
}

struct CoverageWindow: Codable, Hashable, Sendable {
    let title: String
    let startDate: String
    let endDate: String
    let description: String
}

enum MassPhase: String, Codable, CaseIterable, Hashable, Sendable {
    case preparation
    case instruction
    case offertory
    case canon
    case communion
    case conclusion

    var title: String {
        switch self {
        case .preparation:
            "Preparation"
        case .instruction:
            "Instruction"
        case .offertory:
            "Offertory"
        case .canon:
            "Canon"
        case .communion:
            "Communion"
        case .conclusion:
            "Conclusion"
        }
    }
}

struct MassPart: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let order: Int
    let phase: MassPhase
    let title: String
    let summary: String
    let tags: [String]
    let gestureCues: [GestureCue]
    let textBlocks: [TextBlock]
    let explanationNotes: [ExplanationNote]
    let liveNote: String?
    let searchAliases: [String]?
    let sourceIDs: [String]?
    let glossaryIDs: [String]?
    let pronunciationIDs: [String]?

    var directSourceIDs: [String] {
        sourceIDs ?? []
    }

    var glossaryReferenceIDs: [String] {
        glossaryIDs ?? []
    }

    var pronunciationReferenceIDs: [String] {
        pronunciationIDs ?? []
    }

    var alternateSearchTerms: [String] {
        searchAliases ?? []
    }

    var searchableText: String {
        searchableText(glossaryEntries: [], pronunciationGuides: [])
    }

    func searchableText(
        glossaryEntries: [GlossaryEntry],
        pronunciationGuides: [PronunciationGuide]
    ) -> String {
        let pieces =
            [title, summary, liveNote ?? ""]
                + tags
                + alternateSearchTerms
                + directSourceIDs
                + gestureCues.flatMap { [$0.label, $0.detail] }
                + textBlocks.flatMap { [$0.speaker, $0.latin, $0.english, $0.rubric ?? ""] }
                + explanationNotes.flatMap { [$0.title, $0.body, $0.sourceID ?? ""] }
                + glossaryEntries.flatMap {
                    [$0.term, $0.definition] + $0.keywords + $0.relatedTerms + ($0.searchAliases ?? [])
                }
                + pronunciationGuides.flatMap {
                    [$0.title, $0.latin, $0.phonetic, $0.note] + $0.keywords + ($0.searchAliases ?? [])
                }

        return pieces.joined(separator: " ").lowercased()
    }
}

struct GestureCue: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let label: String
    let detail: String
    let systemImage: String
}

struct TextBlock: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let speaker: String
    let latin: String
    let english: String
    let rubric: String?
}

struct ExplanationNote: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let body: String
    let sourceID: String?
}

struct Celebration: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let summary: String
    let rank: String
    let sourceIDs: [String]
    let properSections: [CelebrationSection]
}

struct CelebrationSection: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let replacesPartID: String
    let title: String
    let summary: String
    let tags: [String]
    let gestureCues: [GestureCue]
    let textBlocks: [TextBlock]
    let explanationNotes: [ExplanationNote]
    let liveNote: String?
    let searchAliases: [String]?
    let sourceIDs: [String]
    let glossaryIDs: [String]
    let pronunciationIDs: [String]
}

struct LiturgicalDateIndex: Codable, Hashable, Identifiable, Sendable {
    let date: String
    let celebrationID: String

    var id: String {
        date
    }
}

struct GlossaryEntry: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let term: String
    let definition: String
    let keywords: [String]
    let relatedTerms: [String]
    let searchAliases: [String]?
    let sourceIDs: [String]

    var searchableText: String {
        ([term, definition] + keywords + relatedTerms + (searchAliases ?? []))
            .joined(separator: " ")
            .lowercased()
    }
}

struct PronunciationGuide: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let latin: String
    let phonetic: String
    let note: String
    let keywords: [String]
    let searchAliases: [String]?
    let sourceIDs: [String]

    var searchableText: String {
        ([title, latin, phonetic, note] + keywords + (searchAliases ?? []))
            .joined(separator: " ")
            .lowercased()
    }
}

struct ParticipationGuide: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let body: String
    let keywords: [String]
    let searchAliases: [String]?
    let sourceIDs: [String]

    var searchableText: String {
        ([title, body] + keywords + (searchAliases ?? []))
            .joined(separator: " ")
            .lowercased()
    }
}

struct ResolvedMassPart: Identifiable, Hashable, Sendable {
    let id: String
    let order: Int
    let phase: MassPhase
    let title: String
    let summary: String
    let tags: [String]
    let gestureCues: [GestureCue]
    let textBlocks: [TextBlock]
    let explanationNotes: [ExplanationNote]
    let liveNote: String?
    let searchAliases: [String]
    let sourceIDs: [String]
    let glossaryIDs: [String]
    let pronunciationIDs: [String]
    let celebrationID: String?
    let celebrationTitle: String?
    let isProper: Bool

    init(part: MassPart) {
        id = part.id
        order = part.order
        phase = part.phase
        title = part.title
        summary = part.summary
        tags = part.tags
        gestureCues = part.gestureCues
        textBlocks = part.textBlocks
        explanationNotes = part.explanationNotes
        liveNote = part.liveNote
        searchAliases = part.alternateSearchTerms
        sourceIDs = part.directSourceIDs
        glossaryIDs = part.glossaryReferenceIDs
        pronunciationIDs = part.pronunciationReferenceIDs
        celebrationID = nil
        celebrationTitle = nil
        isProper = false
    }

    init(basePart: MassPart, properSection: CelebrationSection, celebration: Celebration) {
        id = basePart.id
        order = basePart.order
        phase = basePart.phase
        title = properSection.title
        summary = properSection.summary
        tags = Array(Set(basePart.tags + properSection.tags)).sorted()
        gestureCues = properSection.gestureCues
        textBlocks = properSection.textBlocks
        explanationNotes = properSection.explanationNotes
        liveNote = properSection.liveNote ?? basePart.liveNote
        searchAliases = Array(
            Set(basePart.alternateSearchTerms + (properSection.searchAliases ?? []))
        ).sorted()
        sourceIDs = Array(Set(basePart.directSourceIDs + properSection.sourceIDs + celebration.sourceIDs)).sorted()
        glossaryIDs = Array(Set(basePart.glossaryReferenceIDs + properSection.glossaryIDs)).sorted()
        pronunciationIDs = Array(Set(basePart.pronunciationReferenceIDs + properSection.pronunciationIDs)).sorted()
        celebrationID = celebration.id
        celebrationTitle = celebration.title
        isProper = true
    }

    var sourceReferenceIDs: [String] {
        let noteSourceIDs = explanationNotes.compactMap(\.sourceID)
        return Array(Set(sourceIDs + noteSourceIDs)).sorted()
    }

    func searchableText(
        glossaryEntries: [GlossaryEntry],
        pronunciationGuides: [PronunciationGuide]
    ) -> String {
        let pieces =
            [title, summary, celebrationTitle ?? "", liveNote ?? "", phase.title]
                + tags
                + searchAliases
                + sourceReferenceIDs
                + gestureCues.flatMap { [$0.label, $0.detail] }
                + textBlocks.flatMap { [$0.speaker, $0.latin, $0.english, $0.rubric ?? ""] }
                + explanationNotes.flatMap { [$0.title, $0.body, $0.sourceID ?? ""] }
                + glossaryEntries.flatMap {
                    [$0.term, $0.definition] + $0.keywords + $0.relatedTerms + ($0.searchAliases ?? [])
                }
                + pronunciationGuides.flatMap {
                    [$0.title, $0.latin, $0.phonetic, $0.note] + $0.keywords + ($0.searchAliases ?? [])
                }

        return pieces.joined(separator: " ").lowercased()
    }
}

enum LearnDestination: Hashable, Sendable {
    case glossary(String)
    case pronunciation(String)
    case participation(String)
}

enum LearningSearchResult: Identifiable, Hashable, Sendable {
    case glossary(GlossaryEntry)
    case pronunciation(PronunciationGuide)
    case participation(ParticipationGuide)

    var id: String {
        switch self {
        case let .glossary(entry):
            "glossary-\(entry.id)"
        case let .pronunciation(guide):
            "pronunciation-\(guide.id)"
        case let .participation(guide):
            "participation-\(guide.id)"
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
        }
    }

    var categoryTitle: String {
        switch self {
        case .glossary:
            "Glossary"
        case .pronunciation:
            "Pronunciation"
        case .participation:
            "Participation"
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
