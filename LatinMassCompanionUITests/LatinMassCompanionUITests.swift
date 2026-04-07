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

        let collectCheckpoint = app.buttons["timeline-checkpoint-collect-readings"]
        XCTAssertTrue(collectCheckpoint.waitForExistence(timeout: 5))
        collectCheckpoint.tap()

        let partTitle = app.staticTexts["mass-part-title"]
        XCTAssertTrue(partTitle.waitForExistence(timeout: 5))
        XCTAssertEqual(partTitle.label, "Octave Day of Christmas Collect, Epistle, and Gradual")
    }

    func testGuideTimelineJumpsToCanon() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-03-30")

        app.openGuide()

        let canonCheckpoint = app.buttons["timeline-checkpoint-canon"]
        XCTAssertTrue(canonCheckpoint.waitForExistence(timeout: 5))
        canonCheckpoint.tap()

        let partTitle = app.staticTexts["mass-part-title"]
        XCTAssertTrue(partTitle.waitForExistence(timeout: 5))
        XCTAssertEqual(partTitle.label, "Canon of the Mass")
    }

    func testBookmarkAppearsInLibraryBookmarks() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-03-30", seedBookmark: "prayers-foot-altar")

        app.openLibrary()

        XCTAssertTrue(app.buttons["library-saved-sections-button"].waitForExistence(timeout: 5))
        app.buttons["library-saved-sections-button"].tap()
        XCTAssertTrue(app.buttons["Show All"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Bookmarks"].exists)
        XCTAssertTrue(app.segmentedControls["library-scope-toggle"].buttons["Bookmarks"].isSelected)
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
        assertContentIsClearOfChrome(
            app.staticTexts["guide-timeline-title"],
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
@MainActor
final class LatinMassCompanionReleaseUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testCalendarOpenLibraryCarriesSelectedCelebrationContext() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-03-30")

        app.openCalendar()
        app.swipeUp()

        let octaveDayRow = app.buttons["calendar-row-2026-01-01"]
        XCTAssertTrue(octaveDayRow.waitForExistence(timeout: 5))
        octaveDayRow.tap()

        let openLibraryButton = app.buttons["calendar-open-library-button"]
        XCTAssertTrue(openLibraryButton.waitForExistence(timeout: 5))
        openLibraryButton.tap()

        XCTAssertTrue(app.staticTexts["Octave Day of Christmas"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.segmentedControls["library-mass-form-toggle"].exists)
    }

    func testLearnShowsAppearanceAndOptionalSupportSections() {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-03-30")

        app.tabBars.buttons["Learn"].tap()

        XCTAssertTrue(app.segmentedControls["appearance-toggle"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Optional Support"].waitForExistence(timeout: 5))
        XCTAssertTrue(
            app.otherElements["support-tip-loading"].exists ||
                app.buttons["support-tip-retry"].exists ||
                app.buttons.matching(identifier: "support-tip-com.kevpierce.LatinMassCompanion.tip.small").firstMatch.exists
        )
    }

    func testIPadCalendarSelectionCanOpenLibraryContext() throws {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-04-05")

        guard !app.tabBars.buttons["Guide"].exists else {
            throw XCTSkip("iPad-only sidebar test")
        }

        app.buttons["sidebar-tab-calendar"].tap()

        let octaveDayRow = app.buttons["calendar-row-2026-01-01"]
        XCTAssertTrue(octaveDayRow.waitForExistence(timeout: 5))
        octaveDayRow.tap()

        let openLibraryButton = app.buttons["calendar-open-library-button"]
        XCTAssertTrue(openLibraryButton.waitForExistence(timeout: 5))
        openLibraryButton.tap()

        XCTAssertTrue(app.staticTexts["Octave Day of Christmas"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.textFields["library-search-field"].exists)
    }

    func testIPadLearnShowsAppearanceAndSupportSections() throws {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-04-05")

        guard !app.tabBars.buttons["Guide"].exists else {
            throw XCTSkip("iPad-only sidebar test")
        }

        app.buttons["sidebar-tab-learn"].tap()

        XCTAssertTrue(app.segmentedControls["appearance-toggle"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Optional Support"].waitForExistence(timeout: 5))
    }

    func testIPadGuideBookmarkCarriesIntoLibraryBookmarks() throws {
        let app = XCUIApplication()
        app.launchApp(resetState: true, todayOverride: "2026-04-05", seedBookmark: "prayers-foot-altar")

        guard !app.tabBars.buttons["Guide"].exists else {
            throw XCTSkip("iPad-only sidebar test")
        }

        app.buttons["sidebar-tab-library"].tap()
        XCTAssertTrue(app.buttons["library-saved-sections-button"].waitForExistence(timeout: 5))
        app.buttons["library-saved-sections-button"].tap()
        XCTAssertTrue(app.buttons["Show All"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Bookmarks"].exists)
        XCTAssertTrue(app.segmentedControls["library-scope-toggle"].buttons["Bookmarks"].isSelected)
    }

}
