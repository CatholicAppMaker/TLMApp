import Foundation
@testable import LatinMassCompanion

struct StubMassContentRepository: MassContentRepository {
    let load: () throws -> MassCatalog

    func loadCatalog() throws -> MassCatalog {
        try load()
    }
}

final class SpySearchService: SearchService {
    private(set) var capturedQuery: String?
    private(set) var capturedPartIDs: [String] = []
    private(set) var capturedGlossaryIDs: [String] = []
    private(set) var capturedPronunciationIDs: [String] = []
    private(set) var capturedParticipationIDs: [String] = []
    var nextResults = LibrarySearchResults(parts: [], learningItems: [])

    func search(
        query: String,
        in parts: [ResolvedMassPart],
        glossaryEntries: [GlossaryEntry],
        pronunciationGuides: [PronunciationGuide],
        participationGuides: [ParticipationGuide]
    ) -> LibrarySearchResults {
        capturedQuery = query
        capturedPartIDs = parts.map(\.id)
        capturedGlossaryIDs = glossaryEntries.map(\.id)
        capturedPronunciationIDs = pronunciationGuides.map(\.id)
        capturedParticipationIDs = participationGuides.map(\.id)
        return nextResults
    }
}

final class SpyBookmarkStore: BookmarkStore {
    private(set) var storedIDs: Set<String>
    private(set) var saveCalls: [Set<String>] = []

    init(storedIDs: Set<String> = []) {
        self.storedIDs = storedIDs
    }

    func loadBookmarks() -> Set<String> {
        storedIDs
    }

    func saveBookmarks(_ ids: Set<String>) {
        storedIDs = ids
        saveCalls.append(ids)
    }
}

final class SpyMassModeProgressStore: MassModeProgressStore {
    private(set) var storedProgress: MassModeProgress?
    private(set) var saveCalls: [MassModeProgress] = []
    private(set) var clearCallCount = 0

    init(storedProgress: MassModeProgress? = nil) {
        self.storedProgress = storedProgress
    }

    func loadProgress() -> MassModeProgress? {
        storedProgress
    }

    func saveProgress(_ progress: MassModeProgress) {
        storedProgress = progress
        saveCalls.append(progress)
    }

    func clearProgress() {
        storedProgress = nil
        clearCallCount += 1
    }
}

enum SampleTestError: LocalizedError {
    case loadFailed

    var errorDescription: String? {
        "Sample load failure"
    }
}

enum TestFixtures {
    static let sources = [
        SourceReference(
            id: "ordinary",
            title: "Missale Romanum (1962), Ordinary of the Mass",
            description: "Core Latin text",
            note: "Primary structure",
            url: nil,
            category: "ordinary",
            rights: "Public-domain Latin text",
            attribution: "Ordinary baseline",
            coverageNote: "Always available"
        ),
        SourceReference(
            id: "translation",
            title: "Public-domain English hand missal translations",
            description: "English reference text",
            note: "Explanatory English support",
            url: nil,
            category: "translation",
            rights: "Public-domain devotional support",
            attribution: "Hand missal adaptation",
            coverageNote: "Supports learning and notes"
        ),
        SourceReference(
            id: "proper",
            title: "Bundled propers for Sundays and major feasts",
            description: "Local calendar supplement",
            note: "Offline proper texts",
            url: nil,
            category: "proper",
            rights: "Bundled public-domain adaptation",
            attribution: "Supported year proper set",
            coverageNote: "Used for date-backed propers"
        )
    ]

    static let coverageWindow = CoverageWindow(
        title: "2026 Bundled Sunday and Feast Coverage",
        startDate: "2026-01-01",
        endDate: "2026-12-31",
        description: "Bundled Sundays and major feasts for 2026."
    )

    static let defaultGlossaryEntries = [
        GlossaryEntry(
            id: "collect",
            term: "Collect",
            definition: "The opening prayer that gathers the petitions of the faithful.",
            keywords: ["oration", "opening prayer"],
            relatedTerms: ["Roman Canon"],
            searchAliases: ["day prayer"],
            sourceIDs: ["ordinary"]
        ),
        GlossaryEntry(
            id: "canon",
            term: "Roman Canon",
            definition: "The central Eucharistic prayer of the Mass.",
            keywords: ["canon", "eucharistic prayer"],
            relatedTerms: ["Collect"],
            searchAliases: ["te igitur"],
            sourceIDs: ["ordinary"]
        ),
        GlossaryEntry(
            id: "agnus-dei",
            term: "Agnus Dei",
            definition: "The invocation to the Lamb of God before Communion.",
            keywords: ["lamb of god", "communion"],
            relatedTerms: ["Roman Canon"],
            searchAliases: ["agnus"],
            sourceIDs: ["ordinary"]
        )
    ]

    static let defaultPronunciationGuides = [
        PronunciationGuide(
            id: "et-cum-spiritu-tuo",
            title: "Et cum spiritu tuo",
            latin: "Et cum spiritu tuo",
            phonetic: "et koom spee-ree-too too-oh",
            note: "A common congregational response.",
            keywords: ["response", "greeting"],
            searchAliases: ["and with thy spirit"],
            sourceIDs: ["ordinary"]
        ),
        PronunciationGuide(
            id: "domine-non-sum-dignus",
            title: "Domine, non sum dignus",
            latin: "Domine, non sum dignus",
            phonetic: "DOH-mee-neh non soom DEEN-yoos",
            note: "Said before Holy Communion.",
            keywords: ["communion", "worthy"],
            searchAliases: ["lord i am not worthy"],
            sourceIDs: ["ordinary"]
        )
    ]

    static let defaultParticipationGuides = [
        ParticipationGuide(
            id: "participating-at-low-mass",
            title: "How to Participate at a Low Mass",
            body: "Pray with the texts, watch the altar, and use silence well.",
            keywords: ["newcomer", "participation"],
            searchAliases: ["first visit"],
            sourceIDs: ["translation"]
        ),
        ParticipationGuide(
            id: "when-not-receiving-communion",
            title: "When You Are Not Receiving Communion",
            body: "Remain prayerful and unite yourself spiritually to the sacrifice.",
            keywords: ["communion", "spiritual communion"],
            searchAliases: ["not receiving"],
            sourceIDs: ["translation"]
        )
    ]

    static func makeCatalog(
        parts: [MassPart],
        celebrations: [Celebration] = [],
        dateIndex: [LiturgicalDateIndex] = [],
        coverageWindow: CoverageWindow = coverageWindow,
        glossaryEntries: [GlossaryEntry] = defaultGlossaryEntries,
        pronunciationGuides: [PronunciationGuide] = defaultPronunciationGuides,
        participationGuides: [ParticipationGuide] = defaultParticipationGuides
    ) -> MassCatalog {
        MassCatalog(
            title: "Test Library",
            subtitle: "Sample subtitle",
            coverageWindow: coverageWindow,
            sources: sources,
            parts: parts,
            celebrations: celebrations,
            dateIndex: dateIndex,
            glossaryEntries: glossaryEntries,
            pronunciationGuides: pronunciationGuides,
            participationGuides: participationGuides
        )
    }

    static func makePart(
        id: String,
        order: Int,
        phase: MassPhase = .instruction,
        title: String,
        summary: String = "Summary",
        tags: [String] = ["tag"],
        gestureCues: [GestureCue] = [
            GestureCue(
                id: "gesture",
                label: "Stand",
                detail: "Stand quietly",
                systemImage: "figure.stand"
            )
        ],
        textBlocks: [TextBlock] = [
            TextBlock(
                id: "text",
                speaker: "Priest",
                latin: "Dominus vobiscum",
                english: "The Lord be with you",
                rubric: "Greeting"
            )
        ],
        explanationNotes: [ExplanationNote] = [
            ExplanationNote(
                id: "note",
                title: "Meaning",
                body: "An explanation of the rite.",
                sourceID: "ordinary"
            )
        ],
        liveNote: String? = "Stay with the guide calmly.",
        searchAliases: [String]? = [],
        sourceIDs: [String]? = ["ordinary"],
        glossaryIDs: [String]? = [],
        pronunciationIDs: [String]? = []
    ) -> MassPart {
        MassPart(
            id: id,
            order: order,
            phase: phase,
            title: title,
            summary: summary,
            tags: tags,
            gestureCues: gestureCues,
            textBlocks: textBlocks,
            explanationNotes: explanationNotes,
            liveNote: liveNote,
            searchAliases: searchAliases,
            sourceIDs: sourceIDs,
            glossaryIDs: glossaryIDs,
            pronunciationIDs: pronunciationIDs
        )
    }

    static func makeCelebration(
        id: String,
        title: String,
        subtitle: String = "Feast subtitle",
        summary: String = "Feast summary",
        rank: String = "First Class",
        replacesPartID: String = "collect-readings",
        properTitle: String,
        properSummary: String = "Proper summary",
        properTags: [String] = ["proper"],
        properLiveNote: String? = "This is where the day changes most clearly.",
        properSearchAliases: [String] = [],
        properGlossaryIDs: [String] = [],
        properPronunciationIDs: [String] = [],
        sourceIDs: [String] = ["proper"]
    ) -> Celebration {
        Celebration(
            id: id,
            title: title,
            subtitle: subtitle,
            summary: summary,
            rank: rank,
            sourceIDs: sourceIDs,
            properSections: [
                CelebrationSection(
                    id: "\(id)-proper",
                    replacesPartID: replacesPartID,
                    title: properTitle,
                    summary: properSummary,
                    tags: properTags,
                    gestureCues: [
                        GestureCue(
                            id: "\(id)-gesture",
                            label: "Listen closely",
                            detail: "The proper text changes the focus of the Mass.",
                            systemImage: "figure.stand"
                        )
                    ],
                    textBlocks: [
                        TextBlock(
                            id: "\(id)-text",
                            speaker: "Priest",
                            latin: "Proper Latin text",
                            english: "Proper English text",
                            rubric: "Proper"
                        )
                    ],
                    explanationNotes: [
                        ExplanationNote(
                            id: "\(id)-note",
                            title: "Why this feast matters",
                            body: "The proper texts teach the character of the celebration.",
                            sourceID: "translation"
                        )
                    ],
                    liveNote: properLiveNote,
                    searchAliases: properSearchAliases,
                    sourceIDs: sourceIDs,
                    glossaryIDs: properGlossaryIDs,
                    pronunciationIDs: properPronunciationIDs
                )
            ]
        )
    }

    static func date(_ value: String) -> Date {
        guard let date = storageDateFormatter.date(from: value) else {
            fatalError("Invalid test date: \(value)")
        }
        return date
    }

    private static let storageDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

final class TestBundleLocator {}
