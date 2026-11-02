import SwiftUI

public struct VIPPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var proManager = ProFeatureManager.shared
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.07, blue: 0.11).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Crown & Hero Headline
                VStack(spacing: UIDevice.isTablet ? 6 : 4) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.yellow.opacity(0.28), Color.orange.opacity(0.12)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: UIDevice.isTablet ? 54 : 44, height: UIDevice.isTablet ? 54 : 44)
                            .shadow(color: .orange.opacity(0.4), radius: 8)
                        
                        Image(systemName: "crown.fill")
                            .font(.system(size: UIDevice.isTablet ? 24 : 20, weight: .bold))
                            .foregroundColor(.yellow)
                    }
                    
                    Text(String(localized: "Lifetime VIP Pass"))
                        .font(.system(size: UIDevice.isTablet ? 24 : 20, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(String(localized: "$2.99 One-Time • Forever"))
                        .font(.system(size: UIDevice.isTablet ? 15.5 : 13, weight: .bold, design: .rounded))
                        .foregroundColor(.yellow)
                }
                .padding(.top, UIDevice.isTablet ? 32 : 24)
                
                Spacer(minLength: 8)
                
                // Perks Card (100% visible, single-line crispness, zero overlap)
                VStack(alignment: .leading, spacing: UIDevice.isTablet ? 14 : 10) {
                    PerkRow(
                        icon: "nosign",
                        title: String(localized: "100% Ad-Free Forever"),
                        subtitle: String(localized: "Zero banner ads, popups, or interruptions"),
                        isTablet: UIDevice.isTablet
                    )
                    PerkRow(
                        icon: "sparkles",
                        title: String(localized: "All 6 Hypnotic Shaders"),
                        subtitle: String(localized: "Liquid Gold, Cyberpunk Plasma & Solar Flare"),
                        isTablet: UIDevice.isTablet
                    )
                    PerkRow(
                        icon: "waveform.path",
                        title: String(localized: "Generative ASMR Audio"),
                        subtitle: String(localized: "Uncapped interactive harmonic soundscapes"),
                        isTablet: UIDevice.isTablet
                    )
                    PerkRow(
                        icon: "hand.tap.fill",
                        title: String(localized: "Fluid Dynamic Haptics"),
                        subtitle: String(localized: "Micro-vibrations synced to your touch"),
                        isTablet: UIDevice.isTablet
                    )
                }
                .padding(.vertical, UIDevice.isTablet ? 16 : 12)
                .padding(.horizontal, UIDevice.isTablet ? 18 : 14)
                .background(Color(red: 0.09, green: 0.12, blue: 0.17))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
                .padding(.horizontal, UIDevice.isTablet ? 24 : 20)
                
                Spacer(minLength: 12)
                
                // Bottom Action Area & Legal Links
                VStack(spacing: UIDevice.isTablet ? 12 : 8) {
                    Button(action: {
                        Task {
                            let success = await proManager.purchaseVIP()
                            if success {
                                dismiss()
                            } else if let err = proManager.errorMessage {
                                alertMessage = err
                                showingAlert = true
                            }
                        }
                    }) {
                        HStack {
                            if proManager.isPurchasing {
                                ProgressView().tint(.white)
                            } else {
                                Text(String(localized: "Unlock Lifetime VIP • $2.99"))
                                    .font(.system(size: UIDevice.isTablet ? 18.5 : 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, UIDevice.isTablet ? 17 : 14)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 1.0, green: 0.55, blue: 0.1), Color(red: 0.95, green: 0.3, blue: 0.1)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: .orange.opacity(0.35), radius: 10, y: 4)
                    }
                    .disabled(proManager.isPurchasing)
                    
                    HStack(spacing: UIDevice.isTablet ? 20 : 16) {
                        Button(action: {
                            Task {
                                await proManager.restorePurchases()
                                if proManager.isVIP {
                                    dismiss()
                                } else if let err = proManager.errorMessage {
                                    alertMessage = err
                                    showingAlert = true
                                }
                            }
                        }) {
                            Text(String(localized: "Restore Purchases"))
                                .font(.system(size: UIDevice.isTablet ? 14 : 12, weight: .semibold, design: .rounded))
                                .foregroundColor(.gray)
                        }
                        
                        Text("•")
                            .foregroundColor(.gray.opacity(0.4))
                        
                        Link(destination: URL(string: "https://rj707.github.io/fluid-glow/")!) {
                            Text(String(localized: "Terms & Privacy"))
                                .font(.system(size: UIDevice.isTablet ? 14 : 12, weight: .medium, design: .rounded))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, UIDevice.isTablet ? 24 : 20)
                .padding(.bottom, UIDevice.isTablet ? 28 : 22)
            }
            .tabletContainer(maxWidth: 680)
        }
        .overlay(alignment: .topTrailing) {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: UIDevice.isTablet ? 28 : 24, weight: .semibold))
                    .foregroundColor(.white.opacity(0.55))
                    .frame(width: UIDevice.isTablet ? 48 : 44, height: UIDevice.isTablet ? 48 : 44)
                    .contentShape(Circle())
            }
            .padding(.top, 18)
            .padding(.trailing, 18)
        }
        .preferredColorScheme(.dark)
        .alert(String(localized: "VIP Store"), isPresented: $showingAlert) {
            Button(String(localized: "OK"), role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
}

private struct PerkRow: View {
    let icon: String
    let title: String
    let subtitle: String
    var isTablet: Bool = false
    
    var body: some View {
        HStack(alignment: .center, spacing: isTablet ? 14 : 12) {
            Image(systemName: icon)
                .font(.system(size: isTablet ? 18 : 15, weight: .bold))
                .foregroundColor(.orange)
                .frame(width: isTablet ? 24 : 20, height: isTablet ? 24 : 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: isTablet ? 15.5 : 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(subtitle)
                    .font(.system(size: isTablet ? 13 : 11, weight: .regular))
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            Spacer()
        }
    }
}
