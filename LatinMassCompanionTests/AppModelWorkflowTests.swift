@testable import LatinMassCompanion
import Testing

struct AppModelWorkflowTests {
    @MainActor
    @Test
    func majorMomentAnchorsResolveStableGuideLandmarks() {
        let checkpoints = [
            GuideCheckpoint("foot-of-the-altar", .preparation, "Prayers at the Foot of the Altar"),
            GuideCheckpoint("kyrie-gloria", .instruction, "Kyrie and Gloria"),
            GuideCheckpoint("collect-readings", .instruction, "Collect and Readings"),
            GuideCheckpoint("offertory", .offertory, "Offertory"),
            GuideCheckpoint("canon", .canon, "Canon"),
            GuideCheckpoint("communion", .communion, "Communion"),
            GuideCheckpoint("last-gospel", .conclusion, "Last Gospel")
        ]
        let parts = checkpoints.enumerated().map { index, checkpoint in
            TestFixtures.makePart(
                id: checkpoint.id,
                order: index + 1,
                phase: checkpoint.phase,
                title: checkpoint.title
            )
        }

        let model = AppModel(
            repository: StubMassContentRepository {
                TestFixtures.makeCatalog(parts: parts)
            },
            searchService: SpySearchService(),
            bookmarkStore: SpyBookmarkStore(),
            progressStore: SpyMassModeProgressStore(),
            now: { TestFixtures.date("2026-03-30") }
        )

        #expect(model.majorMomentAnchors.map(\.title) == [
            "Prayers at the Foot of the Altar",
            "Kyrie / Gloria",
            "Collect / Readings",
            "Offertory",
            "Canon",
            "Communion",
            "Last Gospel"
        ])
        #expect(model.majorMomentAnchors.map(\.partID) == checkpoints.map(\.id))
    }

    @MainActor
    @Test
    func focusingSavedSectionsNarrowsLibrarySearchUntilReset() {
        let intro = TestFixtures.makePart(
            id: "intro",
            order: 1,
            phase: .preparation,
            title: "Prayers at the Foot of the Altar"
        )
        let canon = TestFixtures.makePart(
            id: "canon",
            order: 2,
            phase: .canon,
            title: "Canon of the Mass"
        )
        let searchService = SpySearchService()

        let model = AppModel(
            repository: StubMassContentRepository {
                TestFixtures.makeCatalog(parts: [intro, canon])
            },
            searchService: searchService,
            bookmarkStore: SpyBookmarkStore(storedIDs: ["canon"]),
            progressStore: SpyMassModeProgressStore(),
            now: { TestFixtures.date("2026-03-30") }
        )

        #expect(model.preferredLibraryScope == .allSections)

        model.focusBookmarkedSections()
        _ = model.search(query: "canon", scope: model.preferredLibraryScope)
        #expect(model.preferredLibraryScope == .bookmarks)
        #expect(searchService.capturedPartIDs == ["canon"])

        model.focusAllSections()
        _ = model.search(query: "altar", scope: model.preferredLibraryScope)
        #expect(model.preferredLibraryScope == .allSections)
        #expect(searchService.capturedPartIDs == ["intro", "canon"])
    }

    @MainActor
    @Test
    func celebrationSectionsGroupVisibleCoverageByMonth() {
        let model = AppModel(
            repository: StubMassContentRepository {
                TestFixtures.makeCatalog(
                    parts: [TestFixtures.makePart(id: "intro", order: 1, title: "Intro")],
                    celebrations: [
                        TestFixtures.makeCelebration(id: "epiphany", title: "Epiphany", properTitle: "Epiphany Proper"),
                        TestFixtures.makeCelebration(id: "easter", title: "Easter Sunday", properTitle: "Easter Proper")
                    ],
                    dateIndex: [
                        LiturgicalDateIndex(date: "2026-01-06", celebrationID: "epiphany"),
                        LiturgicalDateIndex(date: "2026-04-05", celebrationID: "easter")
                    ]
                )
            },
            searchService: SpySearchService(),
            bookmarkStore: SpyBookmarkStore(),
            progressStore: SpyMassModeProgressStore(),
            now: { TestFixtures.date("2026-01-06") }
        )

        let sections = model.celebrationSections(matching: "")

        #expect(sections.map(\.title) == ["January 2026", "April 2026"])
        #expect(sections.flatMap(\.listings).map(\.title) == ["Epiphany", "Easter Sunday"])
        #expect(sections.flatMap(\.listings).allSatisfy { $0.coverageBadgeTitle == "Proper Texts" })
    }

    @MainActor
    @Test
    func openingGuideSectionQueuesPendingSelectionAndChangesToken() {
        let model = AppModel(
            repository: StubMassContentRepository {
                TestFixtures.makeCatalog(
                    parts: [
                        TestFixtures.makePart(id: "intro", order: 1, title: "Intro"),
                        TestFixtures.makePart(id: "canon", order: 2, phase: .canon, title: "Canon")
                    ]
                )
            },
            searchService: SpySearchService(),
            bookmarkStore: SpyBookmarkStore(),
            progressStore: SpyMassModeProgressStore(),
            now: { TestFixtures.date("2026-03-30") }
        )

        let firstToken = model.guideSelectionToken

        model.openGuideSection("canon")

        #expect(model.consumePendingGuideSectionID() == "canon")
        #expect(model.guideSelectionToken != firstToken)
    }

    @MainActor
    @Test
    func riteTimelineMarksCurrentCheckpointFromActiveSection() {
        let checkpoints = [
            GuideCheckpoint("foot-of-the-altar", .preparation, "Prayers at the Foot of the Altar"),
            GuideCheckpoint("kyrie-gloria", .instruction, "Kyrie and Gloria"),
            GuideCheckpoint("collect-readings", .instruction, "Collect and Readings"),
            GuideCheckpoint("offertory", .offertory, "Offertory"),
            GuideCheckpoint("canon", .canon, "Canon"),
            GuideCheckpoint("communion", .communion, "Communion"),
            GuideCheckpoint("last-gospel", .conclusion, "Last Gospel")
        ]
        let parts = checkpoints.enumerated().map { index, checkpoint in
            TestFixtures.makePart(
                id: checkpoint.id,
                order: index + 1,
                phase: checkpoint.phase,
                title: checkpoint.title
            )
        }

        let model = AppModel(
            repository: StubMassContentRepository {
                TestFixtures.makeCatalog(parts: parts)
            },
            searchService: SpySearchService(),
            bookmarkStore: SpyBookmarkStore(),
            progressStore: SpyMassModeProgressStore(),
            now: { TestFixtures.date("2026-03-30") }
        )

        let timeline = model.riteTimelineCheckpoints(activePartID: "canon")

        #expect(timeline.first(where: { $0.id == "offertory" })?.state == .completed)
        #expect(timeline.first(where: { $0.id == "canon" })?.state == .current)
        #expect(timeline.first(where: { $0.id == "communion" })?.state == .upcoming)
    }

    @MainActor
    @Test
    func synchronizedGuideSelectionPreservesResumePromptWhenSavedPlaceDiffersFromOpening() {
        let intro = TestFixtures.makePart(id: "intro", order: 1, title: "Intro")
        let canon = TestFixtures.makePart(id: "canon", order: 2, phase: .canon, title: "Canon of the Mass")
        let savedProgress = MassModeProgress(
            dateKey: "2026-03-30",
            sectionID: "canon",
            celebrationID: nil,
            massForm: .low,
            lastOpenedAt: TestFixtures.date("2026-03-30")
        )

        let model = AppModel(
            repository: StubMassContentRepository {
                TestFixtures.makeCatalog(parts: [intro, canon])
            },
            searchService: SpySearchService(),
            bookmarkStore: SpyBookmarkStore(),
            progressStore: SpyMassModeProgressStore(storedProgress: savedProgress),
            now: { TestFixtures.date("2026-03-30") }
        )

        let update = model.synchronizedGuideSelection(from: nil)

        #expect(update.sectionID == "intro")
        #expect(update.shouldRecordProgress == false)
        #expect(model.canResumeSavedPlace(from: update.sectionID))
    }

    @MainActor
    @Test
    func synchronizedGuideSelectionUsesPendingGuideSectionWhenPresent() {
        let intro = TestFixtures.makePart(id: "intro", order: 1, title: "Intro")
        let canon = TestFixtures.makePart(id: "canon", order: 2, phase: .canon, title: "Canon of the Mass")

        let model = AppModel(
            repository: StubMassContentRepository {
                TestFixtures.makeCatalog(parts: [intro, canon])
            },
            searchService: SpySearchService(),
            bookmarkStore: SpyBookmarkStore(),
            progressStore: SpyMassModeProgressStore(),
            now: { TestFixtures.date("2026-03-30") }
        )

        model.openGuideSection("canon")
        let update = model.synchronizedGuideSelection(from: "intro")

        #expect(update.sectionID == "canon")
        #expect(update.shouldRecordProgress)
        #expect(model.consumePendingGuideSectionID() == nil)
    }
}

private struct GuideCheckpoint {
    let id: String
    let phase: MassPhase
    let title: String

    init(_ id: String, _ phase: MassPhase, _ title: String) {
        self.id = id
        self.phase = phase
        self.title = title
    }
}
