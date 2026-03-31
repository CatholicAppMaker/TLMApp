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
    private let calendar: Calendar
    private let now: () -> Date

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
    private(set) var focusedLearningDestination: LearnDestination?
    private(set) var errorMessage: String?

    private var pendingGuideSectionID: String?

    init(
        repository: any MassContentRepository,
        searchService: any SearchService,
        bookmarkStore: any BookmarkStore,
        progressStore: any MassModeProgressStore,
        massFormStore: any MassFormStore,
        now: @escaping () -> Date = Date.init,
        calendar: Calendar = .current
    ) {
        self.repository = repository
        self.searchService = searchService
        self.bookmarkStore = bookmarkStore
        self.progressStore = progressStore
        self.massFormStore = massFormStore
        self.now = now
        self.calendar = calendar
        selectedDate = calendar.startOfDay(for: now())
        selectedMassForm = massFormStore.loadMassForm()
        loadCatalog()
    }

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

    func selectDate(_ date: Date) {
        selectedDate = calendar.startOfDay(for: date)
    }

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

    func search(query: String, scope: LibraryScope) -> LibrarySearchResults {
        let source = scope == .allSections ? orderedParts : bookmarkedParts
        return searchService.search(
            query: query,
            in: source,
            glossaryEntries: glossaryEntries,
            pronunciationGuides: pronunciationGuides,
            participationGuides: participationGuides,
            chantGuides: chantGuides
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

    func startGuide() {
        pendingGuideSectionID = nil
    }

    func resumeMass() {
        guard let progress, let date = Self.storageDateFormatter.date(from: progress.dateKey) else {
            return
        }

        selectedDate = date
        selectedMassForm = progress.massForm
        massFormStore.saveMassForm(progress.massForm)
        pendingGuideSectionID = progress.sectionID
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

    func sourceReferences(for part: ResolvedMassPart) -> [SourceReference] {
        let ids = Set(part.sourceReferenceIDs)
        return sources.filter { ids.contains($0.id) }.sorted { $0.title < $1.title }
    }

    func guideOrientation(for part: ResolvedMassPart) -> GuideOrientation {
        let upcomingPart = self.part(after: part)
        return GuideOrientation(
            positionText: "Section \(displayIndex(for: part)) of \(orderedParts.count)",
            phaseTitle: part.phase.title,
            massFormTitle: part.massForm.title,
            liveNote: part.liveNote,
            participationNote: part.participationNote,
            nextPartTitle: upcomingPart?.title,
            nextPartSummary: upcomingPart?.summary
        )
    }

    func chantGuides(for part: ResolvedMassPart) -> [ChantGuide] {
        let ids = Set(part.chantGuideIDs)
        return chantGuides.filter { ids.contains($0.id) }.sorted { $0.title < $1.title }
    }

    private var resolvedDay: ResolvedDay {
        resolveDay(for: selectedDate)
    }

    private func resolveDay(for date: Date) -> ResolvedDay {
        let dateKey = Self.storageDateFormatter.string(from: date)
        let celebrationByID = Dictionary(uniqueKeysWithValues: celebrations.map { ($0.id, $0) })
        let matchedCelebration = dateIndex
            .first(where: { $0.date == dateKey })
            .flatMap { celebrationByID[$0.celebrationID] }
        let coverageStatus = coverageStatus(for: date, matchedCelebration: matchedCelebration)

        let replacementLookup = Dictionary(
            uniqueKeysWithValues: matchedCelebration?.properSections.map { ($0.replacesPartID, $0) } ?? []
        )

        let parts = ordinaryParts.map { part in
            if let replacement = replacementLookup[part.id], let matchedCelebration {
                return ResolvedMassPart(
                    basePart: part,
                    properSection: replacement,
                    celebration: matchedCelebration,
                    massForm: selectedMassForm
                )
            }

            return ResolvedMassPart(part: part, massForm: selectedMassForm)
        }

        return ResolvedDay(
            date: date,
            celebration: matchedCelebration,
            parts: parts,
            coverageStatus: coverageStatus
        )
    }

    private func coverageStatus(
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

    private static let storageDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale.current
        formatter.dateStyle = .full
        return formatter
    }()

    private static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale.current
        formatter.dateStyle = .medium
        return formatter
    }()

    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()
}

extension AppModel {
    var orderedParts: [ResolvedMassPart] {
        resolvedDay.parts
    }

    var bookmarkedParts: [ResolvedMassPart] {
        orderedParts.filter { bookmarks.contains($0.id) }
    }

    var selectedDateKey: String {
        Self.storageDateFormatter.string(from: selectedDate)
    }

    var selectedDateTitle: String {
        Self.displayDateFormatter.string(from: selectedDate)
    }

    var selectedMassFormTitle: String {
        selectedMassForm.title
    }

    var selectedMassFormSubtitle: String {
        selectedMassForm.subtitle
    }

    var isShowingOrdinaryOnly: Bool {
        resolvedDay.isOrdinaryOnly
    }

    var isOutsideCoverageWindow: Bool {
        resolvedDay.coverageStatus == .outsideSupportedWindow
    }

    var selectedCelebrationTitle: String {
        resolvedDay.title
    }

    var selectedCelebrationSubtitle: String {
        resolvedDay.subtitle
    }

    var selectedCelebrationSummary: String {
        resolvedDay.summary
    }

    var availabilitySummary: String {
        switch resolvedDay.coverageStatus {
        case .properAvailable:
            """
            Bundled propers and form-aware guidance are available for this celebration within the app's stated 2026 scope.
            """
        case .ordinaryOnlyWithinSupportedWindow:
            """
            This date is inside the supported year window, but no bundled propers are included for it.
            The Ordinary remains fully available without guessing missing texts.
            """
        case .outsideSupportedWindow:
            """
            This date is outside the bundled year window.
            The app falls back to the fixed Ordinary of the Mass and does not invent missing propers.
            """
        }
    }

    var expectationSummary: String {
        switch selectedMassForm {
        case .low:
            """
            Follow the quieter structure of Low Mass first.
            If you lose your place, rejoin using the posture cues,
            section titles, and the broad movement of the rite.
            """
        case .sung:
            """
            Expect slower ceremonial pacing, sung Ordinary parts,
            and stronger chant cues. The guide keeps the same
            structure while pointing out where sung elements
            change the live experience.
            """
        }
    }

    var coverageTitle: String {
        resolvedDay.coverageStatus.title
    }

    var coverageSummary: String {
        resolvedDay.coverageStatus.summary(
            coverageWindowTitle: coverageWindow?.title,
            coverageDescription: coverageWindow?.description
        )
    }

    var coverageWindowTitle: String {
        coverageWindow?.title ?? "Bundled Coverage"
    }

    var coverageWindowDescription: String {
        coverageWindow?.description ?? ""
    }

    var coverageWindowDateText: String {
        guard let coverageWindow else {
            return ""
        }

        guard
            let startDate = Self.storageDateFormatter.date(from: coverageWindow.startDate),
            let endDate = Self.storageDateFormatter.date(from: coverageWindow.endDate)
        else {
            return "\(coverageWindow.startDate) to \(coverageWindow.endDate)"
        }

        return """
        \(Self.shortDateFormatter.string(from: startDate))
        to
        \(Self.shortDateFormatter.string(from: endDate))
        """
        .replacingOccurrences(of: "\n", with: " ")
    }

    var guideHeaderTitle: String {
        resolvedDay.title
    }

    var guideHeaderSubtitle: String {
        let formText = selectedMassForm.title

        return switch resolvedDay.coverageStatus {
        case .properAvailable:
            "\(selectedDateTitle) • \(formText) • \(resolvedDay.subtitle)"
        case .ordinaryOnlyWithinSupportedWindow:
            "\(selectedDateTitle) • \(formText) • Ordinary only"
        case .outsideSupportedWindow:
            "\(selectedDateTitle) • \(formText) • Outside bundled coverage"
        }
    }

    var currentCelebration: Celebration? {
        resolvedDay.celebration
    }

    var resumePreview: ResumePreview? {
        guard let progress, let date = Self.storageDateFormatter.date(from: progress.dateKey) else {
            return nil
        }

        let selectedMassForm = progress.massForm
        let resolvedDay = resolveDay(for: date, massForm: selectedMassForm)
        guard let part = resolvedDay.parts.first(where: { $0.id == progress.sectionID }) else {
            return nil
        }

        return ResumePreview(
            partTitle: part.title,
            celebrationTitle: resolvedDay.title,
            dateText: Self.displayDateFormatter.string(from: date),
            massFormTitle: selectedMassForm.title,
            lastOpenedText: Self.relativeFormatter.localizedString(
                for: progress.lastOpenedAt,
                relativeTo: now()
            )
        )
    }

    private func resolveDay(for date: Date, massForm: MassForm) -> ResolvedDay {
        let dateKey = Self.storageDateFormatter.string(from: date)
        let celebrationByID = Dictionary(uniqueKeysWithValues: celebrations.map { ($0.id, $0) })
        let matchedCelebration = dateIndex
            .first(where: { $0.date == dateKey })
            .flatMap { celebrationByID[$0.celebrationID] }
        let coverageStatus = coverageStatus(for: date, matchedCelebration: matchedCelebration)

        let replacementLookup = Dictionary(
            uniqueKeysWithValues: matchedCelebration?.properSections.map { ($0.replacesPartID, $0) } ?? []
        )

        let parts = ordinaryParts.map { part in
            if let replacement = replacementLookup[part.id], let matchedCelebration {
                return ResolvedMassPart(
                    basePart: part,
                    properSection: replacement,
                    celebration: matchedCelebration,
                    massForm: massForm
                )
            }

            return ResolvedMassPart(part: part, massForm: massForm)
        }

        return ResolvedDay(
            date: date,
            celebration: matchedCelebration,
            parts: parts,
            coverageStatus: coverageStatus
        )
    }
}
