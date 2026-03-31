import Foundation

protocol MassFormStore {
    func loadMassForm() -> MassForm
    func saveMassForm(_ massForm: MassForm)
}

struct UserDefaultsMassFormStore: MassFormStore {
    static let defaultKey = "latin.mass.form.selection"

    private let defaults: UserDefaults
    private let key: String

    init(defaults: UserDefaults = .standard, key: String = defaultKey) {
        self.defaults = defaults
        self.key = key
    }

    func loadMassForm() -> MassForm {
        guard
            let rawValue = defaults.string(forKey: key),
            let massForm = MassForm(rawValue: rawValue)
        else {
            return .low
        }

        return massForm
    }

    func saveMassForm(_ massForm: MassForm) {
        defaults.set(massForm.rawValue, forKey: key)
    }
}
