import SwiftUI
#if canImport(GoogleMobileAds)
import GoogleMobileAds

struct AdMobBannerView: UIViewRepresentable {
    let adUnitID: String
    
    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView(adSize: GADAdSizeBanner)
        banner.adUnitID = adUnitID
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            banner.rootViewController = rootVC
        }
        banner.load(GADRequest())
        return banner
    }
    
    func updateUIView(_ uiView: GADBannerView, context: Context) {}
}
#endif

public struct BannerAdContainerView: View {
    @StateObject private var proManager = ProFeatureManager.shared
    
    public init() {}
    
    public var body: some View {
        if !proManager.isVIP {
            #if canImport(GoogleMobileAds)
            AdMobBannerView(adUnitID: AdManager.testBannerAdUnitID)
                .frame(height: 50)
                .background(Color(red: 0.05, green: 0.07, blue: 0.10))
            #else
            HStack(spacing: 8) {
                Spacer()
                Image(systemName: "megaphone.fill")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                Text("AdMob Adaptive Banner • 320x50")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.gray)
                Spacer()
            }
            .frame(height: 50)
            .background(Color(red: 0.05, green: 0.07, blue: 0.10))
            #endif
        }
    }
}
