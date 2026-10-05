import SwiftUI
import Combine

@MainActor
public final class FluidPhysicsEngine: ObservableObject {
    @Published public var particles: [FluidParticle] = []
    @Published public var currentPreset: FluidShaderPreset = .neonAurora
    @Published public var touchCount: Int = 0
    @Published public var particleCount: Int = 0
    
    public var maxParticles: Int = 350
    public var viscosity: Double = 0.96 // Air / fluid drag damping
    public var vortexStrength: Double = 0.15
    
    private var lastTouchPositions: [Int: CGPoint] = [:]
    
    public init() {}
    
    public func clearParticles() {
        particles.removeAll()
        particleCount = 0
        lastTouchPositions.removeAll()
        touchCount = 0
        lastSwirlArtwork.removeAll()
    }
    
    public func setPreset(_ preset: FluidShaderPreset) {
        currentPreset = preset
        lastSwirlArtwork.removeAll()
    }
    
    public func handleTouchBegan(at point: CGPoint, touchId: Int = 0) {
        lastTouchPositions[touchId] = point
        touchCount = lastTouchPositions.count
        // Spawn radial burst of particles on tap
        spawnBurst(at: point, count: 18)
    }
    
    public func handleTouchMoved(to point: CGPoint, touchId: Int = 0) {
        let prevPoint = lastTouchPositions[touchId] ?? point
        lastTouchPositions[touchId] = point
        touchCount = lastTouchPositions.count
        
        let dx = point.x - prevPoint.x
        let dy = point.y - prevPoint.y
        let velocity = CGVector(dx: dx * 0.85, dy: dy * 0.85)
        let speed = sqrt(dx * dx + dy * dy)
        
        // Spawn particles along the stream trail
        let count = min(Int(speed / 4.0) + 2, 8)
        for i in 0..<count {
            let t = Double(i) / Double(count)
            let interpX = prevPoint.x + (point.x - prevPoint.x) * t
            let interpY = prevPoint.y + (point.y - prevPoint.y) * t
            
            // Perpendicular swirl vector
            let perpX = -dy * 0.25 * Double.random(in: -1.0...1.0)
            let perpY = dx * 0.25 * Double.random(in: -1.0...1.0)
            
            let pVel = CGVector(dx: velocity.dx + perpX, dy: velocity.dy + perpY)
            spawnParticle(at: CGPoint(x: interpX, y: interpY), velocity: pVel, speed: speed)
        }
    }
    
    public func handleTouchEnded(touchId: Int = 0) {
        lastTouchPositions.removeValue(forKey: touchId)
        touchCount = lastTouchPositions.count
    }
    
    private func spawnParticle(at point: CGPoint, velocity: CGVector, speed: CGFloat) {
        guard particles.count < maxParticles else { return }
        
        let hueShift = Double.random(in: -currentPreset.hueVariance...currentPreset.hueVariance)
        var hue = currentPreset.baseHue + hueShift
        if hue < 0.0 { hue += 1.0 }
        if hue > 1.0 { hue -= 1.0 }
        
        let sat = currentPreset == .midnightOLED ? 0.0 : Double.random(in: 0.8...1.0)
        let size = CGFloat.random(in: 18...34) * (1.0 + min(speed / 50.0, 1.0))
        let decay = (Double.random(in: 0.016...0.028)) * currentPreset.particleDecayMultiplier
        
        let particle = FluidParticle(
            position: point,
            velocity: velocity,
            hue: hue,
            saturation: sat,
            brightness: 1.0,
            size: size,
            life: 1.0,
            decayRate: decay,
            blurRadius: currentPreset == .midnightOLED ? 3.0 : 8.0
        )
        particles.append(particle)
        particleCount = particles.count
    }
    
    private func spawnBurst(at point: CGPoint, count: Int) {
        for _ in 0..<count {
            let angle = Double.random(in: 0...(2 * .pi))
            let burstSpeed = CGFloat.random(in: 3.0...12.0)
            let vel = CGVector(dx: CGFloat(Darwin.cos(angle)) * burstSpeed, dy: CGFloat(Darwin.sin(angle)) * burstSpeed)
            spawnParticle(at: point, velocity: vel, speed: burstSpeed)
        }
    }
    
    public func update(deltaTime: Double) {
        guard !particles.isEmpty else { return }
        
        var aliveParticles: [FluidParticle] = []
        aliveParticles.reserveCapacity(particles.count)
        
        for var p in particles {
            p.life -= p.decayRate
            if p.life > 0.0 {
                // Apply velocity and drag
                p.position.x += p.velocity.dx
                p.position.y += p.velocity.dy
                
                p.velocity.dx *= viscosity
                p.velocity.dy *= viscosity
                
                // Slight vortex rotation
                let rotAngle = 0.03
                let rx = p.velocity.dx * CGFloat(Darwin.cos(rotAngle)) - p.velocity.dy * CGFloat(Darwin.sin(rotAngle))
                let ry = p.velocity.dx * CGFloat(Darwin.sin(rotAngle)) + p.velocity.dy * CGFloat(Darwin.cos(rotAngle))
                p.velocity.dx = rx
                p.velocity.dy = ry
                
                aliveParticles.append(p)
            }
        }
        
        particles = aliveParticles
        particleCount = particles.count
        
        // Cache the user's active fluid swirl so it can be saved as wallpaper even after decay
        if particles.count >= 20 {
            lastSwirlArtwork = particles.map { p in
                var copy = p
                copy.life = max(p.life, 0.88)
                return copy
            }
        }
    }
    
    public var lastSwirlArtwork: [FluidParticle] = []
    
    public func generateSignatureParticles(in size: CGSize) -> [FluidParticle] {
        var generated: [FluidParticle] = []
        let width = size.width
        let height = size.height
        
        // 3 cascading fluid ribbons flowing diagonally across the full OLED screen
        let ribbonCount = 3
        let pointsPerRibbon = 120
        
        for r in 0..<ribbonCount {
            let xOffset = width * (0.28 + Double(r) * 0.22)
            let phaseOffset = Double(r) * 1.4
            let ribbonHueShift = (Double(r) - 1.0) * currentPreset.hueVariance * 0.8
            
            for i in 0..<pointsPerRibbon {
                let t = Double(i) / Double(pointsPerRibbon)
                let y = t * (height + 80.0) - 40.0
                
                // Fluid harmonic wave curves
                let wave1 = Darwin.sin(t * .pi * 2.5 + phaseOffset) * (width * 0.22)
                let wave2 = Darwin.cos(t * .pi * 1.5 - phaseOffset) * (width * 0.12)
                let x = xOffset + CGFloat(wave1 + wave2)
                
                var hue = currentPreset.baseHue + ribbonHueShift + (t * currentPreset.hueVariance * 1.2)
                if hue < 0.0 { hue += 1.0 }
                if hue > 1.0 { hue -= 1.0 }
                
                let sat = currentPreset == .midnightOLED ? 0.0 : Double.random(in: 0.85...1.0)
                let sizeVariation = CGFloat(Darwin.sin(t * .pi)) * 16.0 + CGFloat.random(in: 24...38)
                let blur = currentPreset == .midnightOLED ? 3.0 : CGFloat.random(in: 6.0...10.0)
                
                let p = FluidParticle(
                    position: CGPoint(x: x, y: y),
                    velocity: .zero,
                    hue: hue,
                    saturation: sat,
                    brightness: 1.0,
                    size: sizeVariation,
                    life: Double.random(in: 0.85...1.0),
                    decayRate: 0.01,
                    blurRadius: blur
                )
                generated.append(p)
                
                // Soft ambient stardust glow nodes along the stream
                if i % 3 == 0 {
                    let spreadX = CGFloat.random(in: -30...30)
                    let spreadY = CGFloat.random(in: -20...20)
                    let star = FluidParticle(
                        position: CGPoint(x: x + spreadX, y: y + spreadY),
                        velocity: .zero,
                        hue: hue,
                        saturation: sat * 0.8,
                        brightness: 0.9,
                        size: CGFloat.random(in: 12...22),
                        life: Double.random(in: 0.6...0.9),
                        decayRate: 0.01,
                        blurRadius: blur * 1.3
                    )
                    generated.append(star)
                }
            }
        }
        return generated
    }
}
