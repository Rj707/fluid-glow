package com.saadapps.fluidglow

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class FluidPhysicsTest {
    @Test
    fun spawnAndCap() {
        val engine = FluidPhysicsEngine()
        assertEquals(0, engine.particleCount)
        engine.handleTouchBegan(FluidPoint(100f, 100f))
        assertTrue(engine.particleCount > 0)
        repeat(100) { index ->
            engine.handleTouchMoved(FluidPoint(index * 5f, index * 5f))
        }
        assertTrue(engine.particleCount <= engine.maxParticles)
    }

    @Test
    fun presetSwitching() {
        val engine = FluidPhysicsEngine()
        assertEquals(FluidPreset.NeonAurora, engine.currentPreset)
        engine.setPreset(FluidPreset.LiquidGold)
        assertEquals(FluidPreset.LiquidGold, engine.currentPreset)
        assertTrue(engine.currentPreset.vipOnly)
    }

    @Test
    fun clearParticles() {
        val engine = FluidPhysicsEngine()
        engine.handleTouchBegan(FluidPoint(50f, 50f))
        assertTrue(engine.particleCount > 0)
        engine.clearParticles()
        assertEquals(0, engine.particleCount)
        assertEquals(0, engine.touchCount)
    }
}
