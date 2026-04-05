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
    private(set) var capturedChantIDs: [String] = []
    var nextResults = LibrarySearchResults(parts: [], learningItems: [])

    func search(
        query: String,
        in parts: [ResolvedMassPart],
        learningContent: LearningContentIndex
    ) -> LibrarySearchResults {
        capturedQuery = query
        capturedPartIDs = parts.map(\.id)
        capturedGlossaryIDs = learningContent.glossaryEntries.map(\.id)
        capturedPronunciationIDs = learningContent.pronunciationGuides.map(\.id)
        capturedParticipationIDs = learningContent.participationGuides.map(\.id)
        capturedChantIDs = learningContent.chantGuides.map(\.id)
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

final class SpyMassFormStore: MassFormStore {
    private(set) var storedMassForm: MassForm
    private(set) var saveCalls: [MassForm] = []

    init(storedMassForm: MassForm = .low) {
        self.storedMassForm = storedMassForm
    }

    func loadMassForm() -> MassForm {
        storedMassForm
    }

    func saveMassForm(_ massForm: MassForm) {
        storedMassForm = massForm
        saveCalls.append(massForm)
    }
}

final class SpyAppAppearanceStore: AppAppearanceStore {
    private(set) var storedAppearance: AppAppearance
    private(set) var saveCalls: [AppAppearance] = []

    init(storedAppearance: AppAppearance = .system) {
        self.storedAppearance = storedAppearance
    }

    func loadAppearance() -> AppAppearance {
        storedAppearance
    }

    func saveAppearance(_ appearance: AppAppearance) {
        storedAppearance = appearance
        saveCalls.append(appearance)
    }
}

actor SpySupportTipStorefront: SupportTipStorefront {
    var nextProducts: [SupportTipProduct] = []
    var nextPurchaseOutcome: SupportTipPurchaseOutcome = .success
    var fetchError: Error?
    var purchaseError: Error?
    private(set) var fetchedIDs: [[String]] = []
    private(set) var purchasedIDs: [String] = []

    func setNextProducts(_ products: [SupportTipProduct]) {
        nextProducts = products
    }

    func setNextPurchaseOutcome(_ outcome: SupportTipPurchaseOutcome) {
        nextPurchaseOutcome = outcome
    }

    func setFetchError(_ error: Error?) {
        fetchError = error
    }

    func setPurchaseError(_ error: Error?) {
        purchaseError = error
    }

    func fetchProducts(for ids: [String]) async throws -> [SupportTipProduct] {
        fetchedIDs.append(ids)

        if let fetchError {
            throw fetchError
        }

        return nextProducts
    }

    func purchase(productID: String) async throws -> SupportTipPurchaseOutcome {
        purchasedIDs.append(productID)

        if let purchaseError {
            throw purchaseError
        }

        return nextPurchaseOutcome
    }

    func fetchedRequestCount() -> Int {
        fetchedIDs.count
    }

    func purchasedProductIDs() -> [String] {
        purchasedIDs
    }
}

enum SampleTestError: LocalizedError {
    case loadFailed
    case purchaseFailed

    var errorDescription: String? {
        switch self {
        case .loadFailed:
            "Sample load failure"
        case .purchaseFailed:
            "Sample purchase failure"
        }
    }
}

final class TestBundleLocator {}

extension AppModel {
    convenience init(
        repository: any MassContentRepository,
        searchService: any SearchService,
        bookmarkStore: any BookmarkStore,
        progressStore: any MassModeProgressStore,
        appearanceStore: any AppAppearanceStore = SpyAppAppearanceStore(),
        now: @escaping () -> Date = Date.init
    ) {
        self.init(
            repository: repository,
            searchService: searchService,
            bookmarkStore: bookmarkStore,
            progressStore: progressStore,
            massFormStore: SpyMassFormStore(),
            appearanceStore: appearanceStore,
            now: now
        )
    }
}

extension MassModeProgress {
    init(
        dateKey: String,
        sectionID: String,
        celebrationID: String?,
        lastOpenedAt: Date
    ) {
        self.init(
            dateKey: dateKey,
            sectionID: sectionID,
            celebrationID: celebrationID,
            massForm: .low,
            lastOpenedAt: lastOpenedAt
        )
    }
}
