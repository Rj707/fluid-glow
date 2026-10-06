package com.saadapps.fluidglow

import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioTrack
import android.os.SystemClock
import kotlin.math.PI
import kotlin.math.sin

class ToneSynth {
    var enabled: Boolean = true
    private var pausedForAd = false
    private var lastSwirlAt = 0L

    fun pauseForAd() {
        pausedForAd = true
    }

    fun resumeAfterAd() {
        pausedForAd = false
    }

    fun playSwirl(speed: Float) {
        if (!canPlay()) return
        val now = SystemClock.uptimeMillis()
        if (now - lastSwirlAt < 90L) return
        lastSwirlAt = now
        val frequency = 220.0 + speed.coerceIn(0f, 80f) * 6.0
        play(frequency, 70)
    }

    fun playBurst() {
        if (!canPlay()) return
        play(520.0, 50)
    }

    private fun canPlay(): Boolean = enabled && !pausedForAd

    private fun play(frequency: Double, durationMs: Int) {
        val sampleRate = 44100
        val count = sampleRate * durationMs / 1000
        val buffer = ShortArray(count)
        for (index in buffer.indices) {
            val envelope = 1.0 - index.toDouble() / count
            val sample = sin(2.0 * PI * frequency * index / sampleRate) * envelope * 0.22
            buffer[index] = (sample * Short.MAX_VALUE).toInt().toShort()
        }
        val track = AudioTrack.Builder()
            .setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_GAME)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build(),
            )
            .setAudioFormat(
                AudioFormat.Builder()
                    .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                    .setSampleRate(sampleRate)
                    .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                    .build(),
            )
            .setBufferSizeInBytes(buffer.size * 2)
            .setTransferMode(AudioTrack.MODE_STATIC)
            .build()
        track.write(buffer, 0, buffer.size)
        track.setNotificationMarkerPosition(count)
        track.setPlaybackPositionUpdateListener(object : AudioTrack.OnPlaybackPositionUpdateListener {
            override fun onMarkerReached(played: AudioTrack) {
                played.release()
            }

            override fun onPeriodicNotification(played: AudioTrack) = Unit
        })
        track.play()
    }
}
