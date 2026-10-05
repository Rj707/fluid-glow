import SwiftUI

@main
struct FluidGlowApp: App {
    @State private var isSplashActive = true
    
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
        }
    }
}
