import Foundation

enum AppRoute: Equatable {
    case guideToday
    case guideResume
    case guideSection(partID: String)
    case calendar(dateKey: String?)
    case librarySaved
}

extension AppRoute {
    init?(url: URL) {
        guard url.scheme == "latinmasscompanion" else {
            return nil
        }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let host = url.host ?? ""

        func queryValue(_ name: String) -> String? {
            components?.queryItems?.first(where: { $0.name == name })?.value
        }

        switch host {
        case "guide":
            if queryValue("resume") == "1" {
                self = .guideResume
            } else if let partID = queryValue("part") {
                self = .guideSection(partID: partID)
            } else {
                self = .guideToday
            }
        case "calendar":
            self = .calendar(dateKey: queryValue("date"))
        case "library":
            if queryValue("saved") == "1" {
                self = .librarySaved
            } else {
                return nil
            }
        default:
            return nil
        }
    }
}
