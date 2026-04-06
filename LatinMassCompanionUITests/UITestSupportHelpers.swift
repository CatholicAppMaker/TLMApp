import XCTest

@MainActor
func tapAfterScrollingIfNeeded(_ element: XCUIElement, in app: XCUIApplication) {
    if element.isHittable {
        element.tap()
        return
    }

    for _ in 0 ..< 4 {
        app.swipeUp()
        if element.isHittable {
            element.tap()
            return
        }
    }

    if element.exists, !element.frame.isEmpty {
        let coordinate = app.coordinate(withNormalizedOffset: .zero)
            .withOffset(CGVector(dx: element.frame.midX, dy: element.frame.midY))
        coordinate.tap()
        return
    }

    element.tap()
}

@MainActor
func visibleBookmarkButton(in app: XCUIApplication) -> XCUIElement {
    let matches = app.buttons.matching(identifier: "bookmark-button").allElementsBoundByIndex
    if let hittable = matches.first(where: \.isHittable) {
        return hittable
    }

    return matches.first ?? app.buttons["bookmark-button"]
}

@MainActor
func assertContentIsClearOfChrome(_ element: XCUIElement, in app: XCUIApplication) {
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

extension XCUIApplication {
    func launchApp(
        resetState: Bool,
        todayOverride: String? = nil,
        seedBookmark: String? = nil
    ) {
        var arguments: [String] = []
        if resetState {
            arguments.append("-reset-app-state")
        }
        if let todayOverride {
            arguments.append(contentsOf: ["-today-override", todayOverride])
        }
        if let seedBookmark {
            arguments.append(contentsOf: ["-seed-bookmark", seedBookmark])
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
