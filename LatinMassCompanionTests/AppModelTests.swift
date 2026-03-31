@testable import LatinMassCompanion
import Testing

struct AppModelTests {
    @MainActor
    @Test
    func resumeMassRestoresSavedDateAndSection() {
        let intro = TestFixtures.makePart(id: "intro", order: 1, title: "Intro")
        let collect = TestFixtures.makePart(
            id: "collect-readings",
            order: 2,
            title: "Collect, Epistle, and Gradual"
        )
        let repository = StubMassContentRepository {
            TestFixtures.makeCatalog(
                parts: [intro, collect],
                celebrations: [
                    TestFixtures.makeCelebration(
                        id: "easter-sunday",
                        title: "Easter Sunday",
                        subtitle: "Resurrection joy.",
                        summary: "Easter proper texts celebrate the risen Christ.",
                        properTitle: "Easter Sunday Propers"
                    )
                ],
                dateIndex: [
                    LiturgicalDateIndex(date: "2026-04-05", celebrationID: "easter-sunday")
                ]
            )
        }
        let progress = MassModeProgress(
            dateKey: "2026-04-05",
            sectionID: "collect-readings",
            celebrationID: "easter-sunday",
            lastOpenedAt: TestFixtures.date("2026-04-05")
        )

        let model = AppModel(
            repository: repository,
            searchService: SpySearchService(),
            bookmarkStore: SpyBookmarkStore(),
            progressStore: SpyMassModeProgressStore(storedProgress: progress),
            now: { TestFixtures.date("2026-03-30") }
        )

        #expect(model.resumePreview?.partTitle == "Easter Sunday Propers")

        model.resumeMass()

        #expect(model.selectedDateKey == "2026-04-05")
        #expect(model.consumePendingGuideSectionID() == "collect-readings")
        #expect(model.consumePendingGuideSectionID() == nil)
        #expect(model.selectedCelebrationTitle == "Easter Sunday")
    }

    @MainActor
    @Test
    func recordMassProgressPersistsCurrentSection() throws {
        let intro = TestFixtures.makePart(id: "intro", order: 1, title: "Intro")
        let repository = StubMassContentRepository {
            TestFixtures.makeCatalog(parts: [intro])
        }
        let progressStore = SpyMassModeProgressStore()

        let model = AppModel(
            repository: repository,
            searchService: SpySearchService(),
            bookmarkStore: SpyBookmarkStore(),
            progressStore: progressStore,
            now: { TestFixtures.date("2026-03-30") }
        )

        let part = try #require(model.part(withID: "intro"))
        model.recordMassProgress(for: part)

        let saved = try #require(progressStore.saveCalls.last)
        #expect(saved.sectionID == "intro")
        #expect(saved.dateKey == "2026-03-30")
        #expect(model.progress == saved)
    }

    @MainActor
    @Test
    func selectingMassFormPersistsChoiceAndCarriesIntoProgressAndResume() throws {
        let intro = TestFixtures.makePart(
            id: "intro",
            order: 1,
            title: "Intro",
            formProfiles: [
                MassFormProfile(
                    massForm: .sung,
                    summary: nil,
                    liveNote: nil,
                    participationNote: "Listen for the sung opening.",
                    gestureCues: nil,
                    sourceIDs: ["chant"],
                    chantGuideIDs: ["chant-what-is-it"]
                )
            ]
        )
        let repository = StubMassContentRepository {
            TestFixtures.makeCatalog(parts: [intro])
        }
        let progressStore = SpyMassModeProgressStore()
        let massFormStore = SpyMassFormStore()

        let model = AppModel(
            repository: repository,
            searchService: SpySearchService(),
            bookmarkStore: SpyBookmarkStore(),
            progressStore: progressStore,
            massFormStore: massFormStore,
            now: { TestFixtures.date("2026-03-30") }
        )

        model.selectMassForm(MassForm.sung)
        let part = try #require(model.part(withID: "intro"))
        model.recordMassProgress(for: part)

        let saved = try #require(progressStore.saveCalls.last)
        #expect(model.selectedMassForm == MassForm.sung)
        #expect(model.selectedMassFormTitle == "Sung Mass")
        #expect(massFormStore.saveCalls == [MassForm.sung])
        #expect(saved.massForm == MassForm.sung)
        #expect(model.guideOrientation(for: part).massFormTitle == "Sung Mass")
        #expect(model.guideOrientation(for: part).participationNote == "Listen for the sung opening.")

        model.selectMassForm(MassForm.low)
        model.resumeMass()

        #expect(model.selectedMassForm == MassForm.sung)
        #expect(model.consumePendingGuideSectionID() == "intro")
    }

    @MainActor
    @Test
    func guideOrientationUsesPhaseLiveNoteAndUpcomingSection() throws {
        let intro = TestFixtures.makePart(
            id: "intro",
            order: 1,
            phase: .preparation,
            title: "Intro",
            liveNote: "Stay recollected at the start."
        )
        let canon = TestFixtures.makePart(
            id: "canon",
            order: 2,
            phase: .canon,
            title: "Canon",
            summary: "The central Eucharistic prayer."
        )
        let model = AppModel(
            repository: StubMassContentRepository {
                TestFixtures.makeCatalog(parts: [intro, canon])
            },
            searchService: SpySearchService(),
            bookmarkStore: SpyBookmarkStore(),
            progressStore: SpyMassModeProgressStore(),
            now: { TestFixtures.date("2026-03-30") }
        )

        let part = try #require(model.part(withID: "intro"))
        let orientation = model.guideOrientation(for: part)

        #expect(orientation.phaseTitle == "Preparation")
        #expect(orientation.positionText == "Section 1 of 2")
        #expect(orientation.liveNote == "Stay recollected at the start.")
        #expect(orientation.nextPartTitle == "Canon")
        #expect(orientation.nextPartSummary == "The central Eucharistic prayer.")
    }

    @MainActor
    @Test
    func loadCatalogFailureSetsErrorState() {
        let model = AppModel(
            repository: StubMassContentRepository {
                throw SampleTestError.loadFailed
            },
            searchService: SpySearchService(),
            bookmarkStore: SpyBookmarkStore(),
            progressStore: SpyMassModeProgressStore(),
            now: { TestFixtures.date("2026-03-30") }
        )

        #expect(model.errorMessage == "Sample load failure")
        #expect(model.orderedParts.isEmpty)
        #expect(model.sources.isEmpty)
        #expect(model.bookmarks.isEmpty)
        #expect(model.progress == nil)
    }
}
