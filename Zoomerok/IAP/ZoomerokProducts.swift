import Foundation

public struct ZoomerokProducts {
    public static let NoWatermarkSubscription = "com.icorp.Zoomerok.subscription.no_watermark"
    private static let productIdentifiers: Set<ProductIdentifier> = [ZoomerokProducts.NoWatermarkSubscription]
    public static let store = IAPHelper(productIds: ZoomerokProducts.productIdentifiers)
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}
