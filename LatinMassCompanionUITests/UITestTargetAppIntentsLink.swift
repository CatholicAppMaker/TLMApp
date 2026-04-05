import AppIntents

// Keeps metadata extraction quiet for the UI test bundle when Xcode scans targets.
private struct UITestTargetLinkIntent: AppIntent {
    static let title: LocalizedStringResource = "UI Test Target Link Intent"

    func perform() async throws -> some IntentResult {
        .result()
    }
}
