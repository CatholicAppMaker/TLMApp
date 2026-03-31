import Foundation

protocol BookmarkStore {
    func loadBookmarks() -> Set<String>
    func saveBookmarks(_ ids: Set<String>)
}

struct UserDefaultsBookmarkStore: BookmarkStore {
    static let defaultKey = "latin.mass.bookmarks"

    private let defaults: UserDefaults
    private let key: String

    init(defaults: UserDefaults = .standard, key: String = defaultKey) {
        self.defaults = defaults
        self.key = key
    }

    func loadBookmarks() -> Set<String> {
        let values = defaults.array(forKey: key) as? [String] ?? []
        return Set(values)
    }

    func saveBookmarks(_ ids: Set<String>) {
        defaults.set(Array(ids).sorted(), forKey: key)
    }
}
