import Foundation
@testable import LatinMassCompanion
import Testing

struct AppRouteTests {
    @Test
    func parsesGuideResumeRoute() {
        let route = AppRoute(url: URL(string: "latinmasscompanion://guide?resume=1")!)
        #expect(route == .guideResume)
    }

    @Test
    func parsesCalendarRouteWithDate() {
        let route = AppRoute(url: URL(string: "latinmasscompanion://calendar?date=2026-12-25")!)
        #expect(route == .calendar(dateKey: "2026-12-25"))
    }

    @Test
    func parsesLibrarySavedRoute() {
        let route = AppRoute(url: URL(string: "latinmasscompanion://library?saved=1")!)
        #expect(route == .librarySaved)
    }
}
