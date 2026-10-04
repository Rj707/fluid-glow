import SwiftUI

public struct SettingsView: View {
    @Binding var showingPaywall: Bool
    @State private var showingGuide = false
    @Environment(\.dismiss) private var dismiss
    @StateObject private var proManager = ProFeatureManager.shared
    @StateObject private var audio = ASMRAudioEngine.shared
    @AppStorage("fluidglow_haptics_enabled") private var hapticsEnabled = true
    
    public init(showingPaywall: Binding<Bool>) {
        self._showingPaywall = showingPaywall
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.07, green: 0.09, blue: 0.13).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                                                // Gesture Guide Section
                        Button(action: {
                            FluidHapticsManager.presetSwitched()
                            showingGuide = true
                        }) {
                            HStack {
                                Label(String(localized: "Gesture Guide & How to Play"), systemImage: "questionmark.circle.fill")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(red: 0.12, green: 0.15, blue: 0.20))
                            .cornerRadius(16)
                        }
                        .sheet(isPresented: $showingGuide) {
                            WelcomeGuideView()
                        }
                        
// Sound & Haptics Section
                        VStack(spacing: 0) {
                            Toggle(isOn: $audio.isSoundEnabled) {
                                Label(String(localized: "Sound Effects"), systemImage: "speaker.wave.2.fill")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            .padding()
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            Toggle(isOn: $hapticsEnabled) {
                                Label(String(localized: "Haptic Feedback"), systemImage: "iphone.radiowaves.left.and.right")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            .padding()
                        }
                        .background(Color(red: 0.12, green: 0.15, blue: 0.20))
                        .cornerRadius(16)
                        
                        // VIP Pass Section
                        if !proManager.isVIP {
                            Button(action: {
                                dismiss()
                                showingPaywall = true
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(String(localized: "Lifetime VIP Pass"))
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                        Text(String(localized: "100% Ad-Free Forever (Zero Banners & Videos)"))
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Text(String(localized: "$2.99 One-Time • Forever"))
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.orange)
                                }
                                .padding()
                                .background(Color(red: 0.12, green: 0.15, blue: 0.20))
                                .cornerRadius(16)
                            }
                        } else {
                            HStack {
                                Label(String(localized: "VIP Active • All Features Unlocked"), systemImage: "checkmark.seal.fill")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(.green)
                                Spacer()
                            }
                            .padding()
                            .background(Color.green.opacity(0.12))
                            .cornerRadius(16)
                        }
                        
                        // Footer & Legal
                        VStack(spacing: 12) {
                            Button(action: {
                                Task { await proManager.restorePurchases() }
                            }) {
                                Text(String(localized: "Restore Purchases"))
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppTheme.primaryAccent)
                            }
                            
                            Link(destination: URL(string: "https://rj707.github.io/fluid-glow/")!) {
                                Text(String(localized: "Privacy Policy & Terms"))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.gray)
                            }
                            
                            Text("Fluid Glow v1.0.0 (Build 1)")
                                .font(.system(size: 11))
                                .foregroundColor(.gray.opacity(0.6))
                        }
                        .padding(.top, 16)
                    }
                    .padding(20)
                }
            }
            .navigationTitle(String(localized: "Settings"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "Done")) { dismiss() }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.primaryAccent)
                }
            }
        }
    }
}
