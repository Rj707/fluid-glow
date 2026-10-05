import SwiftUI

public struct WelcomeGuideView: View {
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.07, green: 0.09, blue: 0.13).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(colors: [Color.cyan, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 72, height: 72)
                                    .shadow(color: Color.cyan.opacity(0.4), radius: 12)
                                Image(systemName: "sparkles")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .padding(.top, 10)
                            
                            Text(String(localized: "How to Interact & Relax"))
                                .font(.system(size: 24, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text(String(localized: "Master the gestures that bring fluid light to life"))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                        
                        // Gesture Rows
                        VStack(spacing: 16) {
                            GuideGestureRow(
                                icon: "hand.draw.fill",
                                color: .cyan,
                                title: String(localized: "One-Finger Swirl"),
                                description: String(localized: "Drag across the canvas to draw silky glowing streams that flow with realistic liquid physics.")
                            )
                            
                            GuideGestureRow(
                                icon: "arrow.triangle.2.circlepath",
                                color: .purple,
                                title: String(localized: "Multi-Touch Vortex"),
                                description: String(localized: "Use 2 or 3 fingers simultaneously to create intense swirling whirlpools and gravitational vortexes.")
                            )
                            
                            GuideGestureRow(
                                icon: "hand.tap.fill",
                                color: .orange,
                                title: String(localized: "Tap Stardust Burst"),
                                description: String(localized: "Tap anywhere to trigger an instant radial explosion of glowing particles and soft bubble pops.")
                            )
                            
                            GuideGestureRow(
                                icon: "paintpalette.fill",
                                color: .pink,
                                title: String(localized: "6 Hypnotic Shaders"),
                                description: String(localized: "Switch between Neon Aurora, Liquid Gold, Bioluminescent Deep, Cyberpunk Plasma, and OLED.")
                            )
                            
                            GuideGestureRow(
                                icon: "headphones",
                                color: .green,
                                title: String(localized: "Generative ASMR Audio"),
                                description: String(localized: "Put on headphones! Ambient harmonic chimes and frequencies react to your finger speed.")
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // Bottom Action Button
                        Button(action: {
                            FluidHapticsManager.presetSwitched()
                            dismiss()
                        }) {
                            Text(String(localized: "Start Swirling ✨"))
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(colors: [Color.cyan, Color.blue], startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(16)
                                .shadow(color: Color.cyan.opacity(0.4), radius: 10, y: 5)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "Done")) {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.primaryAccent)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

private struct GuideGestureRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedStringKey(title))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(LocalizedStringKey(description))
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.gray.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(16)
        .background(Color(red: 0.12, green: 0.15, blue: 0.20))
        .cornerRadius(16)
    }
}
