import Foundation
@testable import LatinMassCompanion
import Testing

struct LatinMassCompanionTests {
    @Test
    func bundledCatalogDecodesFromResources() throws {
        let repository = BundleMassContentRepository(bundle: Bundle.main)
        let catalog = try repository.loadCatalog()

        #expect(catalog.title == "Traditional Latin Mass Companion")
        #expect(catalog.coverageWindow.title == "2026 Bundled Sunday and Feast Coverage")
        #expect(catalog.parts.count == 14)
        #expect(catalog.celebrations.count == 63)
        #expect(catalog.dateIndex.count == 63)
        #expect(catalog.glossaryEntries.count == 5)
        #expect(catalog.pronunciationGuides.count == 4)
        #expect(catalog.participationGuides.count == 6)
        #expect(catalog.chantGuides.count == 3)
    }

    @Test
    func ordinaryPartsStayInLiturgicalOrder() throws {
        let repository = BundleMassContentRepository(bundle: Bundle.main)
        let parts = try repository.loadCatalog().parts.sorted { $0.order < $1.order }

        let orders = parts.map(\.order)
        #expect(orders == Array(1 ... 14))
        #expect(parts.first?.title == "Prayers at the Foot of the Altar")
    }

    @Test
    func bundledSearchMatchesOrdinaryProperExplanationAndLearningText() throws {
        let repository = BundleMassContentRepository(bundle: Bundle.main)
        let catalog = try repository.loadCatalog()
        let searchService = LocalMassSearchService()
        let ordinaryParts = catalog.parts
            .sorted { $0.order < $1.order }
            .map { ResolvedMassPart(part: $0, massForm: .low) }

        _ = try #require(catalog.parts.first(where: { $0.id == "collect-readings" }))
        let christmas = try #require(catalog.celebrations.first(where: { $0.id == "christmas" }))
        let entranceProper = try #require(christmas.properSections.first)
        let entrancePart = try #require(catalog.parts.first(where: { $0.id == entranceProper.replacesPartID }))
        let christmasProper = ResolvedMassPart(
            basePart: entrancePart,
            properSection: entranceProper,
            celebration: christmas,
            massForm: .low
        )
        let christmasParts = ordinaryParts.map { part in
            part.id == christmasProper.id ? christmasProper : part
        }
        let ordinaryResults = bundledSearch(
            "Et cum spiritu tuo",
            parts: ordinaryParts,
            catalog: catalog,
            searchService: searchService
        )
        let properResults = bundledSearch(
            "nativity",
            parts: christmasParts,
            catalog: catalog,
            searchService: searchService
        )
        let explanationResults = bundledSearch(
            "announces itself",
            parts: christmasParts,
            catalog: catalog,
            searchService: searchService
        )
        let learningResults = bundledSearch(
            "lord i am not worthy",
            parts: christmasParts,
            catalog: catalog,
            searchService: searchService
        )

        #expect(ordinaryResults.parts.contains(where: { $0.id == "collect-readings" }))
        #expect(properResults.parts.contains(where: { $0.id == entrancePart.id }))
        #expect(explanationResults.parts.contains(where: { $0.id == entrancePart.id }))
        #expect(learningResults.learningItems.contains(where: {
            if case let .pronunciation(guide) = $0 {
                return guide.id == "domine-non-sum-dignus"
            }
            return false
        }))
    }

    @Test
    func bundledCoverageWindowAndProperSourcesStayConsistent() throws {
        let repository = BundleMassContentRepository(bundle: Bundle.main)
        let catalog = try repository.loadCatalog()

        #expect(catalog.coverageWindow.startDate == "2026-01-01")
        #expect(catalog.coverageWindow.endDate == "2026-12-31")
        #expect(catalog.dateIndex.first?.date == "2026-01-01")
        #expect(catalog.dateIndex.last?.date == "2026-12-27")
        #expect(catalog.celebrations.allSatisfy { !$0.properSections.isEmpty })
        #expect(catalog.celebrations.allSatisfy { celebration in
            celebration.properSections.allSatisfy { !$0.sourceIDs.isEmpty }
        })
    }

    @Test
    func bookmarkStorePersistsIDs() throws {
        let suiteName = "LatinMassCompanionTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        let store = UserDefaultsBookmarkStore(defaults: defaults)

        store.saveBookmarks(["canon", "communion"])
        let loaded = store.loadBookmarks()

        #expect(loaded == Set(["canon", "communion"]))
        defaults.removePersistentDomain(forName: suiteName)
    }

    @Test
    func progressStorePersistsAndClearsState() throws {
        let suiteName = "LatinMassCompanionProgressTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        let store = UserDefaultsMassModeProgressStore(defaults: defaults)
        let progress = MassModeProgress(
            dateKey: "2026-04-05",
            sectionID: "collect-readings",
            celebrationID: "easter-sunday",
            lastOpenedAt: Date(timeIntervalSince1970: 0)
        )

        store.saveProgress(progress)
        #expect(store.loadProgress() == progress)

        store.clearProgress()
        #expect(store.loadProgress() == nil)
        defaults.removePersistentDomain(forName: suiteName)
    }
}

private func bundledSearch(
    _ query: String,
    parts: [ResolvedMassPart],
    catalog: MassCatalog,
    searchService: LocalMassSearchService
) -> LibrarySearchResults {
    searchService.search(
        query: query,
        in: parts,
        glossaryEntries: catalog.glossaryEntries,
        pronunciationGuides: catalog.pronunciationGuides,
        participationGuides: catalog.participationGuides,

        chantGuides: catalog.chantGuides
    )
}
