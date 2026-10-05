import SwiftUI
#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

@MainActor
public final class AdManager: NSObject, ObservableObject {
    public static let shared = AdManager()
    
    @Published public var isInterstitialReady: Bool = false
    @Published public var isRewardedReady: Bool = false
    
    public static let testBannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"
    public static let testInterstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910"
    public static let testRewardedAdUnitID = "ca-app-pub-3940256099942544/1712485313"
    
    private var switchCount = 0
    private let interstitialSwitchThreshold = 3
    private var lastInterstitialTime: Date? = nil
    private let interstitialCooldownSeconds: TimeInterval = 180 // 3 minutes cooldown
    
    #if canImport(GoogleMobileAds)
    private var interstitialAd: GADInterstitialAd?
    private var rewardedAd: GADRewardedAd?
    #endif
    
    public override init() {
        super.init()
        loadInterstitial()
        loadRewarded()
    }
    
    public func loadInterstitial() {
        guard !ProFeatureManager.shared.isVIP else { return }
        #if canImport(GoogleMobileAds)
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: Self.testInterstitialAdUnitID, request: request) { [weak self] ad, error in
            guard let self = self else { return }
            if let error = error {
                print("AdMob Interstitial load failed: \(error.localizedDescription)")
                self.isInterstitialReady = false
                return
            }
            self.interstitialAd = ad
            self.isInterstitialReady = true
        }
        #else
        self.isInterstitialReady = true
        #endif
    }
    
    public func loadRewarded() {
        guard !ProFeatureManager.shared.isVIP else { return }
        #if canImport(GoogleMobileAds)
        let request = GADRequest()
        GADRewardedAd.load(withAdUnitID: Self.testRewardedAdUnitID, request: request) { [weak self] ad, error in
            guard let self = self else { return }
            if let error = error {
                print("AdMob Rewarded load failed: \(error.localizedDescription)")
                self.isRewardedReady = false
                return
            }
            self.rewardedAd = ad
            self.isRewardedReady = true
        }
        #else
        self.isRewardedReady = true
        #endif
    }
    
    public func recordWallpaperSaved() {
        recordCanvasClear()
    }
    
    public func recordCanvasClear() {
        guard !ProFeatureManager.shared.isVIP else { return }
        
        let cooldownElapsed: Bool
        if let lastTime = lastInterstitialTime {
            cooldownElapsed = Date().timeIntervalSince(lastTime) >= interstitialCooldownSeconds
        } else {
            cooldownElapsed = true
        }
        
        if cooldownElapsed {
            showInterstitial()
        }
    }
    
    public func recordPresetSwitch() {
        guard !ProFeatureManager.shared.isVIP else { return }
        switchCount += 1
        
        let cooldownElapsed: Bool
        if let lastTime = lastInterstitialTime {
            cooldownElapsed = Date().timeIntervalSince(lastTime) >= interstitialCooldownSeconds
        } else {
            cooldownElapsed = true
        }
        
        if switchCount >= interstitialSwitchThreshold && cooldownElapsed {
            switchCount = 0
            showInterstitial()
        }
    }
    
    public func showInterstitial() {
        guard !ProFeatureManager.shared.isVIP else { return }
        lastInterstitialTime = Date()
        
        #if canImport(GoogleMobileAds)
        if let ad = interstitialAd,
           let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            ad.present(fromRootViewController: rootVC)
            self.interstitialAd = nil
            self.isInterstitialReady = false
            loadInterstitial()
            return
        }
        #endif
        
        print("AdMob Interstitial presented (Simulated)")
        loadInterstitial()
    }
    
    public func showRewardedVideo(for preset: FluidShaderPreset, onReward: @escaping () -> Void) {
        guard !ProFeatureManager.shared.isVIP else {
            onReward()
            return
        }
        
        #if canImport(GoogleMobileAds)
        if let ad = rewardedAd,
           let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            ad.present(fromRootViewController: rootVC) { [weak self] in
                onReward()
                FluidHapticsManager.success()
                self?.rewardedAd = nil
                self?.isRewardedReady = false
                self?.loadRewarded()
            }
            return
        }
        #endif
        
        // Simulated / test fallback
        onReward()
        FluidHapticsManager.success()
        loadRewarded()
    }
}
