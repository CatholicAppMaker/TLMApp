import XCTest

@MainActor
final class LatinMassCompanionFlowUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testGuideNavigationMovesForwardAndBack() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-03-30")

        app.openGuide()

        XCTAssertTrue(app.staticTexts["Prayers at the Foot of the Altar"].waitForExistence(timeout: 5))

        app.buttons["next-section"].tap()
        XCTAssertTrue(app.staticTexts["Confiteor and Absolution Prayers"].waitForExistence(timeout: 5))

        app.buttons["previous-section"].tap()
        XCTAssertTrue(app.staticTexts["Prayers at the Foot of the Altar"].waitForExistence(timeout: 5))
    }

    func testCoveredDateGuideShowsProperSection() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-12-25")

        app.openGuide()

        app.buttons["jump-list-button"].tap()
        app.buttons["jump-moment-collect-readings"].tap()

        let partTitle = app.staticTexts["mass-part-title"]
        XCTAssertTrue(partTitle.waitForExistence(timeout: 5))
        XCTAssertEqual(partTitle.label, "Christmas Day Collect, Epistle, and Gradual")
    }

    func testGuideJumpToMajorMomentNavigatesToCanon() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-03-30")

        app.openGuide()

        XCTAssertTrue(app.buttons["guide-major-moments-button"].waitForExistence(timeout: 5))
        app.buttons["guide-major-moments-button"].tap()
        app.swipeUp()
        let canonMoment = app.staticTexts["Canon"].firstMatch
        XCTAssertTrue(canonMoment.waitForExistence(timeout: 5))
        canonMoment.tap()

        let partTitle = app.staticTexts["mass-part-title"]
        XCTAssertTrue(partTitle.waitForExistence(timeout: 5))
        XCTAssertEqual(partTitle.label, "Canon of the Mass")
    }

    func testUncoveredDateShowsOrdinaryOnlyFallback() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-03-30")

        app.openLibrary()

        XCTAssertTrue(app.staticTexts["Ordinary of the Mass"].waitForExistence(timeout: 5))
    }

    func testLibraryBookmarksScopeShowsClearEmptyState() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-03-30")

        app.openLibrary()
        let scopeToggle = app.segmentedControls["library-scope-toggle"]
        XCTAssertTrue(scopeToggle.waitForExistence(timeout: 5))
        scopeToggle.buttons["Bookmarks"].tap()

        XCTAssertTrue(app.staticTexts["No Bookmarks Yet"].waitForExistence(timeout: 5))
    }

    func testLearnLinkOpensPronunciationContent() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-03-29")

        app.openGuide()
        app.buttons["jump-list-button"].tap()
        app.buttons["jump-moment-collect-readings"].tap()
        let partTitle = app.staticTexts["mass-part-title"]
        XCTAssertTrue(partTitle.waitForExistence(timeout: 5))
        XCTAssertEqual(partTitle.label, "Palm Sunday Collect, Epistle, and Gradual")

        app.buttons["Open learning note for Et cum spiritu tuo"].tap()

        XCTAssertTrue(app.staticTexts["learn-pronunciation-et-cum-spiritu-tuo"].waitForExistence(timeout: 5))
    }

    func testGuideShowsQuickGuidanceForOpeningSection() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-03-30")

        app.openGuide()

        XCTAssertTrue(app.staticTexts["Quick Follow"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Follow the broad movement first"].waitForExistence(timeout: 5))
    }

    func testFindMyPlaceNavigatesToCanon() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-03-30")

        app.openGuide()

        XCTAssertTrue(app.buttons["guide-find-my-place-button"].waitForExistence(timeout: 5))
        app.buttons["guide-find-my-place-button"].tap()

        let canonButton = app.buttons["find-place-canon"]
        XCTAssertTrue(canonButton.waitForExistence(timeout: 5))
        canonButton.tap()

        let partTitle = app.staticTexts["mass-part-title"]
        XCTAssertTrue(partTitle.waitForExistence(timeout: 5))
        XCTAssertEqual(partTitle.label, "Canon of the Mass")
    }

    func testResumeRestoresSavedCelebrationContextFromCalendarSelection() {
        let firstLaunch = XCUIApplication()
        firstLaunch.launchApp(resetState: true, todayOverride: "2026-03-30")

        firstLaunch.openCalendar()
        firstLaunch.swipeUp()
        let octaveDayRow = firstLaunch.buttons["calendar-row-2026-01-01"]
        XCTAssertTrue(octaveDayRow.waitForExistence(timeout: 5))
        octaveDayRow.tap()

        let openGuideButton = firstLaunch.buttons["calendar-open-guide-button"]
        XCTAssertTrue(openGuideButton.waitForExistence(timeout: 5))
        openGuideButton.tap()

        let collectCheckpoint = firstLaunch.buttons["timeline-checkpoint-collect-readings"]
        XCTAssertTrue(collectCheckpoint.waitForExistence(timeout: 5))
        collectCheckpoint.tap()

        let firstPartTitle = firstLaunch.staticTexts["mass-part-title"]
        XCTAssertTrue(firstPartTitle.waitForExistence(timeout: 5))
        XCTAssertEqual(firstPartTitle.label, "Octave Day of Christmas Collect, Epistle, and Gradual")
        firstLaunch.terminate()

        let resumedLaunch = XCUIApplication()
        resumedLaunch.launchApp(resetState: false, todayOverride: "2026-03-30")
        resumedLaunch.openGuide()

        let resumeButton = resumedLaunch.buttons["guide-resume-button"]
        let quickResumeButton = resumedLaunch.buttons["guide-resume-quick-button"]
        if resumeButton.waitForExistence(timeout: 2) {
            resumeButton.tap()
        } else if quickResumeButton.waitForExistence(timeout: 2) {
            quickResumeButton.tap()
        }

        let resumedPartTitle = resumedLaunch.staticTexts["mass-part-title"]
        XCTAssertTrue(resumedPartTitle.waitForExistence(timeout: 5))
        XCTAssertEqual(resumedPartTitle.label, "Octave Day of Christmas Collect, Epistle, and Gradual")
    }

    func testGuideNavigationReflectsBeginningAndEndBoundaries() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-03-30")

        app.openGuide()

        let previousButton = app.buttons["previous-section"]
        let nextButton = app.buttons["next-section"]

        XCTAssertFalse(previousButton.isEnabled)
        XCTAssertTrue(nextButton.isEnabled)

        var stepCount = 0
        while nextButton.isEnabled, stepCount < 20 {
            nextButton.tap()
            stepCount += 1
        }

        XCTAssertTrue(app.staticTexts["mass-part-title"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["mass-part-title"].label, "Postcommunion, Dismissal, and Last Gospel")
        XCTAssertTrue(previousButton.isEnabled)
        XCTAssertFalse(nextButton.isEnabled)
        XCTAssertEqual(stepCount, 13)
    }
}
