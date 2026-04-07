import XCTest

@MainActor
extension LatinMassCompanionUITests {
    func testPrimaryCardsStayClearOfNavigationAndTabChrome() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-03-30")

        app.openGuide()
        assertContentIsClearOfChrome(app.staticTexts["guide-utility-title"], in: app)
        assertContentIsClearOfChrome(app.staticTexts["guide-timeline-title"], in: app)

        app.openCalendar()
        assertContentIsClearOfChrome(
            app.staticTexts["Browse the Bundled Year by Feast, Sunday, and Season"],
            in: app
        )

        app.openLibrary()
        assertContentIsClearOfChrome(app.staticTexts["Search the Rite"], in: app)

        app.tabBars.buttons["Learn"].tap()
        assertContentIsClearOfChrome(app.staticTexts["Learn the Rite, Keep the Prayer"], in: app)
    }

    func testGuideVisualHierarchyKeepsUtilityCardCalmOnIPhone() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-03-30")

        app.openGuide()

        let massFormToggle = app.segmentedControls["guide-mass-form-toggle"]
        let utilityCard = app.otherElements["guide-utility-card"]
        let utilityTitle = app.staticTexts["guide-utility-title"]
        let dismissButton = app.buttons["dismiss-guide-utility"]
        let findMyPlaceButton = app.buttons["guide-find-my-place-button"]
        let timelineTitle = app.staticTexts["guide-timeline-title"]

        assertElementsAreStackedVertically(upper: massFormToggle, lower: utilityCard, minSpacing: 10)
        assertElement(dismissButton, isContainedIn: utilityCard, inset: 6)
        assertElementsDoNotOverlap(utilityTitle, dismissButton, minSpacing: 12)
        assertElementsAreStackedVertically(upper: utilityTitle, lower: findMyPlaceButton, minSpacing: 16)
        assertElementsAreStackedVertically(upper: utilityCard, lower: timelineTitle, minSpacing: 10)
    }

    func testCalendarAndLibraryMaintainReadableVerticalRhythmOnIPhone() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-03-30")

        app.openCalendar()
        let calendarHero = app.otherElements.matching(identifier: "calendar-hero-card").firstMatch
        let calendarSearch = app.textFields["calendar-search-field"]
        assertElementsAreStackedVertically(upper: calendarHero, lower: calendarSearch, minSpacing: 10)
        assertContentIsClearOfChrome(calendarHero, in: app)

        app.openLibrary()
        let libraryHero = app.otherElements.matching(identifier: "library-hero-card").firstMatch
        let scopeToggle = app.segmentedControls["library-scope-toggle"]
        let librarySearch = app.textFields["library-search-field"]
        assertElementsAreStackedVertically(upper: libraryHero, lower: scopeToggle, minSpacing: 10)
        assertElementsAreStackedVertically(upper: scopeToggle, lower: librarySearch, minSpacing: 10)
        assertContentIsClearOfChrome(libraryHero, in: app)
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
        assertContentIsClearOfChrome(resumedLaunch.staticTexts["guide-utility-title"], in: resumedLaunch)

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

        XCTAssertTrue(app.staticTexts["ipad-rite-timeline-title"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["ipad-timeline-collect-readings"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["guide-utility-title"].exists)
    }

    func testIPadTimelineUpdatesGuideDetail() throws {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-04-05")

        guard !app.tabBars.buttons["Guide"].exists else {
            throw XCTSkip("iPad-only sidebar test")
        }

        app.buttons["sidebar-tab-guide"].tap()

        let canonCheckpoint = app.buttons["ipad-timeline-canon"]
        XCTAssertTrue(canonCheckpoint.waitForExistence(timeout: 5))
        canonCheckpoint.tap()

        let partTitle = app.staticTexts["mass-part-title"]
        XCTAssertTrue(partTitle.waitForExistence(timeout: 5))
        XCTAssertEqual(partTitle.label, "Canon of the Mass")
    }

    func testIPadGuideRailRemainsSeparatedFromDetailContent() throws {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-04-05")

        guard !app.tabBars.buttons["Guide"].exists else {
            throw XCTSkip("iPad-only sidebar test")
        }

        app.buttons["sidebar-tab-guide"].tap()

        let railTimelineTitle = app.staticTexts["ipad-rite-timeline-title"]
        let detailPartTitle = app.staticTexts["mass-part-title"]

        XCTAssertTrue(railTimelineTitle.waitForExistence(timeout: 5))
        XCTAssertTrue(detailPartTitle.waitForExistence(timeout: 5))

        let railFrame = railTimelineTitle.frame
        let detailFrame = detailPartTitle.frame

        XCTAssertFalse(railFrame.isEmpty)
        XCTAssertFalse(detailFrame.isEmpty)
        XCTAssertLessThan(railFrame.maxX + 24, detailFrame.minX)
    }
}
