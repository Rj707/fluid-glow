package com.saadapps.fluidglow

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RadialGradient
import android.graphics.Shader
import android.view.Choreographer
import android.view.MotionEvent
import android.view.View
import kotlin.math.hypot

class FluidCanvasView(context: Context) : View(context) {
    val engine = FluidPhysicsEngine()
    var onBurst: () -> Unit = {}
    var onSwirl: (Float) -> Unit = {}
    var onGestureFinished: () -> Unit = {}

    private val paint = Paint(Paint.ANTI_ALIAS_FLAG)
    private val frameCallback = object : Choreographer.FrameCallback {
        override fun doFrame(frameTimeNanos: Long) {
            engine.update()
            invalidate()
            Choreographer.getInstance().postFrameCallback(this)
        }
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        Choreographer.getInstance().postFrameCallback(frameCallback)
    }

    override fun onDetachedFromWindow() {
        Choreographer.getInstance().removeFrameCallback(frameCallback)
        super.onDetachedFromWindow()
    }

    override fun onWindowVisibilityChanged(visibility: Int) {
        super.onWindowVisibilityChanged(visibility)
        val choreographer = Choreographer.getInstance()
        choreographer.removeFrameCallback(frameCallback)
        if (visibility == VISIBLE) choreographer.postFrameCallback(frameCallback)
    }

    override fun onDraw(canvas: Canvas) {
        canvas.drawColor(Color.BLACK)
        drawParticles(canvas, engine.particles)
    }

    fun captureBitmap() = android.graphics.Bitmap.createBitmap(width.coerceAtLeast(1), height.coerceAtLeast(1), android.graphics.Bitmap.Config.ARGB_8888).also { bitmap ->
        val canvas = Canvas(bitmap)
        canvas.drawColor(Color.BLACK)
        drawParticles(canvas, engine.particles)
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        when (event.actionMasked) {
            MotionEvent.ACTION_DOWN, MotionEvent.ACTION_POINTER_DOWN -> {
                val index = event.actionIndex
                engine.handleTouchBegan(FluidPoint(event.getX(index), event.getY(index)), event.getPointerId(index))
                onBurst()
            }
            MotionEvent.ACTION_MOVE -> {
                for (index in 0 until event.pointerCount) {
                    val id = event.getPointerId(index)
                    val history = event.historySize
                    val previousX = if (history > 0) event.getHistoricalX(index, history - 1) else event.getX(index)
                    val previousY = if (history > 0) event.getHistoricalY(index, history - 1) else event.getY(index)
                    val speed = hypot(event.getX(index) - previousX, event.getY(index) - previousY)
                    engine.handleTouchMoved(FluidPoint(event.getX(index), event.getY(index)), id)
                    if (speed > 0f) onSwirl(speed)
                }
            }
            MotionEvent.ACTION_UP, MotionEvent.ACTION_POINTER_UP, MotionEvent.ACTION_CANCEL -> {
                engine.handleTouchEnded(event.getPointerId(event.actionIndex))
                if (event.pointerCount <= 1) onGestureFinished()
            }
        }
        return true
    }

    private fun drawParticles(canvas: Canvas, particles: List<FluidParticle>) {
        for (particle in particles) {
            val radius = particle.size / 2f
            val color = Color.HSVToColor((particle.life * 255).toInt().coerceIn(0, 255), floatArrayOf(particle.hue * 360f, particle.saturation, particle.brightness))
            paint.shader = RadialGradient(
                particle.x,
                particle.y,
                radius.coerceAtLeast(1f),
                color,
                Color.TRANSPARENT,
                Shader.TileMode.CLAMP,
            )
            canvas.drawCircle(particle.x, particle.y, radius, paint)
        }
    }
}
