import Foundation

struct ResolvedDay {
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
            celebration?.subtitle ?? "Bundled propers and Ordinary guidance are available."
        case .ordinaryOnlyWithinSupportedWindow:
            "This date stays inside the bundled year, but the app only promises the fixed Ordinary and refuses to guess missing propers."
        case .outsideSupportedWindow:
            "Outside the bundled year of date-specific propers."
        }
    }

    var summary: String {
        switch coverageStatus {
        case .properAvailable:
            celebration?.summary ?? "The fixed Ordinary remains available alongside the day-specific propers."
        case .ordinaryOnlyWithinSupportedWindow:
            """
            The app keeps the fixed Ordinary available even when a selected date inside
            the supported year has no bundled proper texts. That restraint is deliberate.
            """
        case .outsideSupportedWindow:
            """
            The app keeps the full Ordinary available outside the supported year,
            but it does not synthesize missing propers or pretend to cover every date.
            """
        }
    }
}

struct ResumePreview: Hashable, Sendable {
    let partTitle: String
    let celebrationTitle: String
    let dateText: String
    let massFormTitle: String
    let lastOpenedText: String
}

struct SavedProgressContext: Sendable {
    let progress: MassModeProgress
    let date: Date
    let resolvedDay: ResolvedDay
    let part: ResolvedMassPart
}

struct GuideSelectionUpdate: Hashable, Sendable {
    let sectionID: String?
    let shouldRecordProgress: Bool
}

struct GuideOrientation: Hashable, Sendable {
    let positionText: String
    let phaseTitle: String
    let massFormTitle: String
    let liveNote: String?
    let participationNote: String?
    let nextPartTitle: String?
    let nextPartSummary: String?
}

struct MajorMomentAnchor: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let summary: String
    let partID: String
}

enum RiteTimelineCheckpointState: Hashable, Sendable {
    case completed
    case current
    case upcoming
}

struct RiteTimelineCheckpoint: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let summary: String
    let partID: String
    let phaseTitle: String
    let state: RiteTimelineCheckpointState
}

struct FindMyPlaceAnchor: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let summary: String
    let partID: String
}

struct CelebrationListing: Identifiable, Hashable, Sendable {
    let date: Date
    let dateKey: String
    let title: String
    let subtitle: String
    let summary: String
    let rank: String
    let celebrationID: String
    let coverageStatus: CoverageStatus
    let monthTitle: String
    let shortDateText: String
    let longDateText: String

    var id: String {
        dateKey
    }

    var coverageBadgeTitle: String {
        coverageStatus.calendarBadgeTitle
    }

    func matches(_ query: String) -> Bool {
        let normalized = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalized.isEmpty else {
            return true
        }

        let haystack = [title, subtitle, summary, rank, shortDateText, longDateText, monthTitle]
            .joined(separator: " ")
            .lowercased()

        return haystack.contains(normalized)
    }
}

struct CelebrationMonthSection: Identifiable, Hashable, Sendable {
    let title: String
    let listings: [CelebrationListing]

    var id: String {
        title
    }
}

enum CoverageStatus: Hashable, Sendable {
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

    var calendarBadgeTitle: String {
        switch self {
        case .properAvailable:
            "Proper Texts"
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
            """
            This date is covered by the bundled calendar and includes proper-backed guidance
            for the selected celebration within the app's stated scope.
            """
        case .ordinaryOnlyWithinSupportedWindow:
            """
            This date falls inside \(coverageWindowTitle ?? "the bundled coverage window"),
            but only the fixed Ordinary is available. \(coverageDescription ?? "")
            """
        case .outsideSupportedWindow:
            """
            This date is outside \(coverageWindowTitle ?? "the bundled coverage window").
            The app keeps the Ordinary available and avoids inventing missing proper texts.
            """
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
