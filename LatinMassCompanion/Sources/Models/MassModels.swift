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
    let chantGuides: [ChantGuide]
}

enum MassForm: String, Codable, CaseIterable, Identifiable, Hashable, Sendable {
    case low
    case sung

    var id: Self {
        self
    }

    var title: String {
        switch self {
        case .low:
            "Low Mass"
        case .sung:
            "Sung Mass"
        }
    }

    var subtitle: String {
        switch self {
        case .low:
            "Quieter follow-along with silence and server responses."
        case .sung:
            "Use chant-aware guidance for sung Ordinary parts and ceremonial pacing."
        }
    }

    var libraryBadge: String {
        switch self {
        case .low:
            "Low"
        case .sung:
            "Sung"
        }
    }
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

struct MassFormProfile: Codable, Hashable, Sendable {
    let massForm: MassForm
    let summary: String?
    let liveNote: String?
    let participationNote: String?
    let quickGuidance: [QuickGuidance]?
    let gestureCues: [GestureCue]?
    let sourceIDs: [String]?
    let chantGuideIDs: [String]?

    var profileSourceIDs: [String] {
        sourceIDs ?? []
    }

    var resolvedGestureCues: [GestureCue] {
        gestureCues ?? []
    }

    var resolvedQuickGuidance: [QuickGuidance] {
        quickGuidance ?? []
    }

    var resolvedChantGuideIDs: [String] {
        chantGuideIDs ?? []
    }

    var searchableText: String {
        let pieces =
            [summary ?? "", liveNote ?? "", participationNote ?? ""]
                + resolvedQuickGuidance.flatMap { [$0.title, $0.body, $0.sourceID ?? ""] }
                + profileSourceIDs
                + resolvedChantGuideIDs
                + resolvedGestureCues.flatMap { [$0.label, $0.detail] }

        return pieces.joined(separator: " ").lowercased()
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
    let quickGuidance: [QuickGuidance]?
    let explanationNotes: [ExplanationNote]
    let liveNote: String?
    let searchAliases: [String]?
    let sourceIDs: [String]?
    let glossaryIDs: [String]?
    let pronunciationIDs: [String]?
    let formProfiles: [MassFormProfile]?

    var directSourceIDs: [String] {
        sourceIDs ?? []
    }

    var glossaryReferenceIDs: [String] {
        glossaryIDs ?? []
    }

    var directQuickGuidance: [QuickGuidance] {
        quickGuidance ?? []
    }

    var pronunciationReferenceIDs: [String] {
        pronunciationIDs ?? []
    }

    var alternateSearchTerms: [String] {
        searchAliases ?? []
    }

    func profile(for massForm: MassForm) -> MassFormProfile? {
        formProfiles?.first(where: { $0.massForm == massForm })
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
                + directQuickGuidance.flatMap { [$0.title, $0.body, $0.sourceID ?? ""] }
                + explanationNotes.flatMap { [$0.title, $0.body, $0.sourceID ?? ""] }
                + (formProfiles ?? []).map(\.searchableText)
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
    let quickGuidance: [QuickGuidance]
    let explanationNotes: [ExplanationNote]
    let liveNote: String?
    let searchAliases: [String]?
    let sourceIDs: [String]
    let glossaryIDs: [String]
    let pronunciationIDs: [String]
    let formProfiles: [MassFormProfile]?

    func profile(for massForm: MassForm) -> MassFormProfile? {
        formProfiles?.first(where: { $0.massForm == massForm })
    }
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

enum ParticipationGuideKind: String, Codable, CaseIterable, Hashable, Sendable {
    case orientation
    case changes
    case participation

    var title: String {
        switch self {
        case .orientation:
            "Start Here"
        case .changes:
            "What Changes"
        case .participation:
            "Participation"
        }
    }
}

struct ParticipationGuide: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let kind: ParticipationGuideKind
    let title: String
    let body: String
    let keywords: [String]
    let searchAliases: [String]?
    let sourceIDs: [String]

    var searchableText: String {
        ([title, body, kind.title] + keywords + (searchAliases ?? []))
            .joined(separator: " ")
            .lowercased()
    }
}

struct ChantGuide: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let summary: String
    let body: String
    let keywords: [String]
    let searchAliases: [String]?
    let sourceIDs: [String]

    var searchableText: String {
        ([title, summary, body] + keywords + (searchAliases ?? []))
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
    let quickGuidance: [QuickGuidance]
    let explanationNotes: [ExplanationNote]
    let liveNote: String?
    let participationNote: String?
    let searchAliases: [String]
    let sourceIDs: [String]
    let glossaryIDs: [String]
    let pronunciationIDs: [String]
    let chantGuideIDs: [String]
    let celebrationID: String?
    let celebrationTitle: String?
    let isProper: Bool
    let massForm: MassForm

    init(part: MassPart, massForm: MassForm) {
        let profile = part.profile(for: massForm)
        id = part.id
        order = part.order
        phase = part.phase
        title = part.title
        summary = profile?.summary ?? part.summary
        tags = part.tags
        gestureCues = Array(Set(part.gestureCues + (profile?.resolvedGestureCues ?? []))).sorted {
            $0.id < $1.id
        }
        textBlocks = part.textBlocks
        quickGuidance = Self.mergeGuidance(part.directQuickGuidance, profile?.resolvedQuickGuidance ?? [])
        explanationNotes = part.explanationNotes
        liveNote = profile?.liveNote ?? part.liveNote
        participationNote = profile?.participationNote
        searchAliases = part.alternateSearchTerms
        sourceIDs = Array(Set(part.directSourceIDs + (profile?.profileSourceIDs ?? []))).sorted()
        glossaryIDs = part.glossaryReferenceIDs
        pronunciationIDs = part.pronunciationReferenceIDs
        chantGuideIDs = profile?.resolvedChantGuideIDs ?? []
        celebrationID = nil
        celebrationTitle = nil
        isProper = false
        self.massForm = massForm
    }

    init(basePart: MassPart, properSection: CelebrationSection, celebration: Celebration, massForm: MassForm) {
        let baseProfile = basePart.profile(for: massForm)
        let properProfile = properSection.profile(for: massForm)

        id = basePart.id
        order = basePart.order
        phase = basePart.phase
        title = properSection.title
        summary = properProfile?.summary ?? properSection.summary
        tags = Array(Set(basePart.tags + properSection.tags)).sorted()
        gestureCues = Array(
            Set(
                properSection.gestureCues
                    + (baseProfile?.resolvedGestureCues ?? [])
                    + (properProfile?.resolvedGestureCues ?? [])
            )
        ).sorted { $0.id < $1.id }
        textBlocks = properSection.textBlocks
        quickGuidance = Self.mergeGuidance(
            basePart.directQuickGuidance,
            baseProfile?.resolvedQuickGuidance ?? [],
            properSection.quickGuidance,
            properProfile?.resolvedQuickGuidance ?? []
        )
        explanationNotes = properSection.explanationNotes
        liveNote = properProfile?.liveNote ?? properSection.liveNote ?? baseProfile?.liveNote ?? basePart.liveNote
        participationNote = properProfile?.participationNote ?? baseProfile?.participationNote
        searchAliases = Array(
            Set(basePart.alternateSearchTerms + (properSection.searchAliases ?? []))
        ).sorted()
        sourceIDs = Array(
            Set(
                basePart.directSourceIDs
                    + properSection.sourceIDs
                    + celebration.sourceIDs
                    + (baseProfile?.profileSourceIDs ?? [])
                    + (properProfile?.profileSourceIDs ?? [])
            )
        ).sorted()
        glossaryIDs = Array(
            Set(basePart.glossaryReferenceIDs + properSection.glossaryIDs)
        ).sorted()
        pronunciationIDs = Array(
            Set(basePart.pronunciationReferenceIDs + properSection.pronunciationIDs)
        ).sorted()
        chantGuideIDs = Array(
            Set((baseProfile?.resolvedChantGuideIDs ?? []) + (properProfile?.resolvedChantGuideIDs ?? []))
        ).sorted()
        celebrationID = celebration.id
        celebrationTitle = celebration.title
        isProper = true
        self.massForm = massForm
    }

    var sourceReferenceIDs: [String] {
        let noteSourceIDs = explanationNotes.compactMap(\.sourceID)
        let quickSourceIDs = quickGuidance.compactMap(\.sourceID)
        return Array(Set(sourceIDs + noteSourceIDs + quickSourceIDs)).sorted()
    }

    var libraryCategoryTitle: String {
        isProper ? "Proper" : "Ordinary"
    }

    func searchableText(
        glossaryEntries: [GlossaryEntry],
        pronunciationGuides: [PronunciationGuide]
    ) -> String {
        let pieces =
            [
                title,
                summary,
                celebrationTitle ?? "",
                liveNote ?? "",
                participationNote ?? "",
                phase.title,
                massForm.title
            ]
            + tags
            + searchAliases
            + sourceReferenceIDs
            + chantGuideIDs
            + gestureCues.flatMap { [$0.label, $0.detail] }
            + textBlocks.flatMap { [$0.speaker, $0.latin, $0.english, $0.rubric ?? ""] }
            + quickGuidance.flatMap { [$0.title, $0.body, $0.sourceID ?? ""] }
            + explanationNotes.flatMap { [$0.title, $0.body, $0.sourceID ?? ""] }
            + glossaryEntries.flatMap {
                [$0.term, $0.definition] + $0.keywords + $0.relatedTerms + ($0.searchAliases ?? [])
            }
            + pronunciationGuides.flatMap {
                [$0.title, $0.latin, $0.phonetic, $0.note] + $0.keywords + ($0.searchAliases ?? [])
            }

        return pieces.joined(separator: " ").lowercased()
    }

    private static func mergeGuidance(_ groups: [QuickGuidance]...) -> [QuickGuidance] {
        var merged: [QuickGuidance] = []
        var seenIDs = Set<String>()

        for group in groups {
            for item in group where seenIDs.insert(item.id).inserted {
                merged.append(item)
            }
        }

        return merged
    }
}
