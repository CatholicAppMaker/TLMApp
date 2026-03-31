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

        XCTAssertEqual(app.staticTexts["today-celebration-title"].label, "Christmas Day")
        app.openGuide()

        app.buttons["jump-list-button"].tap()
        app.buttons["jump-to-collect-readings"].tap()

        let partTitle = app.staticTexts["mass-part-title"]
        XCTAssertTrue(partTitle.waitForExistence(timeout: 5))
        XCTAssertEqual(partTitle.label, "Christmas Day Collect, Epistle, and Gradual")
    }

    func testUncoveredDateShowsOrdinaryOnlyFallback() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-03-30")

        XCTAssertEqual(app.staticTexts["today-celebration-title"].label, "Ordinary of the Mass")
        XCTAssertTrue(app.staticTexts["today-availability-summary"].label.contains("The Ordinary remains fully available"))
    }

    func testOutsideCoverageDateShowsOutsideWindowState() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2027-01-03")

        XCTAssertEqual(app.staticTexts["today-celebration-title"].label, "Ordinary of the Mass")
        XCTAssertEqual(app.staticTexts["today-coverage-title"].label, "Outside Coverage")
        XCTAssertTrue(app.staticTexts["today-availability-summary"].label.contains("outside the bundled year window"))
    }

    func testResumeMassRestoresLastSection() {
        let firstLaunch = XCUIApplication()
        firstLaunch.launchApp(resetState: true, todayOverride: "2026-04-05")
        firstLaunch.openGuide()
        firstLaunch.buttons["jump-list-button"].tap()
        firstLaunch.buttons["jump-to-collect-readings"].tap()
        let firstPartTitle = firstLaunch.staticTexts["mass-part-title"]
        XCTAssertTrue(firstPartTitle.waitForExistence(timeout: 5))
        XCTAssertEqual(firstPartTitle.label, "Easter Sunday Collect, Epistle, and Gradual")
        firstLaunch.terminate()

        let resumedLaunch = XCUIApplication()
        resumedLaunch.launchApp(resetState: false, todayOverride: "2026-04-05")

        XCTAssertTrue(resumedLaunch.staticTexts["resume-mass-part-title"].waitForExistence(timeout: 5))
        XCTAssertEqual(
            resumedLaunch.staticTexts["resume-mass-part-title"].label,
            "Easter Sunday Collect, Epistle, and Gradual"
        )

        resumedLaunch.buttons["resume-mass-button"].tap()
        let resumedPartTitle = resumedLaunch.staticTexts["mass-part-title"]
        XCTAssertTrue(resumedPartTitle.waitForExistence(timeout: 5))
        XCTAssertEqual(resumedPartTitle.label, "Easter Sunday Collect, Epistle, and Gradual")
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

    func testGuideShowsOrientationMetadata() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-03-30")

        app.openGuide()

        XCTAssertTrue(app.staticTexts["guide-phase-pill"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["guide-phase-pill"].label, "Preparation")
        XCTAssertTrue(app.staticTexts["guide-position-pill"].label.contains("Section 1 of"))
        XCTAssertEqual(app.staticTexts["guide-next-part-title"].label, "Confiteor and Absolution Prayers")
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

    func testSourcesScreenShowsBundledReferences() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-03-30")

        app.buttons["view-sources-button"].tap()

        XCTAssertTrue(app.staticTexts["2026 Bundled Sunday and Feast Coverage"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Missale Romanum (1962), Ordinary of the Mass"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Public-domain English hand missal translations"].waitForExistence(timeout: 5))
    }

    func testResetAppStateLaunchArgumentClearsPersistedState() {
        let firstLaunch = XCUIApplication()
        firstLaunch.launchApp(resetState: true, todayOverride: "2026-03-30")
        firstLaunch.openGuide()
        firstLaunch.buttons["bookmark-button"].tap()
        firstLaunch.buttons["next-section"].tap()
        firstLaunch.terminate()

        let persistedLaunch = XCUIApplication()
        persistedLaunch.launchApp(resetState: false, todayOverride: "2026-03-30")
        XCTAssertTrue(persistedLaunch.staticTexts["resume-mass-part-title"].waitForExistence(timeout: 5))
        persistedLaunch.openLibrary()
        persistedLaunch.buttons["Bookmarks"].tap()
        XCTAssertTrue(persistedLaunch.staticTexts["Prayers at the Foot of the Altar"].waitForExistence(timeout: 5))
        persistedLaunch.terminate()

        let resetLaunch = XCUIApplication()
        resetLaunch.launchApp(resetState: true, todayOverride: "2026-03-30")
        resetLaunch.openLibrary()
        resetLaunch.buttons["Bookmarks"].tap()
        XCTAssertTrue(resetLaunch.staticTexts["No Results"].waitForExistence(timeout: 5))
        XCTAssertFalse(resetLaunch.staticTexts["resume-mass-part-title"].exists)
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
        buttons["open-guide-button"].tap()
    }

    func openLibrary() {
        tabBars.buttons["Library"].tap()
    }
}
