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
    @State private var restoreControlsTask: Task<Void, Never>? = nil
    @State private var isFlashing = false
    @State private var showSavedToast = false
    @State private var toastMessage = ""
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Fullscreen Canvas with 60/120Hz TimelineView (100% Edge-to-Edge)
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
                .background(Color.black.ignoresSafeArea().preferredColorScheme(.dark))
                .onChange(of: timeline.date) { _, _ in
                    engine.update(deltaTime: 1.0 / 60.0)
                }
            }
            .ignoresSafeArea()
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        hideControlsOnInteraction()
                        engine.handleTouchMoved(to: value.location)
                        let speed = sqrt(pow(value.translation.width, 2) + pow(value.translation.height, 2))
                        audio.playSwirlTone(speed: speed)
                        FluidHapticsManager.fluidSwirl(speed: speed)
                    }
                    .onEnded { _ in
                        engine.handleTouchEnded()
                        scheduleControlsRestore(delay: 0.8)
                    }
            )
            .simultaneousGesture(
                SpatialTapGesture(coordinateSpace: .local)
                    .onEnded { location in
                        engine.handleTouchBegan(at: location.location)
                        audio.playBurstTone()
                        FluidHapticsManager.burstPulse()
                        engine.handleTouchEnded()
                        
                        if isControlsHidden {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isControlsHidden = false
                            }
                        } else {
                            scheduleControlsRestore(delay: 0.8)
                        }
                    }
            )
            
            // Floating UI Overlay
            VStack {
                // Top Header: Unified Balanced HStack with Guaranteed Padding
                HStack(alignment: .center, spacing: 0) {
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
                    
                    Spacer(minLength: 12)
                    
                    // Center: Floating Shader Preset Capsule (Always padded, perfectly centered)
                    Button(action: {
                        FluidHapticsManager.presetSwitched()
                        showingShaderPicker = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: engine.currentPreset.iconName)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(engine.currentPreset.primaryColor)
                            
                            Text(engine.currentPreset.rawValue)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.white.opacity(0.55))
                        }
                        .padding(.horizontal, 13)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(engine.currentPreset.primaryColor.opacity(0.5), lineWidth: 1.2)
                        )
                        .shadow(color: engine.currentPreset.primaryColor.opacity(0.2), radius: 6)
                    }
                    
                    Spacer(minLength: 12)
                    
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
                
                Spacer()
                
                // Bottom Toolbar (Centered when VIP, balanced when Free)
                HStack(alignment: .center) {
                    if proManager.isVIP {
                        Spacer()
                    }
                    
                    Button(action: {
                        saveCurrentWallpaper()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 13, weight: .semibold))
                            Text(String(localized: "Save Wallpaper"))
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                        }
                        .foregroundColor(.white.opacity(0.95))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.18), lineWidth: 1)
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
                                    .lineLimit(1)
                                    .fixedSize(horizontal: true, vertical: false)
                            }
                            .foregroundColor(.white)
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
            }
            .padding(.top, 54)
            .padding(.bottom, 24)
            .opacity(isControlsHidden ? 0.0 : 1.0)
            .animation(.easeInOut(duration: 0.25), value: isControlsHidden)
            .allowsHitTesting(!isControlsHidden)
            
            // Camera Shutter White Flash
            if isFlashing {
                Color.white
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }
            
            // Wallpaper Saved Toast Notification
            if showSavedToast {
                VStack {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(red: 0.1, green: 0.9, blue: 0.6))
                            .font(.system(size: 15, weight: .bold))
                        Text(toastMessage)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 11)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.4), radius: 12, y: 5)
                    .padding(.top, 105)
                    
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(10)
                .allowsHitTesting(false)
            }
        }
        .ignoresSafeArea()
        .sheet(isPresented: $showingShaderPicker) {
            ShaderPickerSheet(engine: engine, showingPaywall: $showingPaywall)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(showingPaywall: $showingPaywall)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingGuide) {
            WelcomeGuideView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingPaywall) {
            VIPPaywallView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
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
    
    // MARK: - Auto-Hide Zen Mode
    private func hideControlsOnInteraction() {
        restoreControlsTask?.cancel()
        restoreControlsTask = nil
        if !isControlsHidden {
            withAnimation(.easeOut(duration: 0.25)) {
                isControlsHidden = true
            }
        }
    }
    
    private func scheduleControlsRestore(delay: TimeInterval = 0.8) {
        restoreControlsTask?.cancel()
        restoreControlsTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            if !Task.isCancelled {
                withAnimation(.easeInOut(duration: 0.35)) {
                    isControlsHidden = false
                }
            }
        }
    }
    
    // MARK: - Wallpaper Snapshot & Export
    private func saveCurrentWallpaper() {
        let size = UIScreen.main.bounds.size
        
        // 1. Audio and Haptics
        audio.playBurstTone()
        FluidHapticsManager.burstPulse()
        
        // 2. Camera Shutter Flash Animation
        withAnimation(.easeOut(duration: 0.08)) {
            isFlashing = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.easeIn(duration: 0.28)) {
                isFlashing = false
            }
        }
        
        // 3. Select particles to draw:
        // Priority 1: Currently live particles on screen
        // Priority 2: User's cached swirl artwork (if they just swirled and lifted their hand)
        // Priority 3: Fullscreen cascading OLED Aurora ribbons (signature procedural artwork)
        let particlesToDraw: [FluidParticle]
        if !engine.particles.isEmpty {
            particlesToDraw = engine.particles
        } else if !engine.lastSwirlArtwork.isEmpty {
            particlesToDraw = engine.lastSwirlArtwork
        } else {
            particlesToDraw = engine.generateSignatureParticles(in: size)
        }
        
        let wallpaperView = ZStack {
            Color.black
            Canvas { context, _ in
                for particle in particlesToDraw {
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
        }
        .frame(width: size.width, height: size.height)
        .ignoresSafeArea()
        
        let renderer = ImageRenderer(content: wallpaperView)
        renderer.scale = UIScreen.main.scale
        
        if let image = renderer.uiImage {
            PhotoLibrarySaver.shared.save(image: image) { success in
                toastMessage = success ? String(localized: "Wallpaper Saved to Photos") : String(localized: "Could not save photo")
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    showSavedToast = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showSavedToast = false
                    }
                }
            }
        }
        
        // 4. Record ad trigger
        adManager.recordWallpaperSaved()
    }
}

// MARK: - Native Photo Album Saver Helper
final class PhotoLibrarySaver: NSObject {
    static let shared = PhotoLibrarySaver()
    private var completion: ((Bool) -> Void)?
    
    func save(image: UIImage, completion: @escaping (Bool) -> Void) {
        self.completion = completion
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(didFinishSaving(_:withError:contextInfo:)), nil)
    }
    
    @objc private func didFinishSaving(_ image: UIImage, withError error: Error?, contextInfo: UnsafeRawPointer) {
        completion?(error == nil)
    }
}
