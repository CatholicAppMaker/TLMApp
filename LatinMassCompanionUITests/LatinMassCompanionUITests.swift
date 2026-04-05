import XCTest

@MainActor
final class LatinMassCompanionUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAppOpensOnGuideWithSimplifiedNavigation() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-04-05")

        XCTAssertTrue(app.tabBars.buttons["Guide"].exists)
        XCTAssertTrue(app.tabBars.buttons["Calendar"].exists)
        XCTAssertTrue(app.tabBars.buttons["Library"].exists)
        XCTAssertTrue(app.tabBars.buttons["Learn"].exists)
        XCTAssertTrue(app.staticTexts["guide-utility-title"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["mass-part-title"].waitForExistence(timeout: 5))
    }

    func testCalendarSelectionUpdatesGuideContext() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-03-30")

        app.openCalendar()
        app.swipeUp()

        let octaveDayRow = app.buttons["calendar-row-2026-01-01"]
        XCTAssertTrue(octaveDayRow.waitForExistence(timeout: 5))
        octaveDayRow.tap()

        let openGuideButton = app.buttons["calendar-open-guide-button"]
        XCTAssertTrue(openGuideButton.waitForExistence(timeout: 5))
        openGuideButton.tap()

        app.buttons["jump-list-button"].tap()
        app.buttons["jump-moment-collect-readings"].tap()

        let partTitle = app.staticTexts["mass-part-title"]
        XCTAssertTrue(partTitle.waitForExistence(timeout: 5))
        XCTAssertEqual(partTitle.label, "Octave Day of Christmas Collect, Epistle, and Gradual")
    }

    func testBookmarkAppearsInLibraryBookmarks() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-03-30")

        app.openGuide()
        app.buttons["bookmark-button"].tap()
        app.openLibrary()

        XCTAssertTrue(app.buttons["library-saved-sections-button"].waitForExistence(timeout: 5))
        app.buttons["library-saved-sections-button"].tap()
        XCTAssertTrue(app.buttons["Show All Sections"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.segmentedControls.buttons["Bookmarks"].isSelected)
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

    func testLearnShowsWhatChangesGuide() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-03-30")

        app.tabBars.buttons["Learn"].tap()

        XCTAssertTrue(app.staticTexts["learn-participation-what-changes-by-day"].waitForExistence(timeout: 5))
    }

    func testLearnShowsFirstTimeOrientationGuide() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-03-30")

        app.tabBars.buttons["Learn"].tap()

        XCTAssertTrue(app.staticTexts["learn-participation-first-time-at-the-1962-mass"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["learn-participation-history-and-context"].exists)
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

    func testSelectingSungMassUpdatesGuideContextAndPersistsAcrossRelaunch() {
        let firstLaunch = XCUIApplication()
        firstLaunch.launchApp(resetState: true, todayOverride: "2026-12-25")

        let massFormToggle = firstLaunch.segmentedControls["guide-mass-form-toggle"]
        XCTAssertTrue(massFormToggle.waitForExistence(timeout: 5))
        massFormToggle.buttons["Sung Mass"].tap()

        XCTAssertTrue(firstLaunch.staticTexts["guide-form-pill"].waitForExistence(timeout: 5))
        XCTAssertEqual(firstLaunch.staticTexts["guide-form-pill"].label, "Sung Mass")
        firstLaunch.terminate()

        let resumedLaunch = XCUIApplication()
        resumedLaunch.launchApp(resetState: false, todayOverride: "2026-12-25")

        XCTAssertTrue(resumedLaunch.staticTexts["guide-form-pill"].waitForExistence(timeout: 5))
        XCTAssertEqual(resumedLaunch.staticTexts["guide-form-pill"].label, "Sung Mass")
    }

    func testLibraryMassFormToggleUpdatesGuideContext() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-03-30")

        app.openLibrary()

        let libraryMassFormToggle = app.segmentedControls["library-mass-form-toggle"]
        XCTAssertTrue(libraryMassFormToggle.waitForExistence(timeout: 5))
        libraryMassFormToggle.buttons["Sung Mass"].tap()

        app.openGuide()

        XCTAssertTrue(app.staticTexts["guide-form-pill"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["guide-form-pill"].label, "Sung Mass")
    }

    func testLearnTabStillShowsSourceAnchoredGuidance() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-03-30")

        app.tabBars.buttons["Learn"].tap()

        XCTAssertTrue(app.staticTexts["Learn the Rite, Keep the Prayer"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Gregorian Chant"].exists)
    }

    func testPrimaryCardsStayClearOfNavigationAndTabChrome() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-03-30")

        app.openGuide()
        assertContentIsClearOfChrome(
            app.staticTexts["guide-utility-title"],
            in: app
        )

        app.openCalendar()
        assertContentIsClearOfChrome(
            app.staticTexts["Browse the Bundled Year by Feast, Sunday, and Season"],
            in: app
        )

        app.openLibrary()
        assertContentIsClearOfChrome(
            app.staticTexts["Search the Rite"],
            in: app
        )

        app.tabBars.buttons["Learn"].tap()
        assertContentIsClearOfChrome(
            app.staticTexts["Learn the Rite, Keep the Prayer"],
            in: app
        )
    }

    func testAppearanceTogglePersistsDarkModeWithoutBreakingGuide() {
        let firstLaunch = XCUIApplication()
        firstLaunch.launchApp(resetState: true, todayOverride: "2026-03-30")
        firstLaunch.tabBars.buttons["Learn"].tap()

        let appearanceToggle = firstLaunch.segmentedControls["appearance-toggle"]
        XCTAssertTrue(appearanceToggle.waitForExistence(timeout: 5))
        appearanceToggle.buttons["Dark"].tap()
        firstLaunch.terminate()

        let resumedLaunch = XCUIApplication()
        resumedLaunch.launchApp(resetState: false, todayOverride: "2026-03-30")
        resumedLaunch.tabBars.buttons["Learn"].tap()

        let resumedAppearanceToggle = resumedLaunch.segmentedControls["appearance-toggle"]
        XCTAssertTrue(resumedAppearanceToggle.waitForExistence(timeout: 5))
        XCTAssertTrue(resumedAppearanceToggle.buttons["Dark"].isSelected)

        resumedLaunch.openGuide()
        XCTAssertTrue(resumedLaunch.staticTexts["guide-utility-title"].waitForExistence(timeout: 5))
        XCTAssertTrue(resumedLaunch.staticTexts["mass-part-title"].waitForExistence(timeout: 5))
        assertContentIsClearOfChrome(
            resumedLaunch.staticTexts["guide-utility-title"],
            in: resumedLaunch
        )

        resumedLaunch.openCalendar()
        assertContentIsClearOfChrome(
            resumedLaunch.staticTexts["Browse the Bundled Year by Feast, Sunday, and Season"],
            in: resumedLaunch
        )
    }

    func testIPadSidebarCalendarFlow() throws {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-04-05")

        guard !app.tabBars.buttons["Guide"].exists else {
            throw XCTSkip("iPad-only sidebar test")
        }

        XCTAssertTrue(app.buttons["sidebar-tab-calendar"].waitForExistence(timeout: 5))
        app.buttons["sidebar-tab-calendar"].tap()
        XCTAssertTrue(app.textFields["calendar-search-field"].waitForExistence(timeout: 5))
    }

    func testIPadGuideUsesPersistentRailTools() throws {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-04-05")

        guard !app.tabBars.buttons["Guide"].exists else {
            throw XCTSkip("iPad-only sidebar test")
        }

        XCTAssertTrue(app.buttons["sidebar-tab-guide"].waitForExistence(timeout: 5))
        app.buttons["sidebar-tab-guide"].tap()

        XCTAssertTrue(app.buttons["ipad-major-moment-collect-readings"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["guide-utility-title"].exists)
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
        openSection(named: "Guide")
    }

    func openLibrary() {
        openSection(named: "Library")
    }

    func openCalendar() {
        openSection(named: "Calendar")
    }

    private func openSection(named name: String) {
        if tabBars.buttons[name].exists {
            tabBars.buttons[name].tap()
        } else if buttons["sidebar-tab-\(name.lowercased())"].exists {
            buttons["sidebar-tab-\(name.lowercased())"].tap()
        }
    }
}

@MainActor
private func assertContentIsClearOfChrome(_ element: XCUIElement, in app: XCUIApplication) {
    XCTAssertTrue(element.waitForExistence(timeout: 5))

    let navBar = app.navigationBars.firstMatch
    let tabBar = app.tabBars.firstMatch

    for _ in 0 ..< 4 {
        let elementFrame = element.frame
        XCTAssertFalse(elementFrame.isEmpty)

        let clearsTopChrome = !navBar.exists || elementFrame.minY >= navBar.frame.maxY - 4
        let clearsBottomChrome = !tabBar.exists || elementFrame.maxY <= tabBar.frame.minY + 4

        if clearsTopChrome && clearsBottomChrome {
            break
        }

        if tabBar.exists && elementFrame.maxY > tabBar.frame.minY + 4 {
            app.swipeUp()
            continue
        }

        if navBar.exists && elementFrame.minY < navBar.frame.maxY - 4 {
            app.swipeDown()
        }
    }

    let elementFrame = element.frame
    XCTAssertFalse(elementFrame.isEmpty)

    if navBar.exists {
        XCTAssertGreaterThanOrEqual(elementFrame.minY, navBar.frame.maxY - 4)
    }

    if tabBar.exists {
        XCTAssertLessThanOrEqual(elementFrame.maxY, tabBar.frame.minY + 4)
    }
}
