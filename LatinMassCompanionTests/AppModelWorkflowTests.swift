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
