import Foundation
import Observation

@MainActor
@Observable
final class AppModel {
    private let repository: any MassContentRepository
    private let searchService: any SearchService
    private let bookmarkStore: any BookmarkStore
    private let progressStore: any MassModeProgressStore
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
    private(set) var sources: [SourceReference] = []
    private(set) var bookmarks: Set<String> = []
    private(set) var progress: MassModeProgress?
    private(set) var selectedDate: Date
    private(set) var focusedLearningDestination: LearnDestination?
    private(set) var errorMessage: String?

    private var pendingGuideSectionID: String?

    init(
        repository: any MassContentRepository,
        searchService: any SearchService,
        bookmarkStore: any BookmarkStore,
        progressStore: any MassModeProgressStore,
        now: @escaping () -> Date = Date.init,
        calendar: Calendar = .current
    ) {
        self.repository = repository
        self.searchService = searchService
        self.bookmarkStore = bookmarkStore
        self.progressStore = progressStore
        self.now = now
        self.calendar = calendar
        selectedDate = calendar.startOfDay(for: now())
        loadCatalog()
    }

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
            "Bundled propers and date-specific guidance are available for this celebration."
        case .ordinaryOnlyWithinSupportedWindow:
            "This date is inside the supported year window, but no bundled propers are included for it. The Ordinary of the Mass remains fully available."
        case .outsideSupportedWindow:
            "This date is outside the bundled year window. The app falls back to the fixed Ordinary of the Mass without guessing missing propers."
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

        return "\(Self.shortDateFormatter.string(from: startDate)) to \(Self.shortDateFormatter.string(from: endDate))"
    }

    var guideHeaderTitle: String {
        resolvedDay.title
    }

    var guideHeaderSubtitle: String {
        switch resolvedDay.coverageStatus {
        case .properAvailable:
            "\(selectedDateTitle) • \(resolvedDay.subtitle)"
        case .ordinaryOnlyWithinSupportedWindow:
            "\(selectedDateTitle) • Ordinary only"
        case .outsideSupportedWindow:
            "\(selectedDateTitle) • Outside bundled coverage"
        }
    }

    var currentCelebration: Celebration? {
        resolvedDay.celebration
    }

    var resumePreview: ResumePreview? {
        guard let progress, let date = Self.storageDateFormatter.date(from: progress.dateKey) else {
            return nil
        }

        let resolvedDay = resolveDay(for: date)
        guard let part = resolvedDay.parts.first(where: { $0.id == progress.sectionID }) else {
            return nil
        }

        return ResumePreview(
            partTitle: part.title,
            celebrationTitle: resolvedDay.title,
            dateText: Self.displayDateFormatter.string(from: date),
            lastOpenedText: Self.relativeFormatter.localizedString(for: progress.lastOpenedAt, relativeTo: now())
        )
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
            sources = catalog.sources
            bookmarks = bookmarkStore.loadBookmarks()
            progress = progressStore.loadProgress()
            errorMessage = nil
        } catch {
            coverageWindow = nil
            errorMessage = error.localizedDescription
        }
    }

    func selectDate(_ date: Date) {
        selectedDate = calendar.startOfDay(for: date)
    }

    func resetToToday() {
        selectDate(now())
    }

    func search(query: String, scope: LibraryScope) -> LibrarySearchResults {
        let source = scope == .allSections ? orderedParts : bookmarkedParts
        return searchService.search(
            query: query,
            in: source,
            glossaryEntries: glossaryEntries,
            pronunciationGuides: pronunciationGuides,
            participationGuides: participationGuides
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

    func sourceReferences(for part: ResolvedMassPart) -> [SourceReference] {
        let ids = Set(part.sourceReferenceIDs)
        return sources.filter { ids.contains($0.id) }.sorted { $0.title < $1.title }
    }

    func guideOrientation(for part: ResolvedMassPart) -> GuideOrientation {
        let upcomingPart = self.part(after: part)
        return GuideOrientation(
            positionText: "Section \(displayIndex(for: part)) of \(orderedParts.count)",
            phaseTitle: part.phase.title,
            liveNote: part.liveNote,
            nextPartTitle: upcomingPart?.title,
            nextPartSummary: upcomingPart?.summary
        )
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
                return ResolvedMassPart(basePart: part, properSection: replacement, celebration: matchedCelebration)
            }

            return ResolvedMassPart(part: part)
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

private struct ResolvedDay {
    let date: Date
    let celebration: Celebration?
    let parts: [ResolvedMassPart]
    let coverageStatus: CoverageStatus

    var isOrdinaryOnly: Bool {
        celebration == nil
    }

    var title: String {
        switch coverageStatus {
        case .properAvailable:
            celebration?.title ?? "Ordinary of the Mass"
        case .ordinaryOnlyWithinSupportedWindow, .outsideSupportedWindow:
            "Ordinary of the Mass"
        }
    }

    var subtitle: String {
        switch coverageStatus {
        case .properAvailable:
            celebration?.subtitle ?? "Bundled propers are available."
        case .ordinaryOnlyWithinSupportedWindow:
            "No bundled propers are available for this covered date."
        case .outsideSupportedWindow:
            "Outside the bundled coverage window for date-specific propers."
        }
    }

    var summary: String {
        switch coverageStatus {
        case .properAvailable:
            celebration?.summary ?? "The fixed Ordinary of the Mass remains available."
        case .ordinaryOnlyWithinSupportedWindow:
            "The fixed Ordinary of the Mass remains available even when a selected day in the supported year has no bundled proper texts."
        case .outsideSupportedWindow:
            "The app keeps the full Ordinary available outside the supported year window, but it does not synthesize missing propers."
        }
    }
}

struct ResumePreview: Hashable, Sendable {
    let partTitle: String
    let celebrationTitle: String
    let dateText: String
    let lastOpenedText: String
}

struct GuideOrientation: Hashable, Sendable {
    let positionText: String
    let phaseTitle: String
    let liveNote: String?
    let nextPartTitle: String?
    let nextPartSummary: String?
}

private enum CoverageStatus: Hashable, Sendable {
    case properAvailable
    case ordinaryOnlyWithinSupportedWindow
    case outsideSupportedWindow

    var title: String {
        switch self {
        case .properAvailable:
            "Proper Available"
        case .ordinaryOnlyWithinSupportedWindow:
            "Ordinary Only"
        case .outsideSupportedWindow:
            "Outside Coverage"
        }
    }

    func summary(
        coverageWindowTitle: String?,
        coverageDescription: String?
    ) -> String {
        switch self {
        case .properAvailable:
            "This date is covered by the bundled calendar and includes proper-backed guidance for the selected celebration."
        case .ordinaryOnlyWithinSupportedWindow:
            "This date falls inside \(coverageWindowTitle ?? "the bundled coverage window"), but only the fixed Ordinary is available. \(coverageDescription ?? "")"
        case .outsideSupportedWindow:
            "This date is outside \(coverageWindowTitle ?? "the bundled coverage window"). The app keeps the Ordinary available and avoids inventing missing proper texts."
        }
    }
}

enum LibraryScope: String, CaseIterable, Identifiable {
    case allSections
    case bookmarks

    var id: Self {
        self
    }

    var title: String {
        switch self {
        case .allSections:
            "All Sections"
        case .bookmarks:
            "Bookmarks"
        }
    }
}
