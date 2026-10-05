import XCTest
@testable import FluidGlow

final class AdManagerTests: XCTestCase {
    @MainActor
    func testAdManagerSingleton() {
        let adManager = AdManager.shared
        XCTAssertNotNil(adManager)
    }
    
    @MainActor
    func testAdManagerTriggerMethods() {
        let adManager = AdManager.shared
        adManager.recordCanvasClear()
        adManager.recordPresetSwitch()
        
        var rewardEarned = false
        adManager.showRewardedVideo(for: .cyberpunkPlasma) {
            rewardEarned = true
        }
        XCTAssertTrue(rewardEarned)
    }
}
