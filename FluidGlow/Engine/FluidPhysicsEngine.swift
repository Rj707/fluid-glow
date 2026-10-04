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
    }
    
    public func setPreset(_ preset: FluidShaderPreset) {
        currentPreset = preset
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
            let vel = CGVector(dx: cos(angle) * burstSpeed, dy: sin(angle) * burstSpeed)
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
                let rx = p.velocity.dx * cos(rotAngle) - p.velocity.dy * sin(rotAngle)
                let ry = p.velocity.dx * sin(rotAngle) + p.velocity.dy * cos(rotAngle)
                p.velocity.dx = rx
                p.velocity.dy = ry
                
                aliveParticles.append(p)
            }
        }
        
        particles = aliveParticles
        particleCount = particles.count
    }
}
