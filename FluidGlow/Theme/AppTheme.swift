import SwiftUI

public enum AppThemeMode: String, CaseIterable, Identifiable {
    case system = "System (Match Device)"
    case modernDark = "Modern Dark"
    case midnightOLED = "Midnight OLED"
    case cyberNeon = "Cyber Neon"
    case minimalLight = "Minimal Light"
    
    public var id: String { rawValue }
}

public enum AppTheme {
    @AppStorage("fluidglow_theme_mode") public static var currentTheme: AppThemeMode = .modernDark
    
    public static var primaryAccent: Color {
        Color(red: 0.1, green: 0.85, blue: 0.95)
    }
    
    public static var secondaryAccent: Color {
        Color(red: 0.9, green: 0.2, blue: 0.6)
    }
    
    public static func background(for mode: AppThemeMode) -> Color {
        switch mode {
        case .system:
            return Color(UIColor.systemBackground)
        case .modernDark:
            return Color(red: 0.05, green: 0.07, blue: 0.10)
        case .midnightOLED:
            return Color.black
        case .cyberNeon:
            return Color(red: 0.08, green: 0.03, blue: 0.12)
        case .minimalLight:
            return Color(red: 0.96, green: 0.97, blue: 0.99)
        }
    }
    
    public static func cardBackground(for mode: AppThemeMode) -> Color {
        switch mode {
        case .system:
            return Color(UIColor.secondarySystemBackground)
        case .modernDark:
            return Color(red: 0.11, green: 0.14, blue: 0.19)
        case .midnightOLED:
            return Color(red: 0.10, green: 0.10, blue: 0.10)
        case .cyberNeon:
            return Color(red: 0.14, green: 0.08, blue: 0.20)
        case .minimalLight:
            return Color.white
        }
    }
    
    public static func textPrimary(for mode: AppThemeMode) -> Color {
        switch mode {
        case .minimalLight: return Color.black
        default: return Color.white
        }
    }
    
    public static func textSecondary(for mode: AppThemeMode) -> Color {
        switch mode {
        case .minimalLight: return Color.gray
        default: return Color(red: 0.65, green: 0.72, blue: 0.80)
        }
    }
}
