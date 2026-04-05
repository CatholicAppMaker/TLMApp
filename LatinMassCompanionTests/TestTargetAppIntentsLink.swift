import AppIntents

// Keeps metadata extraction quiet for the test bundle when Xcode scans targets.
private struct TestTargetLinkIntent: AppIntent {
    static let title: LocalizedStringResource = "Test Target Link Intent"

    func perform() async throws -> some IntentResult {
        .result()
    }
}
