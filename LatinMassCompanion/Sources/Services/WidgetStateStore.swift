import Foundation

#if canImport(WidgetKit)
import WidgetKit
#endif

enum AppGroupConfig {
    static let identifier = "group.com.kevpierce.LatinMassCompanion"
}

struct WidgetStateSnapshot: Codable, Equatable, Sendable {
    let bookmarkCount: Int
    let bookmarkTitles: [String]
    let resumePartTitle: String?
    let resumeCelebrationTitle: String?
    let resumeDateText: String?
    let resumeMassFormTitle: String?

    static let empty = WidgetStateSnapshot(
        bookmarkCount: 0,
        bookmarkTitles: [],
        resumePartTitle: nil,
        resumeCelebrationTitle: nil,
        resumeDateText: nil,
        resumeMassFormTitle: nil
    )
}

protocol WidgetStateStore {
    func loadSnapshot() -> WidgetStateSnapshot?
    func saveSnapshot(_ snapshot: WidgetStateSnapshot)
    func clearSnapshot()
}

struct AppGroupWidgetStateStore: WidgetStateStore {
    static let defaultKey = "latin.mass.widget.snapshot"

    private let defaults: UserDefaults?
    private let key: String
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(
        defaults: UserDefaults? = UserDefaults(suiteName: AppGroupConfig.identifier),
        key: String = defaultKey
    ) {
        self.defaults = defaults
        self.key = key
    }

    func loadSnapshot() -> WidgetStateSnapshot? {
        guard
            let defaults,
            let data = defaults.data(forKey: key)
        else {
            return nil
        }

        return try? decoder.decode(WidgetStateSnapshot.self, from: data)
    }

    func saveSnapshot(_ snapshot: WidgetStateSnapshot) {
        guard
            let defaults,
            let data = try? encoder.encode(snapshot)
        else {
            return
        }

        defaults.set(data, forKey: key)
        reloadWidgets()
    }

    func clearSnapshot() {
        defaults?.removeObject(forKey: key)
        reloadWidgets()
    }

    private func reloadWidgets() {
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
}

struct NoopWidgetStateStore: WidgetStateStore {
    func loadSnapshot() -> WidgetStateSnapshot? { nil }
    func saveSnapshot(_ snapshot: WidgetStateSnapshot) {}
    func clearSnapshot() {}
}
