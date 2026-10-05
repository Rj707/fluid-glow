import SwiftUI

public struct FluidGlowSplashView: View {
    @Binding var isActive: Bool
    @State private var isAnimating = false
    @State private var pulseAura = false
    @State private var textOpacity = 0.0
    
    public init(isActive: Binding<Bool>) {
        self._isActive = isActive
    }
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Hypnotic background ambient glow
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.9, blue: 0.6).opacity(pulseAura ? 0.25 : 0.08),
                    Color(red: 0.9, green: 0.1, blue: 0.7).opacity(pulseAura ? 0.20 : 0.05),
                    Color.black
                ]),
                center: .center,
                startRadius: 20,
                endRadius: pulseAura ? 280 : 160
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Animated Glowing Swirl Emblem
                ZStack {
                    // Outer neon aura
                    Circle()
                        .fill(
                            AngularGradient(
                                gradient: Gradient(colors: [.cyan, .pink, .purple, .green, .cyan]),
                                center: .center
                            )
                        )
                        .frame(width: 110, height: 110)
                        .blur(radius: 20)
                        .opacity(pulseAura ? 0.8 : 0.4)
                        .scaleEffect(pulseAura ? 1.15 : 0.95)
                    
                    // Rotating fluid vortex core
                    Circle()
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.1, green: 0.9, blue: 0.6),
                                    Color(red: 0.0, green: 0.7, blue: 0.95),
                                    Color(red: 0.9, green: 0.1, blue: 0.7),
                                    Color(red: 1.0, green: 0.8, blue: 0.1),
                                    Color(red: 0.1, green: 0.9, blue: 0.6)
                                ]),
                                center: .center
                            ),
                            lineWidth: 5
                        )
                        .frame(width: 86, height: 86)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    
                    // Center stardust node
                    Circle()
                        .fill(Color.white)
                        .frame(width: 14, height: 14)
                        .shadow(color: .cyan, radius: 10)
                        .shadow(color: .white, radius: 4)
                        .scaleEffect(pulseAura ? 1.2 : 0.8)
                }
                
                // App Title & Tagline
                VStack(spacing: 8) {
                    Text("Fluid Glow")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.1, green: 0.9, blue: 0.6),
                                    Color(red: 0.0, green: 0.7, blue: 0.95),
                                    Color(red: 0.9, green: 0.1, blue: 0.7)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Color(red: 0.1, green: 0.9, blue: 0.6).opacity(0.5), radius: 12)
                    
                    Text("ASMR SENSORY RELAX")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .tracking(3.5)
                        .foregroundStyle(Color.white.opacity(0.65))
                }
                .opacity(textOpacity)
                
                Spacer()
                
                // Subtle loading pulse dots
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.white.opacity(0.4))
                            .frame(width: 6, height: 6)
                            .scaleEffect(pulseAura ? 1.3 : 0.7)
                            .animation(
                                .easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.15),
                                value: pulseAura
                            )
                    }
                }
                .padding(.bottom, 48)
            }
        }
        .onAppear {
            let args = ProcessInfo.processInfo.arguments
            if args.contains(where: { $0.hasPrefix("-screenshot") }) {
                isActive = false
                return
            }
            
            withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                pulseAura = true
            }
            withAnimation(.easeOut(duration: 0.5)) {
                textOpacity = 1.0
            }
            
            FluidHapticsManager.fluidSwirl(speed: 12)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                withAnimation(.easeInOut(duration: 0.35)) {
                    isActive = false
                }
            }
        }
    }
}
