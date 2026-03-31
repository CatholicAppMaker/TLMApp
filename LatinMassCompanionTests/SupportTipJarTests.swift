@testable import LatinMassCompanion
import Testing

struct SupportTipJarTests {
    @MainActor
    @Test
    func loadsProductsAndUsesFetchedPrices() async {
        let storefront = SpySupportTipStorefront()
        await storefront.setNextProducts([
            SupportTipProduct(
                id: "com.kevpierce.LatinMassCompanion.tip.small",
                displayPrice: "$2.99"
            )
        ])
        let jar = SupportTipJar(storefront: storefront)

        await jar.loadProductsIfNeeded()

        #expect(jar.hasLoadedProducts)
        #expect(jar.errorMessage == nil)
        #expect(jar.displayPrice(for: jar.options[0]) == "$2.99")
        #expect(await storefront.fetchedRequestCount() == 1)
    }

    @MainActor
    @Test
    func purchaseSuccessShowsThankYouMessage() async {
        let storefront = SpySupportTipStorefront()
        let jar = SupportTipJar(storefront: storefront)

        await jar.purchase(jar.options[1])

        #expect(jar.purchaseInFlightID == nil)
        #expect(jar.statusMessage == "Thank you for supporting Latin Mass Companion.")
        #expect(jar.errorMessage == nil)
        #expect(await storefront.purchasedProductIDs() == ["com.kevpierce.LatinMassCompanion.tip.medium"])
    }

    @MainActor
    @Test
    func purchasePendingShowsPendingMessage() async {
        let storefront = SpySupportTipStorefront()
        await storefront.setNextPurchaseOutcome(.pending)
        let jar = SupportTipJar(storefront: storefront)

        await jar.purchase(jar.options[2])

        #expect(jar.statusMessage == "Your purchase is pending approval.")
        #expect(jar.errorMessage == nil)
    }

    @MainActor
    @Test
    func purchaseFailureShowsErrorMessage() async {
        let storefront = SpySupportTipStorefront()
        await storefront.setPurchaseError(SampleTestError.purchaseFailed)
        let jar = SupportTipJar(storefront: storefront)

        await jar.purchase(jar.options[0])

        #expect(jar.statusMessage == nil)
        #expect(jar.errorMessage == "The purchase could not be completed.")
    }
}
