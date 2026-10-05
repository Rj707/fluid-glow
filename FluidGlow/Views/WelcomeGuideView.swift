import SwiftUI

public struct WelcomeGuideView: View {
    @Environment(\.dismiss) private var dismiss
    public var isModal: Bool
    
    public init(isModal: Bool = true) {
        self.isModal = isModal
    }
    
    public var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.05, blue: 0.08).ignoresSafeArea()
            
            // Hypnotic background ambient glow
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.0, green: 0.75, blue: 0.95).opacity(0.12),
                    Color(red: 0.75, green: 0.15, blue: 0.85).opacity(0.08),
                    Color.clear
                ]),
                center: .top,
                startRadius: 40,
                endRadius: 360
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Dismiss Button (only shown when presented as a standalone modal sheet)
                if isModal {
                    HStack {
                        Spacer()
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(width: 32, height: 32)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 16)
                    }
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        // Hero Header: App Icon Squircle + Gradient Title
                        VStack(spacing: 8) {
                            ZStack {
                                // Ambient icon aura
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(
                                        AngularGradient(
                                            gradient: Gradient(colors: [.cyan, .pink, .purple, .yellow, .cyan]),
                                            center: .center
                                        )
                                    )
                                    .frame(width: 76, height: 76)
                                    .blur(radius: 18)
                                    .opacity(0.65)
                                
                                // App Icon Squircle Core
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.10, green: 0.12, blue: 0.18),
                                                Color(red: 0.05, green: 0.06, blue: 0.10)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 72, height: 72)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color.cyan.opacity(0.7), Color.pink.opacity(0.5)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1.5
                                            )
                                    )
                                
                                Image(systemName: "sparkles")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.cyan, .pink],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                            .padding(.top, 4)
                            
                            Text("Welcome to")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .tracking(1.5)
                                .foregroundColor(.white.opacity(0.6))
                                .textCase(.uppercase)
                                .padding(.top, 4)
                            
                            Text(String(localized: "Fluid Glow"))
                                .font(.system(size: 34, weight: .heavy, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.15, green: 0.90, blue: 0.85),
                                            Color(red: 0.85, green: 0.25, blue: 0.95),
                                            Color(red: 1.0, green: 0.75, blue: 0.2)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: Color.cyan.opacity(0.35), radius: 10)
                            
                            Text(String(localized: "ASMR SENSORY & LIQUID PHYSICS"))
                                .font(.system(size: 12, weight: .heavy, design: .rounded))
                                .tracking(2.0)
                                .foregroundColor(Color(red: 1.0, green: 0.78, blue: 0.15))
                        }
                        
                        // Breathable Feature Rows (No heavy boxes - pure elegant typography)
                        VStack(spacing: 20) {
                            GuideFeatureRow(
                                icon: "hand.draw.fill",
                                gradient: [Color(red: 0.0, green: 0.85, blue: 0.95), Color(red: 0.0, green: 0.50, blue: 0.90)],
                                title: String(localized: "One-Finger Swirl"),
                                description: String(localized: "Drag across the canvas to draw silky glowing streams that flow with realistic fluid physics.")
                            )
                            
                            GuideFeatureRow(
                                icon: "arrow.triangle.2.circlepath",
                                gradient: [Color(red: 0.75, green: 0.25, blue: 0.95), Color(red: 0.50, green: 0.10, blue: 0.80)],
                                title: String(localized: "Multi-Touch Vortex"),
                                description: String(localized: "Use 2 or 3 fingers simultaneously to create intense swirling whirlpools and gravitational vortexes.")
                            )
                            
                            GuideFeatureRow(
                                icon: "sparkles",
                                gradient: [Color(red: 1.0, green: 0.65, blue: 0.10), Color(red: 0.95, green: 0.35, blue: 0.05)],
                                title: String(localized: "Tap Stardust Burst"),
                                description: String(localized: "Tap anywhere to trigger an instant radial explosion of glowing particles and soft ASMR pops.")
                            )
                            
                            GuideFeatureRow(
                                icon: "paintpalette.fill",
                                gradient: [Color(red: 0.95, green: 0.20, blue: 0.60), Color(red: 0.80, green: 0.05, blue: 0.45)],
                                title: String(localized: "6 Hypnotic Shaders"),
                                description: String(localized: "Switch between Neon Aurora, Liquid Gold, Bioluminescent Deep, Cyberpunk Plasma, and OLED.")
                            )
                            
                            GuideFeatureRow(
                                icon: "headphones",
                                gradient: [Color(red: 0.10, green: 0.85, blue: 0.55), Color(red: 0.05, green: 0.60, blue: 0.35)],
                                title: String(localized: "Generative ASMR Audio"),
                                description: String(localized: "Put on headphones! Ambient harmonic chimes and soothing frequencies react in real-time to your swirl speed.")
                            )
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 24)
                }
                
                // Pinned Bottom Gradient CTA Button (Never scrolls off!)
                Button(action: {
                    FluidHapticsManager.presetSwitched()
                    dismiss()
                }) {
                    HStack(spacing: 8) {
                        Text(String(localized: "Start Swirling"))
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                        Text("•")
                        Image(systemName: "sparkles")
                        Text(String(localized: "Relax"))
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 0.0, green: 0.75, blue: 0.95),
                                Color(red: 0.70, green: 0.20, blue: 0.90)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color.cyan.opacity(0.4), radius: 10, y: 5)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Breathable Emoji-Riddle Style Feature Row
private struct GuideFeatureRow: View {
    let icon: String
    let gradient: [Color]
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Vibrant Circular Icon Badge (Matching Emoji Riddle design)
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 46, height: 46)
                    .shadow(color: gradient.first?.opacity(0.4) ?? .clear, radius: 8, y: 3)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Clean Typography without dark enclosing box
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedStringKey(title))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(LocalizedStringKey(description))
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.72))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)
            }
            
            Spacer()
        }
    }
}
