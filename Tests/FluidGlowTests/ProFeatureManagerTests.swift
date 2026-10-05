import XCTest
import UIKit
@testable import FluidGlow

final class ProFeatureManagerTests: XCTestCase {
    @MainActor
    func testVIPProductIdentifier() {
        XCTAssertEqual(ProFeatureManager.lifetimeVIPProductID, "com.saadapps.fluidglow.vip")
    }
    
    @MainActor
    func testPresetUnlockLogic() {
        let manager = ProFeatureManager()
        XCTAssertTrue(manager.isPresetUnlocked(.neonAurora))
        XCTAssertTrue(manager.isPresetUnlocked(.bioluminescentDeep))
        XCTAssertTrue(manager.isPresetUnlocked(.midnightOLED))
        
        if !manager.isVIP {
            XCTAssertFalse(manager.isPresetUnlocked(.liquidGold))
            manager.grantTemporaryPresetUnlock(.liquidGold)
            XCTAssertTrue(manager.isPresetUnlocked(.liquidGold))
        }
    }
    
    func testAllSFSymbolsAvailability() {
        let allSymbols = [
            "sparkles",
            "water.waves",
            "crown.fill",
            "bolt.fill",
            "flame.fill",
            "moon.stars.fill",
            "hand.draw.fill",
            "arrow.triangle.2.circlepath",
            "hand.tap.fill",
            "paintpalette.fill",
            "headphones",
            "checkmark",
            "chevron.right",
            "checkmark.seal.fill",
            "speaker.wave.2.fill",
            "speaker.slash.fill",
            "iphone.radiowaves.left.and.right",
            "arrow.counterclockwise.circle.fill",
            "arrow.up.right",
            "chevron.down",
            "questionmark",
            "gearshape.fill",
            "checkmark.circle.fill",
            "play.circle.fill",
            "xmark.circle.fill",
            "nosign",
            "waveform.path"
        ]
        
        var missing: [String] = []
        for symbol in allSymbols {
            if UIImage(systemName: symbol) == nil {
                missing.append(symbol)
                print("❌ MISSING SF SYMBOL: \(symbol)")
            } else {
                print("✓ Valid SF Symbol: \(symbol)")
            }
        }
        XCTAssertTrue(missing.isEmpty, "Missing SF Symbols in current runtime: \(missing)")
    }
    
    func testAllPresetIconsAreValidSFSymbols() {
        for preset in FluidShaderPreset.allCases {
            let img = UIImage(systemName: preset.iconName)
            XCTAssertNotNil(img, "Preset \(preset.rawValue) has invalid iconName: '\(preset.iconName)'")
        }
    }
}
