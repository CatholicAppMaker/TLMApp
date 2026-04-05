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
        app.buttons["jump-to-collect-readings"].tap()

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

    func testLearnLinkOpensPronunciationContent() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-03-29")

        app.openGuide()
        app.buttons["jump-list-button"].tap()
        app.buttons["jump-to-collect-readings"].tap()
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

private extension XCUIApplication {
    func launchApp(resetState: Bool, todayOverride: String? = nil) {
        var arguments: [String] = []
        if resetState {
            arguments.append("-reset-app-state")
        }
        if let todayOverride {
            arguments.append(contentsOf: ["-today-override", todayOverride])
        }
        launchArguments = arguments
        launch()
    }

    func openGuide() {
        if tabBars.buttons["Guide"].exists {
            tabBars.buttons["Guide"].tap()
        }
    }

    func openLibrary() {
        tabBars.buttons["Library"].tap()
    }
}
