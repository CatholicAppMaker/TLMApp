import Foundation
import SwiftUI

enum AppAppearance: String, CaseIterable, Identifiable, Sendable {
    case system
    case light
    case dark

    var id: Self {
        self
    }

    var title: String {
        switch self {
        case .system:
            "System"
        case .light:
            "Light"
        case .dark:
            "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            nil
        case .light:
            .light
        case .dark:
            .dark
        }
    }
}

protocol AppAppearanceStore {
    func loadAppearance() -> AppAppearance
    func saveAppearance(_ appearance: AppAppearance)
}

struct UserDefaultsAppAppearanceStore: AppAppearanceStore {
    static let defaultKey = "latin.mass.app.appearance"

    private let defaults: UserDefaults
    private let key: String

    init(defaults: UserDefaults = .standard, key: String = defaultKey) {
        self.defaults = defaults
        self.key = key
    }

    func loadAppearance() -> AppAppearance {
        guard
            let rawValue = defaults.string(forKey: key),
            let appearance = AppAppearance(rawValue: rawValue)
        else {
            return .system
        }

        return appearance
    }

    func saveAppearance(_ appearance: AppAppearance) {
        defaults.set(appearance.rawValue, forKey: key)
    }
}
