import XCTest
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
}
