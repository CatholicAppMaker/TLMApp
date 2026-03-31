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
            "This date stays inside the bundled year, but the app only promises the fixed Ordinary."
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
            the supported year has no bundled proper texts.
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

struct GuideOrientation: Hashable, Sendable {
    let positionText: String
    let phaseTitle: String
    let massFormTitle: String
    let liveNote: String?
    let participationNote: String?
    let nextPartTitle: String?
    let nextPartSummary: String?
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
