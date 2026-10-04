import XCTest
@testable import FluidGlow

final class FluidPhysicsTests: XCTestCase {
    @MainActor
    func testParticleSpawnAndCap() {
        let engine = FluidPhysicsEngine()
        XCTAssertEqual(engine.particleCount, 0)
        
        engine.handleTouchBegan(at: CGPoint(x: 100, y: 100))
        XCTAssertGreaterThan(engine.particleCount, 0)
        
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
}
