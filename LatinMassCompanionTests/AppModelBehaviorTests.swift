@testable import LatinMassCompanion
import Testing

struct AppModelBehaviorTests {
    @MainActor
    @Test
    func guideNavigationHelpersRespectBoundsAndDisplayIndices() throws {
        let intro = TestFixtures.makePart(
            id: "intro",
            order: 1,
            phase: .preparation,
            title: "Intro"
        )
        let collect = TestFixtures.makePart(
            id: "collect-readings",
            order: 2,
            phase: .instruction,
            title: "Collect"
        )
        let communion = TestFixtures.makePart(
            id: "communion",
            order: 3,
            phase: .communion,
            title: "Communion"
        )

        let model = AppModel(
            repository: StubMassContentRepository {
                TestFixtures.makeCatalog(parts: [communion, intro, collect])
            },
            searchService: SpySearchService(),
            bookmarkStore: SpyBookmarkStore(),
            progressStore: SpyMassModeProgressStore(),
            now: { TestFixtures.date("2026-03-30") }
        )

        let first = try #require(model.part(withID: nil))
        let middle = try #require(model.part(after: first))
        let last = try #require(model.part(withID: "communion"))

        #expect(first.id == "intro")
        #expect(model.part(before: first) == nil)
        #expect(middle.id == "collect-readings")
        #expect(model.part(before: middle)?.id == "intro")
        #expect(model.part(after: middle)?.id == "communion")
        #expect(model.part(after: last) == nil)
        #expect(model.displayIndex(for: last) == 3)
    }

    @MainActor
    @Test
    func sourceReferencesForProperPartMergeAndSortUniqueIDs() throws {
        let collect = TestFixtures.makePart(
            id: "collect-readings",
            order: 1,
            title: "Collect",
            sourceIDs: ["translation", "ordinary"]
        )
        let celebration = TestFixtures.makeCelebration(
            id: "christmas",
            title: "Christmas Day",
            properTitle: "Christmas Day Propers",
            sourceIDs: ["proper", "ordinary"]
        )

        let model = AppModel(
            repository: StubMassContentRepository {
                TestFixtures.makeCatalog(
                    parts: [collect],
                    celebrations: [celebration],
                    dateIndex: [LiturgicalDateIndex(date: "2026-12-25", celebrationID: "christmas")]
                )
            },
            searchService: SpySearchService(),
            bookmarkStore: SpyBookmarkStore(),
            progressStore: SpyMassModeProgressStore(),
            now: { TestFixtures.date("2026-12-25") }
        )

        let properPart = try #require(model.part(withID: "collect-readings"))
        let references = model.sourceReferences(for: properPart)

        #expect(properPart.isProper)
        #expect(references.map(\.id) == ["proper", "ordinary", "translation"])
    }

    @MainActor
    @Test
    func coverageWindowBoundariesStayInclusive() {
        let intro = TestFixtures.makePart(id: "intro", order: 1, title: "Intro")

        let model = AppModel(
            repository: StubMassContentRepository {
                TestFixtures.makeCatalog(parts: [intro])
            },
            searchService: SpySearchService(),
            bookmarkStore: SpyBookmarkStore(),
            progressStore: SpyMassModeProgressStore(),
            now: { TestFixtures.date("2026-01-01") }
        )

        #expect(model.isOutsideCoverageWindow == false)
        #expect(model.isShowingOrdinaryOnly)

        model.selectDate(TestFixtures.date("2026-12-31"))
        #expect(model.isOutsideCoverageWindow == false)

        model.selectDate(TestFixtures.date("2025-12-31"))
        #expect(model.isOutsideCoverageWindow)
    }

    @MainActor
    @Test
    func resumePreviewIsNilWhenSavedSectionCannotBeResolved() {
        let intro = TestFixtures.makePart(id: "intro", order: 1, title: "Intro")
        let progress = MassModeProgress(
            dateKey: "2026-03-30",
            sectionID: "missing",
            celebrationID: nil,
            lastOpenedAt: TestFixtures.date("2026-03-30")
        )

        let model = AppModel(
            repository: StubMassContentRepository {
                TestFixtures.makeCatalog(parts: [intro])
            },
            searchService: SpySearchService(),
            bookmarkStore: SpyBookmarkStore(),
            progressStore: SpyMassModeProgressStore(storedProgress: progress),
            now: { TestFixtures.date("2026-03-30") }
        )

        #expect(model.resumePreview == nil)
    }

    @MainActor
    @Test
    func learnFocusAndLookupHelpersTrackSelectedDestination() {
        let intro = TestFixtures.makePart(id: "intro", order: 1, title: "Intro")
        let model = AppModel(
            repository: StubMassContentRepository {
                TestFixtures.makeCatalog(parts: [intro])
            },
            searchService: SpySearchService(),
            bookmarkStore: SpyBookmarkStore(),
            progressStore: SpyMassModeProgressStore(),
            now: { TestFixtures.date("2026-03-30") }
        )

        model.openLearn(.participation("participating-at-low-mass"))
        #expect(model.focusedLearningDestination == .participation("participating-at-low-mass"))
        #expect(model.participationGuide(withID: "participating-at-low-mass")?.title == "How to Participate at a Low Mass")
        #expect(model.glossaryEntry(withID: "collect")?.term == "Collect")
        #expect(model.pronunciationGuide(withID: "domine-non-sum-dignus")?.title == "Domine, non sum dignus")

        model.clearLearnFocus()
        #expect(model.focusedLearningDestination == nil)
    }

    @MainActor
    @Test
    func learningGuidesAreGroupedByKindForLearnScreen() {
        let intro = TestFixtures.makePart(id: "intro", order: 1, title: "Intro")
        let model = AppModel(
            repository: StubMassContentRepository {
                TestFixtures.makeCatalog(
                    parts: [intro],
                    participationGuides: [
                        ParticipationGuide(
                            id: "orientation",
                            kind: .orientation,
                            title: "Orientation",
                            body: "Body",
                            keywords: [],
                            searchAliases: nil,
                            sourceIDs: ["translation"]
                        ),
                        ParticipationGuide(
                            id: "changes",
                            kind: .changes,
                            title: "Changes",
                            body: "Body",
                            keywords: [],
                            searchAliases: nil,
                            sourceIDs: ["translation"]
                        ),
                        ParticipationGuide(
                            id: "participation",
                            kind: .participation,
                            title: "Participation",
                            body: "Body",
                            keywords: [],
                            searchAliases: nil,
                            sourceIDs: ["translation"]
                        )
                    ]
                )
            },
            searchService: SpySearchService(),
            bookmarkStore: SpyBookmarkStore(),
            progressStore: SpyMassModeProgressStore(),
            now: { TestFixtures.date("2026-03-30") }
        )

        #expect(model.orientationGuides.map(\.id) == ["orientation"])
        #expect(model.changeGuides.map(\.id) == ["changes"])
        #expect(model.participationHelpGuides.map(\.id) == ["participation"])
    }
}
