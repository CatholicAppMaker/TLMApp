import Foundation
@testable import LatinMassCompanion
import Testing

struct RepositoryTests {
    @Test
    func repositoryReportsMissingResources() {
        let repository = BundleMassContentRepository(
            bundle: Bundle(for: TestBundleLocator.self),
            resourceName: "missing_mass_library"
        )

        do {
            _ = try repository.loadCatalog()
            Issue.record("Expected missing resource error")
        } catch let error as MassContentRepositoryError {
            switch error {
            case let .missingResource(name):
                #expect(name == "missing_mass_library")
            case let .unreadableResource(message):
                Issue.record("Expected missing resource error, got unreadable resource: \(message)")
            }
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test
    func repositoryReportsUnreadableResources() {
        let repository = BundleMassContentRepository(
            bundle: Bundle(for: TestBundleLocator.self),
            resourceName: "invalid_mass_library"
        )

        do {
            _ = try repository.loadCatalog()
            Issue.record("Expected unreadable resource error")
        } catch let error as MassContentRepositoryError {
            switch error {
            case .missingResource:
                Issue.record("Expected unreadable resource error")
            case let .unreadableResource(message):
                #expect(!message.isEmpty)
            }
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
}
