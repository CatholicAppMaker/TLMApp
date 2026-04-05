import Foundation
import Observation

@MainActor
@Observable
final class AppModel {
    private let repository: any MassContentRepository
    private let searchService: any SearchService
    private let bookmarkStore: any BookmarkStore
    private let progressStore: any MassModeProgressStore
    private let massFormStore: any MassFormStore
    private let appearanceStore: any AppAppearanceStore
    let calendar: Calendar
    let now: () -> Date

    private(set) var libraryTitle = ""
    private(set) var librarySubtitle = ""
    private(set) var coverageWindow: CoverageWindow?
    private(set) var ordinaryParts: [MassPart] = []
    private(set) var celebrations: [Celebration] = []
    private(set) var dateIndex: [LiturgicalDateIndex] = []
    private(set) var glossaryEntries: [GlossaryEntry] = []
    private(set) var pronunciationGuides: [PronunciationGuide] = []
    private(set) var participationGuides: [ParticipationGuide] = []
    private(set) var chantGuides: [ChantGuide] = []
    private(set) var sources: [SourceReference] = []
    private(set) var bookmarks: Set<String> = []
    private(set) var progress: MassModeProgress?
    private(set) var selectedDate: Date
    private(set) var selectedMassForm: MassForm
    private(set) var selectedAppearance: AppAppearance
    private(set) var preferredLibraryScope: LibraryScope = .allSections
    private(set) var focusedLearningDestination: LearnDestination?
    private(set) var errorMessage: String?
    private(set) var guideSelectionToken = UUID()

    private var pendingGuideSectionID: String?

    init(
        repository: any MassContentRepository,
        searchService: any SearchService,
        bookmarkStore: any BookmarkStore,
        progressStore: any MassModeProgressStore,
        massFormStore: any MassFormStore,
        appearanceStore: any AppAppearanceStore = UserDefaultsAppAppearanceStore(),
        now: @escaping () -> Date = Date.init,
        calendar: Calendar = .current
    ) {
        self.repository = repository
        self.searchService = searchService
        self.bookmarkStore = bookmarkStore
        self.progressStore = progressStore
        self.massFormStore = massFormStore
        self.appearanceStore = appearanceStore
        self.now = now
        self.calendar = calendar
        selectedDate = calendar.startOfDay(for: now())
        selectedMassForm = massFormStore.loadMassForm()
        selectedAppearance = appearanceStore.loadAppearance()
        loadCatalog()
    }
}

extension AppModel {
    func loadCatalog() {
        do {
            let catalog = try repository.loadCatalog()
            libraryTitle = catalog.title
            librarySubtitle = catalog.subtitle
            coverageWindow = catalog.coverageWindow
            ordinaryParts = catalog.parts.sorted { $0.order < $1.order }
            celebrations = catalog.celebrations
            dateIndex = catalog.dateIndex
            glossaryEntries = catalog.glossaryEntries
            pronunciationGuides = catalog.pronunciationGuides
            participationGuides = catalog.participationGuides
            chantGuides = catalog.chantGuides
            sources = catalog.sources
            bookmarks = bookmarkStore.loadBookmarks()
            progress = progressStore.loadProgress()
            selectedMassForm = massFormStore.loadMassForm()
            selectedAppearance = appearanceStore.loadAppearance()
            errorMessage = nil
        } catch {
            coverageWindow = nil
            ordinaryParts = []
            celebrations = []
            dateIndex = []
            glossaryEntries = []
            pronunciationGuides = []
            participationGuides = []
            chantGuides = []
            sources = []
            errorMessage = error.localizedDescription
        }
    }
}

extension AppModel {
    func selectDate(_ date: Date) {
        selectedDate = calendar.startOfDay(for: date)
    }

    func search(query: String, scope: LibraryScope) -> LibrarySearchResults {
        let source = scope == .allSections ? orderedParts : bookmarkedParts
        return searchService.search(
            query: query,
            in: source,
            learningContent: LearningContentIndex(
                glossaryEntries: glossaryEntries,
                pronunciationGuides: pronunciationGuides,
                participationGuides: participationGuides,
                chantGuides: chantGuides
            )
        )
    }

    func isBookmarked(_ part: ResolvedMassPart) -> Bool {
        bookmarks.contains(part.id)
    }

    func toggleBookmark(for part: ResolvedMassPart) {
        if bookmarks.contains(part.id) {
            bookmarks.remove(part.id)
        } else {
            bookmarks.insert(part.id)
        }

        bookmarkStore.saveBookmarks(bookmarks)
    }

    func part(withID id: String?) -> ResolvedMassPart? {
        guard let id else {
            return orderedParts.first
        }

        return orderedParts.first(where: { $0.id == id })
    }

    func part(before part: ResolvedMassPart) -> ResolvedMassPart? {
        guard let index = orderedParts.firstIndex(of: part), index > 0 else {
            return nil
        }

        return orderedParts[index - 1]
    }

    func part(after part: ResolvedMassPart) -> ResolvedMassPart? {
        guard let index = orderedParts.firstIndex(of: part), index < orderedParts.count - 1 else {
            return nil
        }

        return orderedParts[index + 1]
    }

    func displayIndex(for part: ResolvedMassPart) -> Int {
        orderedParts.firstIndex(of: part).map { $0 + 1 } ?? 1
    }
}

extension AppModel {
    func startGuide() {
        pendingGuideSectionID = nil
    }

    func resumeMass() {
        guard let savedProgressContext else {
            return
        }

        selectedDate = calendar.startOfDay(for: savedProgressContext.date)
        selectedMassForm = savedProgressContext.progress.massForm
        massFormStore.saveMassForm(savedProgressContext.progress.massForm)
        pendingGuideSectionID = savedProgressContext.progress.sectionID
        guideSelectionToken = UUID()
    }

    func consumePendingGuideSectionID() -> String? {
        defer { pendingGuideSectionID = nil }
        return pendingGuideSectionID
    }

    func recordMassProgress(for part: ResolvedMassPart) {
        let progress = MassModeProgress(
            dateKey: selectedDateKey,
            sectionID: part.id,
            celebrationID: currentCelebration?.id,
            massForm: selectedMassForm,
            lastOpenedAt: now()
        )
        self.progress = progress
        progressStore.saveProgress(progress)
    }

    func openGuideSection(_ sectionID: String) {
        pendingGuideSectionID = sectionID
        guideSelectionToken = UUID()
    }

    func canResumeSavedPlace(from sectionID: String?) -> Bool {
        guard let savedProgressContext else {
            return false
        }

        return !savedProgressMatchesCurrentSelection(
            sectionID: sectionID,
            dateKey: selectedDateKey,
            massForm: selectedMassForm,
            savedProgressContext: savedProgressContext
        )
    }

    func synchronizedGuideSelection(from currentSectionID: String?) -> GuideSelectionUpdate {
        if let pendingSectionID = consumePendingGuideSectionID(),
           part(withID: pendingSectionID) != nil
        {
            return GuideSelectionUpdate(sectionID: pendingSectionID, shouldRecordProgress: true)
        }

        if let currentSectionID,
           part(withID: currentSectionID) != nil
        {
            return GuideSelectionUpdate(sectionID: currentSectionID, shouldRecordProgress: true)
        }

        let firstPartID = orderedParts.first?.id
        return GuideSelectionUpdate(
            sectionID: firstPartID,
            shouldRecordProgress: !shouldPreserveResumePrompt(
                from: currentSectionID,
                fallbackSectionID: firstPartID
            )
        )
    }

    var currentGuideSectionID: String? {
        if let pendingGuideSectionID,
           part(withID: pendingGuideSectionID) != nil
        {
            return pendingGuideSectionID
        }

        if let progress,
           progress.dateKey == selectedDateKey,
           progress.massForm == selectedMassForm,
           part(withID: progress.sectionID) != nil
        {
            return progress.sectionID
        }

        return orderedParts.first?.id
    }
}

extension AppModel {
    func openLearn(_ destination: LearnDestination) {
        focusedLearningDestination = destination
    }

    func clearLearnFocus() {
        focusedLearningDestination = nil
    }

    func glossaryEntry(withID id: String) -> GlossaryEntry? {
        glossaryEntries.first(where: { $0.id == id })
    }

    func pronunciationGuide(withID id: String) -> PronunciationGuide? {
        pronunciationGuides.first(where: { $0.id == id })
    }

    func participationGuide(withID id: String) -> ParticipationGuide? {
        participationGuides.first(where: { $0.id == id })
    }

    func chantGuide(withID id: String) -> ChantGuide? {
        chantGuides.first(where: { $0.id == id })
    }
}

extension AppModel {
    var resolvedDay: ResolvedDay {
        resolveDay(for: selectedDate, massForm: selectedMassForm)
    }

    func coverageStatus(
        for date: Date,
        matchedCelebration: Celebration?
    ) -> CoverageStatus {
        guard let coverageWindow else {
            return matchedCelebration == nil ? .ordinaryOnlyWithinSupportedWindow : .properAvailable
        }

        guard
            let startDate = Self.storageDateFormatter.date(from: coverageWindow.startDate),
            let endDate = Self.storageDateFormatter.date(from: coverageWindow.endDate)
        else {
            return matchedCelebration == nil ? .ordinaryOnlyWithinSupportedWindow : .properAvailable
        }

        let normalizedDate = calendar.startOfDay(for: date)
        let normalizedStart = calendar.startOfDay(for: startDate)
        let normalizedEnd = calendar.startOfDay(for: endDate)

        if normalizedDate < normalizedStart || normalizedDate > normalizedEnd {
            return .outsideSupportedWindow
        }

        return matchedCelebration == nil ? .ordinaryOnlyWithinSupportedWindow : .properAvailable
    }
}

extension AppModel {
    static let storageDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale.current
        formatter.dateStyle = .full
        return formatter
    }()

    static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale.current
        formatter.dateStyle = .medium
        return formatter
    }()

    static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()
}

extension AppModel {
    func resetToToday() {
        selectDate(now())
    }

    func selectMassForm(_ massForm: MassForm) {
        guard selectedMassForm != massForm else {
            return
        }

        selectedMassForm = massForm
        massFormStore.saveMassForm(massForm)
    }

    func selectAppearance(_ appearance: AppAppearance) {
        guard selectedAppearance != appearance else {
            return
        }

        selectedAppearance = appearance
        appearanceStore.saveAppearance(appearance)
    }

    func setPreferredLibraryScope(_ scope: LibraryScope) {
        preferredLibraryScope = scope
    }

    func focusBookmarkedSections() {
        preferredLibraryScope = .bookmarks
    }

    func focusAllSections() {
        preferredLibraryScope = .allSections
    }

    private func shouldPreserveResumePrompt(
        from currentSectionID: String?,
        fallbackSectionID: String?
    ) -> Bool {
        guard
            currentSectionID == nil,
            let fallbackSectionID,
            let savedProgressContext
        else {
            return false
        }

        return !savedProgressMatchesCurrentSelection(
            sectionID: fallbackSectionID,
            dateKey: selectedDateKey,
            massForm: selectedMassForm,
            savedProgressContext: savedProgressContext
        )
    }

    private func savedProgressMatchesCurrentSelection(
        sectionID: String?,
        dateKey: String,
        massForm: MassForm,
        savedProgressContext: SavedProgressContext
    ) -> Bool {
        savedProgressContext.progress.sectionID == sectionID
            && savedProgressContext.progress.dateKey == dateKey
            && savedProgressContext.progress.massForm == massForm
    }
}
