import AppIntents

struct OpenGuideIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Guide"
    static let description = IntentDescription("Open the guide in Latin Mass Companion.")
    static let openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        .result()
    }
}

struct LatinMassCompanionShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenGuideIntent(),
            phrases: [
                "Open the guide in \(.applicationName)",
                "Open \(.applicationName)"
            ],
            shortTitle: "Open Guide",
            systemImageName: "book.pages"
        )
    }
}
