package com.saadapps.fluidglow

import kotlin.math.cos
import kotlin.math.sin
import kotlin.math.sqrt
import kotlin.random.Random

data class FluidPoint(val x: Float, val y: Float)

data class FluidParticle(
    var x: Float,
    var y: Float,
    var vx: Float,
    var vy: Float,
    val hue: Float,
    val saturation: Float,
    val brightness: Float,
    val size: Float,
    var life: Float,
    val decayRate: Float,
)

enum class FluidPreset(
    val label: String,
    val vipOnly: Boolean,
    val baseHue: Float,
    val hueVariance: Float,
    val decayMultiplier: Float,
) {
    NeonAurora("Neon Aurora", false, 0.42f, 0.20f, 1f),
    BioluminescentDeep("Bioluminescent Deep", false, 0.55f, 0.12f, 1f),
    LiquidGold("Liquid Gold", true, 0.12f, 0.06f, 0.75f),
    CyberpunkPlasma("Cyberpunk Plasma", true, 0.82f, 0.18f, 1.3f),
    SolarFlare("Solar Flare", true, 0.05f, 0.08f, 1f),
    MidnightOled("Midnight OLED", false, 0f, 0f, 1f),
}

class FluidPhysicsEngine(
    var maxParticles: Int = 350,
    var viscosity: Double = 0.96,
) {
    val particles = ArrayList<FluidParticle>()
    var currentPreset: FluidPreset = FluidPreset.NeonAurora
        private set

    val particleCount: Int get() = particles.size
    val touchCount: Int get() = lastTouch.size

    private val lastTouch = HashMap<Int, FluidPoint>()

    fun clearParticles() {
        particles.clear()
        lastTouch.clear()
    }

    fun setPreset(preset: FluidPreset) {
        currentPreset = preset
    }

    fun handleTouchBegan(point: FluidPoint, touchId: Int = 0) {
        lastTouch[touchId] = point
        spawnBurst(point, 18)
    }

    fun handleTouchMoved(point: FluidPoint, touchId: Int = 0) {
        val previous = lastTouch[touchId] ?: point
        lastTouch[touchId] = point
        val dx = point.x - previous.x
        val dy = point.y - previous.y
        val speed = sqrt(dx * dx + dy * dy)
        val count = minOf((speed / 4f).toInt() + 2, 8)
        for (index in 0 until count) {
            val t = index.toFloat() / count
            val x = previous.x + (point.x - previous.x) * t
            val y = previous.y + (point.y - previous.y) * t
            val perpX = -dy * 0.25f * (Random.nextFloat() * 2f - 1f)
            val perpY = dx * 0.25f * (Random.nextFloat() * 2f - 1f)
            spawnParticle(
                x = x,
                y = y,
                vx = dx * 0.85f + perpX,
                vy = dy * 0.85f + perpY,
                speed = speed,
            )
        }
    }

    fun handleTouchEnded(touchId: Int = 0) {
        lastTouch.remove(touchId)
    }

    fun update() {
        if (particles.isEmpty()) return
        val alive = ArrayList<FluidParticle>(particles.size)
        val rot = 0.03
        val cosR = cos(rot)
        val sinR = sin(rot)
        for (particle in particles) {
            particle.life -= particle.decayRate
            if (particle.life <= 0f) continue
            particle.x += particle.vx
            particle.y += particle.vy
            particle.vx = (particle.vx * viscosity).toFloat()
            particle.vy = (particle.vy * viscosity).toFloat()
            val rx = particle.vx * cosR - particle.vy * sinR
            val ry = particle.vx * sinR + particle.vy * cosR
            particle.vx = rx.toFloat()
            particle.vy = ry.toFloat()
            alive.add(particle)
        }
        particles.clear()
        particles.addAll(alive)
    }

    private fun spawnParticle(x: Float, y: Float, vx: Float, vy: Float, speed: Float) {
        if (particles.size >= maxParticles) return
        val preset = currentPreset
        val hueShift = if (preset.hueVariance == 0f) {
            0.0
        } else {
            Random.nextDouble(-preset.hueVariance.toDouble(), preset.hueVariance.toDouble())
        }
        var hue = preset.baseHue + hueShift.toFloat()
        if (hue < 0f) hue += 1f
        if (hue > 1f) hue -= 1f
        val saturation = if (preset == FluidPreset.MidnightOled) 0f else Random.nextDouble(0.8, 1.0).toFloat()
        val size = Random.nextDouble(18.0, 34.0).toFloat() * (1f + minOf(speed / 50f, 1f))
        val decay = Random.nextDouble(0.016, 0.028).toFloat() * preset.decayMultiplier
        particles.add(
            FluidParticle(
                x = x,
                y = y,
                vx = vx,
                vy = vy,
                hue = hue,
                saturation = saturation,
                brightness = 1f,
                size = size,
                life = 1f,
                decayRate = decay,
            ),
        )
    }

    private fun spawnBurst(point: FluidPoint, count: Int) {
        repeat(count) {
            val angle = Random.nextDouble(0.0, Math.PI * 2)
            val burst = Random.nextDouble(3.0, 12.0).toFloat()
            spawnParticle(
                x = point.x,
                y = point.y,
                vx = (cos(angle) * burst).toFloat(),
                vy = (sin(angle) * burst).toFloat(),
                speed = burst,
            )
        }
    }
}
