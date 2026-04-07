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

@MainActor
func assertElementsDoNotOverlap(
    _ first: XCUIElement,
    _ second: XCUIElement,
    minSpacing: CGFloat = 8,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    XCTAssertTrue(first.waitForExistence(timeout: 5), file: file, line: line)
    XCTAssertTrue(second.waitForExistence(timeout: 5), file: file, line: line)

    let firstFrame = first.frame
    let secondFrame = second.frame

    XCTAssertFalse(firstFrame.isEmpty, file: file, line: line)
    XCTAssertFalse(secondFrame.isEmpty, file: file, line: line)

    let horizontalSeparation = max(firstFrame.minX, secondFrame.minX) - min(firstFrame.maxX, secondFrame.maxX)
    let verticalSeparation = max(firstFrame.minY, secondFrame.minY) - min(firstFrame.maxY, secondFrame.maxY)

    XCTAssertTrue(
        horizontalSeparation >= minSpacing || verticalSeparation >= minSpacing,
        "Expected elements to remain visually separated by at least \(minSpacing) points, but frames were \(firstFrame) and \(secondFrame)",
        file: file,
        line: line
    )
}

@MainActor
func assertElement(
    _ element: XCUIElement,
    isContainedIn container: XCUIElement,
    inset: CGFloat = 0,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    XCTAssertTrue(element.waitForExistence(timeout: 5), file: file, line: line)
    XCTAssertTrue(container.waitForExistence(timeout: 5), file: file, line: line)

    let elementFrame = element.frame
    let containerFrame = container.frame

    XCTAssertFalse(elementFrame.isEmpty, file: file, line: line)
    XCTAssertFalse(containerFrame.isEmpty, file: file, line: line)

    XCTAssertGreaterThanOrEqual(elementFrame.minX, containerFrame.minX + inset, file: file, line: line)
    XCTAssertGreaterThanOrEqual(elementFrame.minY, containerFrame.minY + inset, file: file, line: line)
    XCTAssertLessThanOrEqual(elementFrame.maxX, containerFrame.maxX - inset, file: file, line: line)
    XCTAssertLessThanOrEqual(elementFrame.maxY, containerFrame.maxY - inset, file: file, line: line)
}

@MainActor
func assertElementsAreStackedVertically(
    upper: XCUIElement,
    lower: XCUIElement,
    minSpacing: CGFloat = 8,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    XCTAssertTrue(upper.waitForExistence(timeout: 5), file: file, line: line)
    XCTAssertTrue(lower.waitForExistence(timeout: 5), file: file, line: line)

    let upperFrame = upper.frame
    let lowerFrame = lower.frame

    XCTAssertFalse(upperFrame.isEmpty, file: file, line: line)
    XCTAssertFalse(lowerFrame.isEmpty, file: file, line: line)

    XCTAssertGreaterThanOrEqual(
        lowerFrame.minY,
        upperFrame.maxY + minSpacing,
        "Expected lower element to sit at least \(minSpacing) points below upper element, but frames were \(upperFrame) and \(lowerFrame)",
        file: file,
        line: line
    )
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
