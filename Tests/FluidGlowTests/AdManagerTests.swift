import XCTest
@testable import FluidGlow

final class AdManagerTests: XCTestCase {
    @MainActor
    func testAdManagerSingleton() {
        let adManager = AdManager.shared
        XCTAssertNotNil(adManager)
        XCTAssertTrue(adManager.isInterstitialReady)
        XCTAssertTrue(adManager.isRewardedReady)
    }
}
