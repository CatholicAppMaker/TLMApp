import XCTest

@MainActor
final class LatinMassCompanionUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAppOpensOnTodayForCoveredDate() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-04-05")

        XCTAssertTrue(app.tabBars.buttons["Today"].exists)
        XCTAssertTrue(app.staticTexts["today-celebration-title"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["today-celebration-title"].label, "Easter Sunday")
        XCTAssertTrue(app.staticTexts["today-availability-summary"].label.contains("Bundled propers"))
    }

    func testBookmarkAppearsInLibraryBookmarks() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-03-30")

        app.openGuide()
        app.buttons["bookmark-button"].tap()
        app.openLibrary()
        app.buttons["Bookmarks"].tap()

        XCTAssertTrue(app.staticTexts["Prayers at the Foot of the Altar"].waitForExistence(timeout: 5))
    }

    func testLibrarySearchFindsProperSpecificTerm() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-12-25")

        app.openLibrary()

        let searchField = app.textFields["library-search-field"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("nativity")

        XCTAssertTrue(app.staticTexts["library-row-kyrie-gloria"].waitForExistence(timeout: 5))
    }

    func testLibrarySearchShowsLearningResultsSeparately() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-03-30")

        app.openLibrary()

        let searchField = app.textFields["library-search-field"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("first visit")

        XCTAssertTrue(app.staticTexts["Learning"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["How to Participate at a Low Mass"].waitForExistence(timeout: 5))
    }

    func testTodayFirstVisitButtonOpensFocusedLearnGuide() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-03-30")

        app.buttons["open-first-visit-guide-button"].tap()

        XCTAssertTrue(app.staticTexts["learn-participation-first-time-at-the-1962-mass"].waitForExistence(timeout: 5))
    }

    func testTodayWhatChangesButtonOpensChangesGuide() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-03-30")

        app.buttons["open-what-changes-button"].tap()

        XCTAssertTrue(app.staticTexts["learn-participation-what-changes-by-day"].waitForExistence(timeout: 5))
    }

    func testLibraryLearningResultOpensPronunciationGuide() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-03-30")

        app.openLibrary()

        let searchField = app.textFields["library-search-field"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("lord i am not worthy")

        let learningRow = app.buttons["library-learning-pronunciation-domine-non-sum-dignus"]
        XCTAssertTrue(learningRow.waitForExistence(timeout: 5))
        learningRow.tap()

        XCTAssertTrue(app.staticTexts["learn-pronunciation-domine-non-sum-dignus"].waitForExistence(timeout: 5))
    }

    func testLibrarySearchWithNoMatchesShowsEmptyState() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-03-30")

        app.openLibrary()

        let searchField = app.textFields["library-search-field"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("zzzxxyyqq")

        XCTAssertTrue(app.staticTexts["No Results"].waitForExistence(timeout: 5))
    }

    func testLibrarySearchFindsChantGuideSeparately() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-03-30")

        app.openLibrary()

        let searchField = app.textFields["library-search-field"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("gregorian chant")

        let learningRow = app.buttons["library-learning-chant-chant-what-is-it"]
        XCTAssertTrue(learningRow.waitForExistence(timeout: 5))
        learningRow.tap()

        XCTAssertTrue(app.staticTexts["learn-chant-chant-what-is-it"].waitForExistence(timeout: 5))
    }

    func testSelectingSungMassUpdatesGuideContextAndResumeState() {
        let firstLaunch = XCUIApplication()
        firstLaunch.launchApp(resetState: true, todayOverride: "2026-12-25")

        let sungButton = firstLaunch.segmentedControls.buttons["Sung Mass"]
        XCTAssertTrue(sungButton.waitForExistence(timeout: 5))
        sungButton.tap()

        firstLaunch.openGuide()
        XCTAssertTrue(firstLaunch.staticTexts["guide-form-pill"].waitForExistence(timeout: 5))
        XCTAssertEqual(firstLaunch.staticTexts["guide-form-pill"].label, "Sung Mass")
        firstLaunch.terminate()

        let resumedLaunch = XCUIApplication()
        resumedLaunch.launchApp(resetState: false, todayOverride: "2026-12-25")

        XCTAssertTrue(resumedLaunch.staticTexts["resume-mass-part-title"].waitForExistence(timeout: 5))

        resumedLaunch.buttons["resume-mass-button"].tap()
        XCTAssertTrue(resumedLaunch.staticTexts["guide-form-pill"].waitForExistence(timeout: 5))
        XCTAssertEqual(resumedLaunch.staticTexts["guide-form-pill"].label, "Sung Mass")
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
