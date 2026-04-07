import Foundation

enum WidgetAppGroupConfig {
    static let identifier = "group.com.kevpierce.LatinMassCompanion"
}

struct WidgetSharedSnapshot: Codable {
    let bookmarkCount: Int
    let bookmarkTitles: [String]
    let resumePartTitle: String?
    let resumeCelebrationTitle: String?
    let resumeDateText: String?
    let resumeMassFormTitle: String?

    static let empty = WidgetSharedSnapshot(
        bookmarkCount: 0,
        bookmarkTitles: [],
        resumePartTitle: nil,
        resumeCelebrationTitle: nil,
        resumeDateText: nil,
        resumeMassFormTitle: nil
    )
}

struct WidgetSharedStateLoader {
    static let defaultKey = "latin.mass.widget.snapshot"

    private let defaults: UserDefaults?
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults? = UserDefaults(suiteName: WidgetAppGroupConfig.identifier)) {
        self.defaults = defaults
    }

    func loadSnapshot() -> WidgetSharedSnapshot {
        guard
            let defaults,
            let data = defaults.data(forKey: Self.defaultKey),
            let snapshot = try? decoder.decode(WidgetSharedSnapshot.self, from: data)
        else {
            return .empty
        }

        return snapshot
    }
}
