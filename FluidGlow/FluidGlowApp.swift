import SwiftUI
import HSCore
import HSAds
import HSUI

@main
struct FluidGlowApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @ObservedObject private var theme = HSThemeManager.shared
    @State private var isSplashActive = true
    
    init() {
        AppReports.start()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                MainFluidCanvasView()
                
                if isSplashActive {
                    FluidGlowSplashView(isActive: $isSplashActive)
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .ignoresSafeArea()
            .preferredColorScheme(theme.preferredColorScheme)
            .onAppear {
                if !ProcessInfo.processInfo.arguments.contains(where: { $0.hasPrefix("-screenshot") }) {
                    HSConsentManager.shared.requestTrackingPermission { allowed in
                        AppReports.setCollectionAllowed(allowed)
                        AdManager.shared.preloadAds()
                    }
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active && !isSplashActive {
                    AdManager.shared.showAppOpenAdIfAvailable()
                }
            }
        }
    }
}
