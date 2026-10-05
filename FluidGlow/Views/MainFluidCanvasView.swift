import SwiftUI

public struct MainFluidCanvasView: View {
    @StateObject private var engine = FluidPhysicsEngine()
    @StateObject private var audio = ASMRAudioEngine.shared
    @StateObject private var proManager = ProFeatureManager.shared
    @StateObject private var adManager = AdManager.shared
    
    @State private var showingShaderPicker = false
    @State private var showingSettings = false
    @State private var showingGuide = false
    @AppStorage("fluidglow_seen_guide") private var seenGuide = false
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
                .background(Color.black.ignoresSafeArea()
                    .preferredColorScheme(.dark))
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
                // Top Header: Centered Shader Capsule with Balanced Controls
                HStack(alignment: .center) {
                    // Left: Audio Ambience Toggle (36x36 Circle)
                    Button(action: {
                        audio.isSoundEnabled.toggle()
                        FluidHapticsManager.fluidSwirl(speed: 10)
                    }) {
                        Image(systemName: audio.isSoundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(audio.isSoundEnabled ? AppTheme.primaryAccent : .white.opacity(0.5))
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // Center: Floating Shader Preset Capsule (100% Single Line, Never Wraps)
                    Button(action: {
                        FluidHapticsManager.presetSwitched()
                        showingShaderPicker = true
                    }) {
                        HStack(spacing: 7) {
                            Image(systemName: engine.currentPreset.iconName)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(engine.currentPreset.primaryColor)
                            
                            Text(engine.currentPreset.rawValue)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.white.opacity(0.55))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(engine.currentPreset.primaryColor.opacity(0.5), lineWidth: 1.2)
                        )
                        .shadow(color: engine.currentPreset.primaryColor.opacity(0.2), radius: 6)
                    }
                    
                    Spacer()
                    
                    // Right: Settings Control (36x36 Circle)
                    Button(action: {
                        FluidHapticsManager.presetSwitched()
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 54)
                .opacity(isControlsHidden ? 0.0 : 1.0)
                .animation(.easeInOut(duration: 0.25), value: isControlsHidden)
                
                Spacer()
                
                // Bottom Toolbar (Centered when VIP, balanced when Free)
                HStack {
                    if proManager.isVIP {
                        Spacer()
                    }
                    
                    Button(action: {
                        FluidHapticsManager.burstPulse()
                        engine.clearParticles()
                    }) {
                        Label(String(localized: "Clear Canvas"), systemImage: "arrow.counterclockwise")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            )
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
                            .clipShape(Capsule())
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
        .sheet(isPresented: $showingShaderPicker) {
            ShaderPickerSheet(engine: engine, showingPaywall: $showingPaywall)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(showingPaywall: $showingPaywall)
        }
        .sheet(isPresented: $showingGuide) {
            WelcomeGuideView()
        }
        .sheet(isPresented: $showingPaywall) {
            VIPPaywallView()
        }
        .onAppear {
            let args = ProcessInfo.processInfo.arguments
            if args.contains("-vip_active") {
                engine.setPreset(.cyberpunkPlasma)
            }
            if args.contains("-screenshot_gold") {
                engine.setPreset(.liquidGold)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if args.contains("-screenshot_guide") {
                    showingGuide = true
                    return
                } else if args.contains("-screenshot_picker") {
                    showingShaderPicker = true
                    return
                } else if args.contains("-screenshot_paywall") {
                    showingPaywall = true
                    return
                } else if args.contains("-screenshot_settings") {
                    showingSettings = true
                    return
                }
                
                engine.handleTouchBegan(at: CGPoint(x: 195, y: 400))
                for i in 1...25 {
                    let angle = Double(i) * 0.25
                    let r = Double(i) * 4.5
                    let x = 195.0 + Darwin.cos(angle) * r
                    let y = 400.0 + Darwin.sin(angle) * r
                    engine.handleTouchMoved(to: CGPoint(x: x, y: y))
                }
            }
        }
    }
}
