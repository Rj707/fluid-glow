import SwiftUI
import UIKit
import HSUI

// MARK: - App Theme Modes (Adopted from HSKit HSUI)
public typealias AppThemeMode = HSThemeMode

public struct AppTheme {
    // Current Active Theme State (Synchronized via HSKit HSThemeManager)
    public static var currentTheme: AppThemeMode {
        get {
            if let raw = UserDefaults.standard.string(forKey: HSThemeManager.themeKey) ?? UserDefaults.standard.string(forKey: "fluidglow_theme_mode"),
               let mode = AppThemeMode(rawValue: raw) {
                return mode
            }
            return .modernDark
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "fluidglow_theme_mode")
            UserDefaults.standard.set(newValue.rawValue, forKey: HSThemeManager.themeKey)
            Task { @MainActor in
                HSThemeManager.shared.currentTheme = newValue
            }
        }
    }
    
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
