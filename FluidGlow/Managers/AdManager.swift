import SwiftUI

@MainActor
public final class AdManager: ObservableObject {
    public static let shared = AdManager()
    
    @Published public var isInterstitialReady: Bool = true
    @Published public var isRewardedReady: Bool = true
    
    public static let testBannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"
    public static let testInterstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910"
    public static let testRewardedAdUnitID = "ca-app-pub-3940256099942544/1712485313"
    
    private var switchCount = 0
    private let interstitialFrequency = 5
    
    public init() {}
    
    public func recordPresetSwitch() {
        guard !ProFeatureManager.shared.isVIP else { return }
        switchCount += 1
        if switchCount >= interstitialFrequency {
            switchCount = 0
            showInterstitial()
        }
    }
    
    public func showInterstitial() {
        guard !ProFeatureManager.shared.isVIP else { return }
        print("AdMob Interstitial presented")
    }
    
    public func showRewardedVideo(for preset: FluidShaderPreset, onReward: @escaping () -> Void) {
        // In test mode, simulates immediate reward
        onReward()
        FluidHapticsManager.success()
    }
}
