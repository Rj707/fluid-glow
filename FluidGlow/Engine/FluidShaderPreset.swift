import SwiftUI

public enum FluidShaderPreset: String, CaseIterable, Identifiable {
    case neonAurora = "Neon Aurora"
    case bioluminescentDeep = "Bioluminescent Deep"
    case liquidGold = "Liquid Gold"
    case cyberpunkPlasma = "Cyberpunk Plasma"
    case solarFlare = "Solar Flare"
    case midnightOLED = "Midnight OLED"
    
    public var id: String { rawValue }
    
    public var isVIPOnly: Bool {
        switch self {
        case .neonAurora, .bioluminescentDeep, .midnightOLED:
            return false
        case .liquidGold, .cyberpunkPlasma, .solarFlare:
            return true
        }
    }
    
    public var iconName: String {
        switch self {
        case .neonAurora: return "sparkles"
        case .bioluminescentDeep: return "water.waves"
        case .liquidGold: return "crown.fill"
        case .cyberpunkPlasma: return "bolt.fill"
        case .solarFlare: return "flame.fill"
        case .midnightOLED: return "moon.stars.fill"
        }
    }
    
    public var primaryColor: Color {
        switch self {
        case .neonAurora: return Color(red: 0.1, green: 0.9, blue: 0.6)
        case .bioluminescentDeep: return Color(red: 0.0, green: 0.7, blue: 0.95)
        case .liquidGold: return Color(red: 1.0, green: 0.8, blue: 0.1)
        case .cyberpunkPlasma: return Color(red: 0.9, green: 0.1, blue: 0.7)
        case .solarFlare: return Color(red: 1.0, green: 0.35, blue: 0.1)
        case .midnightOLED: return Color.white
        }
    }
    
    public var baseHue: Double {
        switch self {
        case .neonAurora: return 0.42 // Green-Cyan
        case .bioluminescentDeep: return 0.55 // Deep Blue-Cyan
        case .liquidGold: return 0.12 // Golden Amber
        case .cyberpunkPlasma: return 0.82 // Magenta-Violet
        case .solarFlare: return 0.05 // Fiery Red-Orange
        case .midnightOLED: return 0.0 // Neutral White
        }
    }
    
    public var hueVariance: Double {
        switch self {
        case .neonAurora: return 0.20
        case .bioluminescentDeep: return 0.12
        case .liquidGold: return 0.06
        case .cyberpunkPlasma: return 0.18
        case .solarFlare: return 0.08
        case .midnightOLED: return 0.0
        }
    }
    
    public var particleDecayMultiplier: Double {
        switch self {
        case .liquidGold: return 0.75 // Lingers longer, more viscous
        case .cyberpunkPlasma: return 1.3 // Faster, energetic bursts
        default: return 1.0
        }
    }
}
