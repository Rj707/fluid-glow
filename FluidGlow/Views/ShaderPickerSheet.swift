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
                
                VStack(spacing: 0) {
                    ScrollView {
                        Group {
                            if UIDevice.isTablet {
                                LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                                    ForEach(FluidShaderPreset.allCases) { preset in
                                        presetRow(preset: preset, isTablet: true)
                                    }
                                }
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(FluidShaderPreset.allCases) { preset in
                                        presetRow(preset: preset, isTablet: false)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, UIDevice.isTablet ? 24 : 20)
                        .padding(.vertical, 16)
                        .tabletContainer(maxWidth: 680)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle(String(localized: "Fluid Shaders"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(red: 0.07, green: 0.09, blue: 0.13), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "Done")) {
                        dismiss()
                    }
                    .font(.system(size: UIDevice.isTablet ? 18 : 16, weight: .bold))
                    .foregroundColor(AppTheme.primaryAccent)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    @ViewBuilder
    private func presetRow(preset: FluidShaderPreset, isTablet: Bool) -> some View {
        let isUnlocked = proManager.isPresetUnlocked(preset)
        
        Button(action: {
            if isUnlocked {
                engine.setPreset(preset)
                adManager.recordPresetSwitch()
                FluidHapticsManager.presetSwitched()
                dismiss()
            } else {
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showingPaywall = true
                }
            }
        }) {
            if isTablet {
                // Tablet 2-Column Proportional Card: Icon + Action in top row, full-width labels below
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .center) {
                        ZStack {
                            Circle()
                                .fill(preset.primaryColor.opacity(0.18))
                                .frame(width: 44, height: 44)
                            Image(systemName: preset.iconName)
                                .font(.system(size: 19, weight: .bold))
                                .foregroundColor(preset.primaryColor)
                        }
                        
                        Spacer()
                        
                        if engine.currentPreset == preset {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24))
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
                                        .font(.system(size: 13, weight: .bold))
                                    Text(String(localized: "Ad"))
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .cornerRadius(12)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(preset.rawValue)
                            .font(.system(size: 15.5, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                        
                        HStack(spacing: 4) {
                            if preset.isVIPOnly && !proManager.isVIP {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.yellow)
                            }
                            
                            Text(preset.isVIPOnly ? String(localized: "VIP Fluid Preset") : String(localized: "Standard Fluid"))
                                .font(.system(size: 12.5, weight: .medium))
                                .foregroundColor(preset.isVIPOnly && !proManager.isVIP ? Color.yellow.opacity(0.9) : .gray)
                                .lineLimit(1)
                        }
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(red: 0.12, green: 0.15, blue: 0.20))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(engine.currentPreset == preset ? preset.primaryColor : Color.white.opacity(0.08), lineWidth: 1.5)
                )
            } else {
                // Phone: 100% Untouched original horizontal row layout
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
                        Text(preset.rawValue)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                        
                        HStack(spacing: 5) {
                            if preset.isVIPOnly && !proManager.isVIP {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.yellow)
                            }
                            
                            Text(preset.isVIPOnly ? String(localized: "VIP Fluid Preset") : String(localized: "Standard Fluid"))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(preset.isVIPOnly && !proManager.isVIP ? Color.yellow.opacity(0.9) : .gray)
                                .lineLimit(1)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
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
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.12, green: 0.15, blue: 0.20))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(engine.currentPreset == preset ? preset.primaryColor : Color.white.opacity(0.08), lineWidth: 1.5)
                )
            }
        }
        .buttonStyle(.plain)
    }
}
