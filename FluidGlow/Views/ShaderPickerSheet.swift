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
        NavigationView {
            ZStack {
                Color(red: 0.07, green: 0.09, blue: 0.13).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
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
                                HStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(preset.primaryColor.opacity(0.2))
                                            .frame(width: 48, height: 48)
                                        Image(systemName: preset.iconName)
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(preset.primaryColor)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(preset.rawValue)
                                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                                .foregroundColor(.white)
                                            
                                            if preset.isVIPOnly && !proManager.isVIP {
                                                Image(systemName: "crown.fill")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.yellow)
                                            }
                                        }
                                        
                                        Text(preset.isVIPOnly ? String(localized: "VIP Fluid Preset") : String(localized: "Standard Fluid"))
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    if engine.currentPreset == preset {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(preset.primaryColor)
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
                                                Text(String(localized: "Ad 🎬"))
                                                    .font(.system(size: 12, weight: .bold))
                                            }
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(Color.blue.opacity(0.2))
                                            .foregroundColor(.blue)
                                            .cornerRadius(12)
                                        }
                                    }
                                }
                                .padding(16)
                                .background(Color(red: 0.12, green: 0.15, blue: 0.20))
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(engine.currentPreset == preset ? preset.primaryColor : Color.white.opacity(0.08), lineWidth: 1.5)
                                )
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle(String(localized: "Fluid Shaders"))
            .navigationBarTitleDisplayMode(.inline)
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
    }
}
