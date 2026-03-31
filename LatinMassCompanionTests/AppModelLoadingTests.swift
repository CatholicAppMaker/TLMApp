@testable import LatinMassCompanion
import Testing

struct AppModelLoadingTests {
    @MainActor
    @Test
    func appModelLoadsTodayStateBookmarksAndProperResolution() {
        let intro = TestFixtures.makePart(id: "intro", order: 1, title: "Intro")
        let collect = TestFixtures.makePart(
            id: "collect-readings",
            order: 2,
            title: "Collect, Epistle, and Gradual",
            glossaryIDs: ["collect"],
            pronunciationIDs: ["et-cum-spiritu-tuo"]
        )
        let canon = TestFixtures.makePart(id: "canon", order: 3, title: "Canon")
        let palmSunday = TestFixtures.makeCelebration(
            id: "palm-sunday",
            title: "Palm Sunday",
            subtitle: "Holy Week begins.",
            summary: "Palm Sunday turns toward Christ's royal entry.",
            properTitle: "Palm Sunday Propers",
            properSummary: "The propers focus on Christ's entry into Jerusalem.",
            properTags: ["hosanna", "holy week"],
            properGlossaryIDs: ["collect"],
            properPronunciationIDs: ["et-cum-spiritu-tuo"]
        )
        let repository = StubMassContentRepository {
            TestFixtures.makeCatalog(
                parts: [canon, intro, collect],
                celebrations: [palmSunday],
                dateIndex: [
                    LiturgicalDateIndex(date: "2026-03-29", celebrationID: "palm-sunday")
                ]
            )
        }
        let bookmarkStore = SpyBookmarkStore(storedIDs: ["canon"])
        let progressStore = SpyMassModeProgressStore()

        let model = AppModel(
            repository: repository,
            searchService: SpySearchService(),
            bookmarkStore: bookmarkStore,
            progressStore: progressStore,
            now: { TestFixtures.date("2026-03-29") }
        )

        #expect(model.libraryTitle == "Test Library")
        #expect(model.librarySubtitle == "Sample subtitle")
        #expect(model.sources == TestFixtures.sources)
        #expect(model.coverageWindowTitle == "2026 Bundled Sunday and Feast Coverage")
        #expect(model.bookmarks == ["canon"])
        #expect(model.selectedCelebrationTitle == "Palm Sunday")
        #expect(model.isShowingOrdinaryOnly == false)
        #expect(model.isOutsideCoverageWindow == false)
        #expect(model.orderedParts.map(\.id) == ["intro", "collect-readings", "canon"])
        #expect(model.orderedParts[1].title == "Palm Sunday Propers")
        #expect(model.orderedParts[1].isProper == true)
        #expect(model.bookmarkedParts.map(\.id) == ["canon"])
    }

    @MainActor
    @Test
    func appModelSearchUsesRequestedScope() {
        let intro = TestFixtures.makePart(id: "intro", order: 1, title: "Intro")
        let canon = TestFixtures.makePart(id: "canon", order: 2, title: "Canon")
        let repository = StubMassContentRepository {
            TestFixtures.makeCatalog(parts: [canon, intro])
        }
        let searchService = SpySearchService()
        searchService.nextResults = LibrarySearchResults(
            parts: [ResolvedMassPart(part: canon, massForm: .low)],
            learningItems: [.glossary(TestFixtures.defaultGlossaryEntries[0])]
        )
        let bookmarkStore = SpyBookmarkStore(storedIDs: ["canon"])

        let model = AppModel(
            repository: repository,
            searchService: searchService,
            bookmarkStore: bookmarkStore,
            progressStore: SpyMassModeProgressStore(),
            now: { TestFixtures.date("2026-03-30") }
        )

        let results = model.search(query: "canon", scope: .bookmarks)

        #expect(results.parts.map(\.id) == ["canon"])
        #expect(results.learningItems.count == 1)
        #expect(searchService.capturedQuery == "canon")
        #expect(searchService.capturedPartIDs == ["canon"])
        #expect(searchService.capturedGlossaryIDs == TestFixtures.defaultGlossaryEntries.map(\.id))
        #expect(searchService.capturedPronunciationIDs == TestFixtures.defaultPronunciationGuides.map(\.id))
        #expect(searchService.capturedParticipationIDs == TestFixtures.defaultParticipationGuides.map(\.id))
        #expect(searchService.capturedChantIDs == TestFixtures.defaultChantGuides.map(\.id))
    }

    @MainActor
    @Test
    func toggleBookmarkDoesNotDisturbMassModeProgress() throws {
        let intro = TestFixtures.makePart(id: "intro", order: 1, title: "Intro")
        let repository = StubMassContentRepository {
            TestFixtures.makeCatalog(parts: [intro])
        }
        let progress = MassModeProgress(
            dateKey: "2026-03-29",
            sectionID: "intro",
            celebrationID: nil,
            lastOpenedAt: TestFixtures.date("2026-03-29")
        )
        let bookmarkStore = SpyBookmarkStore()
        let progressStore = SpyMassModeProgressStore(storedProgress: progress)

        let model = AppModel(
            repository: repository,
            searchService: SpySearchService(),
            bookmarkStore: bookmarkStore,
            progressStore: progressStore,
            now: { TestFixtures.date("2026-03-30") }
        )

        let part = try #require(model.part(withID: "intro"))
        model.toggleBookmark(for: part)

        #expect(model.bookmarks == ["intro"])
        #expect(bookmarkStore.saveCalls.last == ["intro"])
        #expect(model.progress == progress)
        #expect(progressStore.saveCalls.isEmpty)
    }

    @MainActor
    @Test
    func selectingSupportedInWindowAndOutOfWindowDatesUpdatesResolution() {
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
                        id: "christmas",
                        title: "Christmas Day",
                        subtitle: "The Nativity of the Lord.",
                        summary: "Christmas proper texts proclaim the Incarnation.",
                        properTitle: "Christmas Day Propers",
                        properSummary: "The Nativity shapes the proper texts.",
                        properTags: ["nativity", "christmas"]
                    )
                ],
                dateIndex: [
                    LiturgicalDateIndex(date: "2026-12-25", celebrationID: "christmas")
                ]
            )
        }

        let model = AppModel(
            repository: repository,
            searchService: SpySearchService(),
            bookmarkStore: SpyBookmarkStore(),
            progressStore: SpyMassModeProgressStore(),
            now: { TestFixtures.date("2026-03-30") }
        )

        #expect(model.selectedCelebrationTitle == "Ordinary of the Mass")
        #expect(model.isShowingOrdinaryOnly == true)
        #expect(model.isOutsideCoverageWindow == false)

        model.selectDate(TestFixtures.date("2026-12-25"))
        #expect(model.selectedCelebrationTitle == "Christmas Day")
        #expect(model.isShowingOrdinaryOnly == false)
        #expect(model.coverageTitle == "Proper Available")
        #expect(model.orderedParts[1].title == "Christmas Day Propers")

        model.selectDate(TestFixtures.date("2026-12-26"))
        #expect(model.selectedCelebrationTitle == "Ordinary of the Mass")
        #expect(model.isShowingOrdinaryOnly == true)
        #expect(model.isOutsideCoverageWindow == false)
        #expect(model.orderedParts[1].title == "Collect, Epistle, and Gradual")

        model.selectDate(TestFixtures.date("2027-01-03"))
        #expect(model.selectedCelebrationTitle == "Ordinary of the Mass")
        #expect(model.isOutsideCoverageWindow == true)
        #expect(model.coverageTitle == "Outside Coverage")
    }
}
