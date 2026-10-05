import SwiftUI

public struct ShaderPickerSheet: View {
    @ObservedObject var engine: FluidPhysicsEngine
    @Binding var showingPaywall: Bool
    @Environment(\.dismiss) private var dismiss
    @StateObject private var proManager = ProFeatureManager.shared
    @StateObject private var adManager = AdManager.shared
    
    public init(engine: FluidPhysicsEngine, showingPaywall: Binding<Bool>) {
        self.engine = engine
        self._showingPaywall = showingPaywall
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.07, green: 0.09, blue: 0.13).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(FluidShaderPreset.allCases) { preset in
                            let isUnlocked = proManager.isPresetUnlocked(preset)
                            
                            Button(action: {
                                if isUnlocked {
                                    engine.setPreset(preset)
                                    adManager.recordPresetSwitch()
                                    FluidHapticsManager.presetSwitched()
                                    dismiss()
                                } else {
                                    showingPaywall = true
                                }
                            }) {
                                HStack(spacing: 12) {
                                    // Preset Icon
                                    ZStack {
                                        Circle()
                                            .fill(preset.primaryColor.opacity(0.18))
                                            .frame(width: 42, height: 42)
                                        Image(systemName: preset.iconName)
                                            .font(.system(size: 17, weight: .bold))
                                            .foregroundColor(preset.primaryColor)
                                    }
                                    .fixedSize()
                                    
                                    // Title & Category
                                    VStack(alignment: .leading, spacing: 3) {
                                        HStack(spacing: 6) {
                                            Text(preset.rawValue)
                                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                                .foregroundColor(.white)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.65)
                                            
                                            if preset.isVIPOnly && !proManager.isVIP {
                                                Image(systemName: "crown.fill")
                                                    .font(.system(size: 11))
                                                    .foregroundColor(.yellow)
                                                    .fixedSize()
                                            }
                                        }
                                        
                                        Text(preset.isVIPOnly ? String(localized: "VIP Fluid Preset") : String(localized: "Standard Fluid"))
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.gray)
                                            .lineLimit(1)
                                    }
                                    
                                    Spacer(minLength: 6)
                                    
                                    // Status / Action Button
                                    if engine.currentPreset == preset {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(preset.primaryColor)
                                            .fixedSize()
                                    } else if !isUnlocked {
                                        Button(action: {
                                            adManager.showRewardedVideo(for: preset) {
                                                proManager.grantTemporaryPresetUnlock(preset)
                                                engine.setPreset(preset)
                                                dismiss()
                                            }
                                        }) {
                                            HStack(spacing: 4) {
                                                Image(systemName: "play.circle.fill")
                                                    .font(.system(size: 12, weight: .bold))
                                                Text(String(localized: "Ad"))
                                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                            }
                                            .padding(.horizontal, 9)
                                            .padding(.vertical, 5)
                                            .background(Color.blue.opacity(0.2))
                                            .foregroundColor(.blue)
                                            .cornerRadius(12)
                                            .fixedSize()
                                        }
                                        .buttonStyle(.plain)
                                        .fixedSize()
                                    }
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(Color(red: 0.12, green: 0.15, blue: 0.20))
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(engine.currentPreset == preset ? preset.primaryColor : Color.white.opacity(0.08), lineWidth: 1.5)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle(String(localized: "Fluid Shaders"))
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
