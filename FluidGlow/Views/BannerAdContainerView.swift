import SwiftUI
import HSAds

// MARK: - Sticky Adaptive Banner Ad Container (Powered by HSKit HSAds)
public struct BannerAdContainerView: View {
    @ObservedObject private var proManager = ProFeatureManager.shared
    
    public init() {}
    
    public var body: some View {
        if !proManager.isVIP {
            HSBannerAdView(
                adUnitID: AdMobConfig.bannerAdUnitID,
                isProUnlocked: proManager.isVIP
            )
            .background(Color(red: 0.05, green: 0.07, blue: 0.10))
        }
    }
}
