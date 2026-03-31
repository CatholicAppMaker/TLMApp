import Foundation

protocol MassContentRepository {
    func loadCatalog() throws -> MassCatalog
}

enum MassContentRepositoryError: LocalizedError {
    case missingResource(String)
    case unreadableResource(String)

    var errorDescription: String? {
        switch self {
        case let .missingResource(name):
            "The bundled Mass content file '\(name).json' could not be found."
        case let .unreadableResource(message):
            "The bundled Mass content could not be read: \(message)"
        }
    }
}

struct BundleMassContentRepository: MassContentRepository {
    private let bundle: Bundle
    private let resourceName: String

    init(bundle: Bundle = .main, resourceName: String = "mass_library") {
        self.bundle = bundle
        self.resourceName = resourceName
    }

    func loadCatalog() throws -> MassCatalog {
        guard let url = bundle.url(forResource: resourceName, withExtension: "json") else {
            throw MassContentRepositoryError.missingResource(resourceName)
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(MassCatalog.self, from: data)
        } catch {
            throw MassContentRepositoryError.unreadableResource(String(describing: error))
        }
    }
}
