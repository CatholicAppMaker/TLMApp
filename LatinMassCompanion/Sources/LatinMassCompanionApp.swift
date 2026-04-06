import SwiftUI

@main
struct LatinMassCompanionApp: App {
    @State private var appModel: AppModel
    @State private var supportTipJar: SupportTipJar

    init() {
        let processInfo = ProcessInfo.processInfo
        let defaults = UserDefaults.standard

        if processInfo.arguments.contains("-reset-bookmarks")
            || processInfo.arguments.contains("-reset-app-state")
        {
            defaults.removeObject(forKey: UserDefaultsBookmarkStore.defaultKey)
            defaults.removeObject(forKey: UserDefaultsMassModeProgressStore.defaultKey)
            defaults.removeObject(forKey: UserDefaultsMassFormStore.defaultKey)
            defaults.removeObject(forKey: UserDefaultsAppAppearanceStore.defaultKey)
            defaults.removeObject(forKey: "latin.mass.guide.utility.dismissed")
        }

        if let seedIndex = processInfo.arguments.firstIndex(of: "-seed-bookmark"),
           processInfo.arguments.indices.contains(seedIndex + 1)
        {
            defaults.set([processInfo.arguments[seedIndex + 1]], forKey: UserDefaultsBookmarkStore.defaultKey)
        }

        let bookmarkStore = UserDefaultsBookmarkStore(defaults: defaults)
        let progressStore = UserDefaultsMassModeProgressStore(defaults: defaults)
        let massFormStore = UserDefaultsMassFormStore(defaults: defaults)
        let appearanceStore = UserDefaultsAppAppearanceStore(defaults: defaults)
        let nowProvider = Self.makeNowProvider(arguments: processInfo.arguments)

        _appModel = State(
            initialValue: AppModel(
                repository: BundleMassContentRepository(),
                searchService: LocalMassSearchService(),
                bookmarkStore: bookmarkStore,
                progressStore: progressStore,
                massFormStore: massFormStore,
                appearanceStore: appearanceStore,
                now: nowProvider
            )
        )
        _supportTipJar = State(initialValue: SupportTipJar())
    }

    var body: some Scene {
        WindowGroup {
            RootTabView(appModel: appModel, supportTipJar: supportTipJar)
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
