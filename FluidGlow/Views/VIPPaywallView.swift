import SwiftUI

public struct VIPPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var proManager = ProFeatureManager.shared
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.08, blue: 0.12).ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 80, height: 80)
                            .shadow(color: .orange.opacity(0.5), radius: 16)
                        Image(systemName: "crown.fill")
                            .font(.system(size: 38))
                            .foregroundColor(.white)
                    }
                    
                    Text(String(localized: "Lifetime VIP Pass"))
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(String(localized: "$2.99 One-Time • Forever"))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.yellow)
                }
                
                // Perks List
                VStack(alignment: .leading, spacing: 16) {
                    PerkRow(icon: "nosign", title: String(localized: "100% Ad-Free Forever (Zero Banners & Videos)"))
                    PerkRow(icon: "sparkles", title: String(localized: "Unlock All 6 Premium Fluid Shaders"))
                    PerkRow(icon: "waveform.path", title: String(localized: "Infinite Generative ASMR Soundscapes"))
                    PerkRow(icon: "hand.tap.fill", title: String(localized: "Ultra-Responsive Fluid Micro-Haptics"))
                }
                .padding(20)
                .background(Color(red: 0.11, green: 0.14, blue: 0.19))
                .cornerRadius(18)
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Purchase Button
                VStack(spacing: 12) {
                    Button(action: {
                        Task {
                            let success = await proManager.purchaseVIP()
                            if success {
                                dismiss()
                            }
                        }
                    }) {
                        HStack {
                            if proManager.isPurchasing {
                                ProgressView().tint(.white)
                            } else {
                                Text(String(localized: "Unlock Lifetime VIP • $2.99"))
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(16)
                        .shadow(color: .orange.opacity(0.4), radius: 10, y: 5)
                    }
                    .disabled(proManager.isPurchasing)
                    
                    Button(action: {
                        Task {
                            await proManager.restorePurchases()
                            if proManager.isVIP {
                                dismiss()
                            }
                        }
                    }) {
                        Text(String(localized: "Restore Purchases"))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
    }
}

private struct PerkRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.orange)
                .frame(width: 24)
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white)
            Spacer()
        }
    }
}
