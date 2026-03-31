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
        glossaryEntries: [GlossaryEntry],
        pronunciationGuides: [PronunciationGuide],
        participationGuides: [ParticipationGuide],
        chantGuides: [ChantGuide]
    ) -> LibrarySearchResults {
        capturedQuery = query
        capturedPartIDs = parts.map(\.id)
        capturedGlossaryIDs = glossaryEntries.map(\.id)
        capturedPronunciationIDs = pronunciationGuides.map(\.id)
        capturedParticipationIDs = participationGuides.map(\.id)
        capturedChantIDs = chantGuides.map(\.id)
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

enum SampleTestError: LocalizedError {
    case loadFailed

    var errorDescription: String? {
        "Sample load failure"
    }
}

final class TestBundleLocator {}

extension AppModel {
    convenience init(
        repository: any MassContentRepository,
        searchService: any SearchService,
        bookmarkStore: any BookmarkStore,
        progressStore: any MassModeProgressStore,
        now: @escaping () -> Date = Date.init,
        calendar: Calendar = .current
    ) {
        self.init(
            repository: repository,
            searchService: searchService,
            bookmarkStore: bookmarkStore,
            progressStore: progressStore,
            massFormStore: SpyMassFormStore(),
            now: now,
            calendar: calendar
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
