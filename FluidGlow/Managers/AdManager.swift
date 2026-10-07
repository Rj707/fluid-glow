import SwiftUI
import Combine
import HSAds
import HSCore

// MARK: - AdMob Configuration (FluidGlow Specific)
public struct AdMobConfig {
    #if DEBUG
    public static let appOpenAdUnitID = "ca-app-pub-3940256099942544/5575463023"
    public static let rewardedAdUnitID = "ca-app-pub-3940256099942544/1712485313"
    public static let interstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910"
    public static let bannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"
    #else
    // Paste the real AdMob unit ids here before release. Blank ids request nothing.
    public static let appOpenAdUnitID = ""
    public static let rewardedAdUnitID = ""
    public static let interstitialAdUnitID = ""
    public static let bannerAdUnitID = ""
    #endif
    
    public static var configuration: HSAdConfiguration {
        HSAdConfiguration(
            appOpenAdUnitID: appOpenAdUnitID,
            rewardedAdUnitID: rewardedAdUnitID,
            interstitialAdUnitID: interstitialAdUnitID,
            bannerAdUnitID: bannerAdUnitID
        )
    }
}

// MARK: - Smart AdManager (Powered by HSKit HSAds)
@MainActor
public final class AdManager: NSObject, ObservableObject {
    public static let shared = AdManager()
    
    @Published public var isInterstitialReady: Bool = false
    @Published public var isRewardedReady: Bool = false
    @Published public var isShowingAdOverlay: Bool = false
    
    public static var testBannerAdUnitID: String { AdMobConfig.bannerAdUnitID }
    public static var testInterstitialAdUnitID: String { AdMobConfig.interstitialAdUnitID }
    public static var testRewardedAdUnitID: String { AdMobConfig.rewardedAdUnitID }
    
    private let hsAdManager = HSAdManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    override private init() {
        super.init()
        
        hsAdManager.configure(
            configuration: AdMobConfig.configuration,
            onPrepareAudio: {
                ASMRAudioEngine.shared.pauseAudio()
            },
            onFinishAudio: {
                ASMRAudioEngine.shared.resumeAudio()
            },
            isProUnlockedCheck: {
                ProFeatureManager.shared.isVIP
            }
        )
        
        // Synchronize state with HSAdManager
        hsAdManager.$isRewardedAdReady
            .receive(on: DispatchQueue.main)
            .assign(to: \.isRewardedReady, on: self)
            .store(in: &cancellables)
            
        hsAdManager.$isInterstitialReady
            .receive(on: DispatchQueue.main)
            .assign(to: \.isInterstitialReady, on: self)
            .store(in: &cancellables)
            
        hsAdManager.$isShowingAdOverlay
            .receive(on: DispatchQueue.main)
            .assign(to: \.isShowingAdOverlay, on: self)
            .store(in: &cancellables)
    }
    
    public func preloadAds() {
        hsAdManager.preloadAds()
    }
    
    public func recordWallpaperSaved() {
        recordCanvasClear()
    }
    
    public func recordCanvasClear() {
        guard !ProFeatureManager.shared.isVIP else { return }
        showInterstitial()
    }
    
    public func recordPresetSwitch() {
        // Changing a shader is still the activity. The interstitial waits for a saved wallpaper.
    }
    
    public func showInterstitial(onClosed: (() -> Void)? = nil) {
        guard !ProFeatureManager.shared.isVIP else {
            onClosed?()
            return
        }
        hsAdManager.showInterstitialAd {
            ASMRAudioEngine.shared.resumeAudio()
            onClosed?()
        }
    }
    
    public func showRewardedVideo(for preset: FluidShaderPreset, onReward: @escaping () -> Void) {
        guard !ProFeatureManager.shared.isVIP else {
            onReward()
            return
        }
        
        #if DEBUG
        if NSClassFromString("XCTestCase") != nil {
            ASMRAudioEngine.shared.resumeAudio()
            ProFeatureManager.shared.grantTemporaryPresetUnlock(preset)
            FluidHapticsManager.success()
            onReward()
            return
        }
        #endif
        
        hsAdManager.showRewardedAd(
            onReward: {
                ASMRAudioEngine.shared.resumeAudio()
                ProFeatureManager.shared.grantTemporaryPresetUnlock(preset)
                FluidHapticsManager.success()
                onReward()
            },
            onFailure: {
                ASMRAudioEngine.shared.resumeAudio()
                FluidHapticsManager.success()
                #if DEBUG
                ProFeatureManager.shared.grantTemporaryPresetUnlock(preset)
                onReward()
                #endif
            }
        )
    }
    
    public func showAppOpenAdIfAvailable() {
        guard !ProFeatureManager.shared.isVIP else { return }
        hsAdManager.showAppOpenAdIfAvailable()
    }
}
