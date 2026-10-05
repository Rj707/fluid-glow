import SwiftUI

public struct SettingsView: View {
    @Binding var showingPaywall: Bool
    @Environment(\.dismiss) private var dismiss
    @StateObject private var proManager = ProFeatureManager.shared
    @StateObject private var audio = ASMRAudioEngine.shared
    @AppStorage("fluidglow_haptics_enabled") private var hapticsEnabled = true
    
    public init(showingPaywall: Binding<Bool>) {
        self._showingPaywall = showingPaywall
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.04, green: 0.05, blue: 0.08).ignoresSafeArea()
                
                // Ambient luxury glow
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.0, green: 0.75, blue: 0.95).opacity(0.08),
                        Color(red: 0.75, green: 0.15, blue: 0.85).opacity(0.05),
                        Color.clear
                    ]),
                    center: .top,
                    startRadius: 40,
                    endRadius: 380
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 22) {
                        
                        // MARK: - 1. VIP Hero Card (Spacious, Un-Clipped, Luxury Layout)
                        if !proManager.isVIP {
                            Button(action: {
                                FluidHapticsManager.presetSwitched()
                                dismiss()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    showingPaywall = true
                                }
                            }) {
                                VStack(alignment: .leading, spacing: 14) {
                                    // Header: Crown & Title
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [Color.yellow.opacity(0.3), Color.orange.opacity(0.1)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: 44, height: 44)
                                            
                                            Image(systemName: "crown.fill")
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundColor(.yellow)
                                                .shadow(color: .orange.opacity(0.6), radius: 6)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            HStack(spacing: 6) {
                                                Text(String(localized: "Lifetime VIP Pass"))
                                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                                    .foregroundColor(.white)
                                                
                                                Text("PRO")
                                                    .font(.system(size: 9, weight: .black, design: .rounded))
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(Color.yellow)
                                                    .foregroundColor(.black)
                                                    .clipShape(Capsule())
                                            }
                                            
                                            Text(String(localized: "Unlock Everything Permanently"))
                                                .font(.system(size: 13, weight: .medium))
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                    }
                                    
                                    // Perk Bullets
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(.yellow)
                                            Text(String(localized: "100% Ad-Free (No Banners & Videos)"))
                                                .font(.system(size: 13, weight: .medium))
                                                .foregroundColor(.white.opacity(0.9))
                                        }
                                        HStack(spacing: 8) {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(.yellow)
                                            Text(String(localized: "All 6 Hypnotic Shaders Unlocked"))
                                                .font(.system(size: 13, weight: .medium))
                                                .foregroundColor(.white.opacity(0.9))
                                        }
                                    }
                                    .padding(.leading, 4)
                                    
                                    // Full-Width Action Pill
                                    HStack {
                                        Text(String(localized: "Get VIP Pass"))
                                            .font(.system(size: 14, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                        Spacer(minLength: 8)
                                        Text("$2.99 • Lifetime")
                                            .font(.system(size: 13, weight: .bold, design: .rounded))
                                            .foregroundColor(.white.opacity(0.95))
                                            .lineLimit(1)
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 11)
                                    .background(
                                        LinearGradient(
                                            colors: [Color(red: 1.0, green: 0.55, blue: 0.1), Color(red: 0.95, green: 0.3, blue: 0.1)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                                    .shadow(color: .orange.opacity(0.35), radius: 6, y: 2)
                                }
                                .padding(16)
                                .background(
                                    LinearGradient(
                                        colors: [Color(red: 0.15, green: 0.12, blue: 0.08), Color(red: 0.10, green: 0.12, blue: 0.17)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color.yellow.opacity(0.6), Color.orange.opacity(0.2)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                )
                                .shadow(color: Color.orange.opacity(0.12), radius: 10, y: 4)
                            }
                            .buttonStyle(.plain)
                        } else {
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.green)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(String(localized: "VIP Active"))
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    Text(String(localized: "All Features & Shaders Unlocked"))
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.green.opacity(0.8))
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color.green.opacity(0.12))
                            .cornerRadius(18)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
                            )
                        }
                        
                        // MARK: - 2. Guide Section (Prominently placed right below VIP)
                        VStack(alignment: .leading, spacing: 8) {
                            Text(String(localized: "HOW TO PLAY & GESTURES"))
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1.5)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 6)
                            
                            NavigationLink(destination: WelcomeGuideView(isModal: false)) {
                                HStack(spacing: 12) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color(red: 0.0, green: 0.80, blue: 0.95), Color(red: 0.0, green: 0.45, blue: 0.90)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 36, height: 36)
                                            .shadow(color: Color.cyan.opacity(0.35), radius: 6, y: 2)
                                        
                                        Image(systemName: "questionmark")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(String(localized: "How to Play & Gesture Guide"))
                                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                        Text(String(localized: "Master swirls, bursts & interactive soundscapes"))
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.gray.opacity(0.6))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color(red: 0.08, green: 0.10, blue: 0.15))
                                .cornerRadius(18)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                            .simultaneousGesture(TapGesture().onEnded {
                                FluidHapticsManager.presetSwitched()
                            })
                        }
                        
                        // MARK: - 3. Sensory Experience Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text(String(localized: "SENSORY CONTROLS"))
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1.5)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 6)
                            
                            VStack(spacing: 0) {
                                Toggle(isOn: $audio.isSoundEnabled) {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [Color(red: 0.0, green: 0.85, blue: 0.80), Color(red: 0.0, green: 0.60, blue: 0.75)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: 36, height: 36)
                                                .shadow(color: Color.teal.opacity(0.35), radius: 6, y: 2)
                                            
                                            Image(systemName: audio.isSoundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                                                .font(.system(size: 15, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(String(localized: "Sound Effects"))
                                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                                .foregroundColor(.white)
                                            Text(String(localized: "Generative ASMR harmonic chimes"))
                                                .font(.system(size: 12))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .tint(Color.cyan)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                
                                Divider().background(Color.white.opacity(0.08)).padding(.leading, 64)
                                
                                Toggle(isOn: $hapticsEnabled) {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [Color(red: 0.75, green: 0.25, blue: 0.95), Color(red: 0.55, green: 0.10, blue: 0.85)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: 36, height: 36)
                                                .shadow(color: Color.purple.opacity(0.35), radius: 6, y: 2)
                                            
                                            Image(systemName: "iphone.radiowaves.left.and.right")
                                                .font(.system(size: 15, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(String(localized: "Haptic Feedback"))
                                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                                .foregroundColor(.white)
                                            Text(String(localized: "Fluid dynamic micro-vibrations"))
                                                .font(.system(size: 12))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .tint(Color.purple)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                            .background(Color(red: 0.08, green: 0.10, blue: 0.15))
                            .cornerRadius(18)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                        }
                        
                        // MARK: - 4. About & Legal
                        VStack(spacing: 12) {
                            Button(action: {
                                Task { await proManager.restorePurchases() }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.counterclockwise.circle.fill")
                                        .font(.system(size: 14))
                                    Text(String(localized: "Restore Purchases"))
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                }
                                .foregroundColor(AppTheme.primaryAccent)
                            }
                            .padding(.top, 6)
                            
                            Link(destination: URL(string: "https://rj707.github.io/fluid-glow/")!) {
                                HStack(spacing: 4) {
                                    Text(String(localized: "Privacy Policy & Terms of Service"))
                                        .font(.system(size: 12, weight: .medium))
                                    Image(systemName: "arrow.up.right")
                                        .font(.system(size: 10))
                                }
                                .foregroundColor(.gray.opacity(0.8))
                            }
                            
                            Text("Fluid Glow v1.0.0 (Build 1)")
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundColor(.gray.opacity(0.5))
                                .padding(.top, 4)
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 12)
                }
            }
            .navigationTitle(String(localized: "Settings"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(red: 0.04, green: 0.05, blue: 0.08), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "Done")) { dismiss() }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.primaryAccent)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
