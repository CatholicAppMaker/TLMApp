import Foundation
import Observation
import StoreKit

struct SupportTipOption: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let fallbackDisplayPrice: String
}

struct SupportTipProduct: Hashable, Sendable {
    let id: String
    let displayPrice: String
}

enum SupportTipPurchaseOutcome: Sendable {
    case success
    case pending
    case cancelled
}

protocol SupportTipStorefront: Sendable {
    func fetchProducts(for ids: [String]) async throws -> [SupportTipProduct]
    func purchase(productID: String) async throws -> SupportTipPurchaseOutcome
}

enum SupportTipError: LocalizedError {
    case productMissing(String)

    var errorDescription: String? {
        switch self {
        case let .productMissing(productID):
            "The product \(productID) is not available right now."
        }
    }
}

actor StoreKitSupportTipStorefront: SupportTipStorefront {
    private var productsByID: [String: Product] = [:]

    func fetchProducts(for ids: [String]) async throws -> [SupportTipProduct] {
        let products = try await Product.products(for: ids)
        productsByID = Dictionary(uniqueKeysWithValues: products.map { ($0.id, $0) })

        return products.map { product in
            SupportTipProduct(id: product.id, displayPrice: product.displayPrice)
        }
    }

    func purchase(productID: String) async throws -> SupportTipPurchaseOutcome {
        guard let product = productsByID[productID] else {
            throw SupportTipError.productMissing(productID)
        }

        let result = try await product.purchase()

        switch result {
        case let .success(verificationResult):
            let transaction = try verify(verificationResult)
            await transaction.finish()
            return .success
        case .pending:
            return .pending
        case .userCancelled:
            return .cancelled
        @unknown default:
            return .cancelled
        }
    }

    private func verify<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case let .verified(value):
            value
        case let .unverified(_, error):
            throw error
        }
    }
}

@MainActor
@Observable
final class SupportTipJar {
    let options: [SupportTipOption]

    private let storefront: any SupportTipStorefront

    private(set) var pricesByID: [String: String] = [:]
    private(set) var availableProductIDs: Set<String> = []
    private(set) var hasLoadedProducts = false
    private(set) var isLoadingProducts = false
    private(set) var purchaseInFlightID: String?
    private(set) var statusMessage: String?
    private(set) var errorMessage: String?

    init(storefront: any SupportTipStorefront = StoreKitSupportTipStorefront()) {
        self.storefront = storefront
        options = [
            SupportTipOption(
                id: "com.kevpierce.LatinMassCompanion.tip.small",
                title: "Small Tip",
                subtitle: "A quiet thank-you for the work behind the app.",
                fallbackDisplayPrice: "$1.99"
            ),
            SupportTipOption(
                id: "com.kevpierce.LatinMassCompanion.tip.medium",
                title: "Medium Tip",
                subtitle: "Support continued refinement, content care, and maintenance.",
                fallbackDisplayPrice: "$4.99"
            ),
            SupportTipOption(
                id: "com.kevpierce.LatinMassCompanion.tip.large",
                title: "Large Tip",
                subtitle: "A generous way to support the app's ongoing development.",
                fallbackDisplayPrice: "$9.99"
            )
        ]
    }

    func loadProductsIfNeeded() async {
        guard !hasLoadedProducts else {
            return
        }

        await reloadProducts()
    }

    func reloadProducts() async {
        guard !isLoadingProducts else {
            return
        }

        isLoadingProducts = true
        errorMessage = nil
        statusMessage = nil

        do {
            let products = try await storefront.fetchProducts(for: options.map(\.id))
            pricesByID = Dictionary(uniqueKeysWithValues: products.map { ($0.id, $0.displayPrice) })
            availableProductIDs = Set(products.map(\.id))
            hasLoadedProducts = true
        } catch {
            pricesByID = [:]
            availableProductIDs = []
            errorMessage = "Support options are unavailable right now. App Store pricing could not be loaded."
        }

        isLoadingProducts = false
    }

    func purchase(_ option: SupportTipOption) async {
        guard canPurchase(option) else {
            errorMessage = "Support options are unavailable right now. App Store pricing could not be loaded."
            return
        }

        purchaseInFlightID = option.id
        errorMessage = nil
        statusMessage = nil

        do {
            let outcome = try await storefront.purchase(productID: option.id)

            switch outcome {
            case .success:
                statusMessage = "Thank you for supporting Latin Mass Companion."
            case .pending:
                statusMessage = "Your purchase is pending approval."
            case .cancelled:
                statusMessage = nil
            }
        } catch {
            errorMessage = "The purchase could not be completed."
        }

        purchaseInFlightID = nil
    }

    func displayPrice(for option: SupportTipOption) -> String {
        pricesByID[option.id] ?? option.fallbackDisplayPrice
    }

    func canPurchase(_ option: SupportTipOption) -> Bool {
        availableProductIDs.contains(option.id)
    }

    func isPurchasing(_ option: SupportTipOption) -> Bool {
        purchaseInFlightID == option.id
    }
}
