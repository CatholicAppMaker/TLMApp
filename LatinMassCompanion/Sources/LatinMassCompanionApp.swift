import SwiftUI

@main
struct LatinMassCompanionApp: App {
    @State private var appModel: AppModel

    init() {
        let processInfo = ProcessInfo.processInfo
        let defaults = UserDefaults.standard

        if processInfo.arguments.contains("-reset-bookmarks")
            || processInfo.arguments.contains("-reset-app-state")
        {
            defaults.removeObject(forKey: UserDefaultsBookmarkStore.defaultKey)
            defaults.removeObject(forKey: UserDefaultsMassModeProgressStore.defaultKey)
        }

        let bookmarkStore = UserDefaultsBookmarkStore(defaults: defaults)
        let progressStore = UserDefaultsMassModeProgressStore(defaults: defaults)
        let nowProvider = Self.makeNowProvider(arguments: processInfo.arguments)

        _appModel = State(
            initialValue: AppModel(
                repository: BundleMassContentRepository(),
                searchService: LocalMassSearchService(),
                bookmarkStore: bookmarkStore,
                progressStore: progressStore,
                now: nowProvider
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            RootTabView(appModel: appModel)
        }
    }

    private static func makeNowProvider(arguments: [String]) -> () -> Date {
        guard let index = arguments.firstIndex(of: "-today-override"),
              arguments.indices.contains(index + 1),
              let date = overrideDateFormatter.date(from: arguments[index + 1])
        else {
            return Date.init
        }

        return { date }
    }

    private static let overrideDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
