import XCTest
@testable import FluidGlow

final class FluidPhysicsTests: XCTestCase {
    @MainActor
    func testParticleSpawnAndCap() {
        let engine = FluidPhysicsEngine()
        XCTAssertEqual(engine.particleCount, 0)
        
        engine.handleTouchBegan(at: CGPoint(x: 100, y: 100))
        XCTAssertGreaterThan(engine.particleCount, 0)
        
        // Exceed max particles test
        for i in 0..<100 {
            engine.handleTouchMoved(to: CGPoint(x: CGFloat(i * 5), y: CGFloat(i * 5)))
        }
        XCTAssertLessThanOrEqual(engine.particleCount, engine.maxParticles)
    }
    
    @MainActor
    func testPresetSwitching() {
        let engine = FluidPhysicsEngine()
        XCTAssertEqual(engine.currentPreset, .neonAurora)
        
        engine.setPreset(.liquidGold)
        XCTAssertEqual(engine.currentPreset, .liquidGold)
        XCTAssertTrue(engine.currentPreset.isVIPOnly)
    }
    
    @MainActor
    func testClearParticles() {
        let engine = FluidPhysicsEngine()
        engine.handleTouchBegan(at: CGPoint(x: 50, y: 50))
        XCTAssertGreaterThan(engine.particleCount, 0)
        
        engine.clearParticles()
        XCTAssertEqual(engine.particleCount, 0)
        XCTAssertEqual(engine.touchCount, 0)
    }
    
    @MainActor
    func testParticleDecay() {
        let engine = FluidPhysicsEngine()
        engine.handleTouchBegan(at: CGPoint(x: 200, y: 200))
        let initialCount = engine.particleCount
        
        // Simulate 120 frames of decay
        for _ in 0..<120 {
            engine.update(deltaTime: 1.0 / 60.0)
        }
        XCTAssertLessThanOrEqual(engine.particleCount, initialCount)
    }
}

final class ProFeatureManagerTests: XCTestCase {
    @MainActor
    func testVIPProductIdentifier() {
        XCTAssertEqual(ProFeatureManager.lifetimeVIPProductID, "com.saadapps.fluidglow.vip")
    }
    
    @MainActor
    func testPresetUnlockLogic() {
        let manager = ProFeatureManager()
        // Standard presets always unlocked
        XCTAssertTrue(manager.isPresetUnlocked(.neonAurora))
        XCTAssertTrue(manager.isPresetUnlocked(.bioluminescentDeep))
        XCTAssertTrue(manager.isPresetUnlocked(.midnightOLED))
        
        // VIP presets locked by default unless unlocked or temporary granted
        if !manager.isVIP {
            XCTAssertFalse(manager.isPresetUnlocked(.liquidGold))
            manager.grantTemporaryPresetUnlock(.liquidGold)
            XCTAssertTrue(manager.isPresetUnlocked(.liquidGold))
        }
    }
}

final class AdManagerTests: XCTestCase {
    @MainActor
    func testAdManagerSingleton() {
        let adManager = AdManager.shared
        XCTAssertNotNil(adManager)
        XCTAssertTrue(adManager.isInterstitialReady)
        XCTAssertTrue(adManager.isRewardedReady)
    }
}

final class LocalizationTests: XCTestCase {
    let requiredLanguages = ["en", "es", "de", "fr", "ja", "pt-BR"]
    
    func testStringCatalogCompleteness() throws {
        let catalogPath = "/Users/saad/Documents/FluidGlow/FluidGlow/Resources/Localizable.xcstrings"
        guard FileManager.default.fileExists(atPath: catalogPath),
              let data = FileManager.default.contents(atPath: catalogPath),
              let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let strings = json["strings"] as? [String: [String: Any]] else {
            XCTFail("Localizable.xcstrings not found")
            return
        }
        
        let sampleKeys = [
            "Fluid Shaders", "Done", "Settings", "Sound Effects",
            "Haptic Feedback", "Clear Canvas", "VIP Pass", "Lifetime VIP Pass",
            "Restore Purchases", "Privacy Policy & Terms"
        ]
        
        for key in sampleKeys {
            guard let entry = strings[key],
                  let localizations = entry["localizations"] as? [String: [String: Any]] else {
                XCTFail("Missing catalog entry for key '\(key)'")
                continue
            }
            
            for lang in requiredLanguages where lang != "en" {
                guard let unit = localizations[lang]?["stringUnit"] as? [String: Any],
                      let value = unit["value"] as? String, !value.isEmpty else {
                    XCTFail("Missing '\(lang)' translation for key '\(key)'")
                    continue
                }
            }
        }
    }
}
