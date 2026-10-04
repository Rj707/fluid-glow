import SwiftUI

public struct FluidParticle: Identifiable {
    public let id: UUID
    public var position: CGPoint
    public var velocity: CGVector
    public var hue: Double
    public var saturation: Double
    public var brightness: Double
    public var size: CGFloat
    public var life: Double // 1.0 down to 0.0
    public var decayRate: Double
    public var blurRadius: CGFloat
    
    public init(
        id: UUID = UUID(),
        position: CGPoint,
        velocity: CGVector,
        hue: Double,
        saturation: Double = 0.9,
        brightness: Double = 1.0,
        size: CGFloat = 24.0,
        life: Double = 1.0,
        decayRate: Double = 0.025,
        blurRadius: CGFloat = 6.0
    ) {
        self.id = id
        self.position = position
        self.velocity = velocity
        self.hue = hue
        self.saturation = saturation
        self.brightness = brightness
        self.size = size
        self.life = life
        self.decayRate = decayRate
        self.blurRadius = blurRadius
    }
}
