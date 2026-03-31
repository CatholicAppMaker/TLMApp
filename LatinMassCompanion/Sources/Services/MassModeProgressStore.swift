import Foundation

struct MassModeProgress: Codable, Hashable, Sendable {
    let dateKey: String
    let sectionID: String
    let celebrationID: String?
    let massForm: MassForm
    let lastOpenedAt: Date
}

protocol MassModeProgressStore {
    func loadProgress() -> MassModeProgress?
    func saveProgress(_ progress: MassModeProgress)
    func clearProgress()
}

struct UserDefaultsMassModeProgressStore: MassModeProgressStore {
    static let defaultKey = "latin.mass.mode.progress"

    private let defaults: UserDefaults
    private let key: String
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard, key: String = defaultKey) {
        self.defaults = defaults
        self.key = key
    }

    func loadProgress() -> MassModeProgress? {
        guard let data = defaults.data(forKey: key) else {
            return nil
        }

        return try? decoder.decode(MassModeProgress.self, from: data)
    }

    func saveProgress(_ progress: MassModeProgress) {
        guard let data = try? encoder.encode(progress) else {
            return
        }

        defaults.set(data, forKey: key)
    }

    func clearProgress() {
        defaults.removeObject(forKey: key)
    }
}
