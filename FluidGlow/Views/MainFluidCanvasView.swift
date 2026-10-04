import SwiftUI

public struct MainFluidCanvasView: View {
    @StateObject private var engine = FluidPhysicsEngine()
    @StateObject private var audio = ASMRAudioEngine.shared
    @StateObject private var proManager = ProFeatureManager.shared
    @StateObject private var adManager = AdManager.shared
    
    @State private var showingShaderPicker = false
    @State private var showingSettings = false
    @State private var showingPaywall = false
    @State private var isControlsHidden = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Fullscreen Canvas with 60/120Hz TimelineView
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    for particle in engine.particles {
                        let rect = CGRect(
                            x: particle.position.x - particle.size / 2,
                            y: particle.position.y - particle.size / 2,
                            width: particle.size,
                            height: particle.size
                        )
                        
                        let color = Color(
                            hue: particle.hue,
                            saturation: particle.saturation,
                            brightness: particle.brightness,
                            opacity: particle.life
                        )
                        
                        context.drawLayer { ctx in
                            ctx.addFilter(.blur(radius: particle.blurRadius))
                            ctx.fill(Path(ellipseIn: rect), with: .color(color))
                        }
                    }
                }
                .background(Color.black.ignoresSafeArea())
                .onChange(of: timeline.date) { _ in
                    engine.update(deltaTime: 1.0 / 60.0)
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        engine.handleTouchMoved(to: value.location)
                        let speed = sqrt(pow(value.translation.width, 2) + pow(value.translation.height, 2))
                        audio.playSwirlTone(speed: speed)
                        FluidHapticsManager.fluidSwirl(speed: speed)
                    }
                    .onEnded { _ in
                        engine.handleTouchEnded()
                    }
            )
            .simultaneousGesture(
                SpatialTapGesture(coordinateSpace: .local)
                    .onEnded { location in
                        engine.handleTouchBegan(at: location.location)
                        audio.playBurstTone()
                        FluidHapticsManager.burstPulse()
                    }
            )
            
            // Floating UI Overlay
            VStack {
                // Top Header Pill
                HStack {
                    Button(action: {
                        FluidHapticsManager.presetSwitched()
                        showingShaderPicker = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: engine.currentPreset.iconName)
                                .foregroundColor(engine.currentPreset.primaryColor)
                            Text(engine.currentPreset.rawValue)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(engine.currentPreset.primaryColor.opacity(0.4), lineWidth: 1)
                        )
                    }
                    
                    Spacer()
                    
                    // Sound & Settings Controls
                    HStack(spacing: 12) {
                        Button(action: {
                            audio.isSoundEnabled.toggle()
                            FluidHapticsManager.fluidSwirl(speed: 10)
                        }) {
                            Image(systemName: audio.isSoundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(audio.isSoundEnabled ? AppTheme.primaryAccent : .white.opacity(0.5))
                                .frame(width: 36, height: 36)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        
                        Button(action: {
                            FluidHapticsManager.presetSwitched()
                            showingSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 54)
                .opacity(isControlsHidden ? 0.0 : 1.0)
                .animation(.easeInOut(duration: 0.25), value: isControlsHidden)
                
                Spacer()
                
                // Bottom Toolbar (Clear & VIP Paywall)
                HStack {
                    Button(action: {
                        FluidHapticsManager.burstPulse()
                        engine.clearParticles()
                    }) {
                        Label(String(localized: "Clear Canvas"), systemImage: "arrow.counterclockwise")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(.ultraThinMaterial)
                            .cornerRadius(20)
                    }
                    
                    Spacer()
                    
                    if !proManager.isVIP {
                        Button(action: {
                            FluidHapticsManager.presetSwitched()
                            showingPaywall = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.yellow)
                                Text(String(localized: "VIP Pass"))
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(20)
                            .shadow(color: .orange.opacity(0.4), radius: 6, x: 0, y: 3)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                .opacity(isControlsHidden ? 0.0 : 1.0)
                .animation(.easeInOut(duration: 0.25), value: isControlsHidden)
            }
        }
        .ignoresSafeArea()
        .sheet(isPresented: $showingShaderPicker) {
            ShaderPickerSheet(engine: engine, showingPaywall: $showingPaywall)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(showingPaywall: $showingPaywall)
        }
        .sheet(isPresented: $showingPaywall) {
            VIPPaywallView()
        }
    }
}
