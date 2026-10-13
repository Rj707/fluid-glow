package com.saadapps.fluidglow

import android.content.Context
import com.google.firebase.analytics.FirebaseAnalytics
import com.google.firebase.crashlytics.FirebaseCrashlytics

/**
 * Crash reports stay on. Usage analytics stay off until the privacy check allows them.
 */
object AppReports {
    private lateinit var analytics: FirebaseAnalytics

    fun start(context: Context) {
        analytics = FirebaseAnalytics.getInstance(context.applicationContext)
        analytics.setAnalyticsCollectionEnabled(false)
    }

    fun setCollectionAllowed(allowed: Boolean) {
        if (!::analytics.isInitialized) return
        analytics.setAnalyticsCollectionEnabled(allowed)
    }

    fun wallpaperSaved() = log("wallpaper_saved")

    fun presetSelected(presetName: String) {
        if (!::analytics.isInitialized) return
        val bundle = android.os.Bundle().apply {
            putString("preset_name", presetName)
        }
        analytics.logEvent("preset_selected", bundle)
    }

    fun vipUnlocked() = log("vip_unlocked")

    fun recordFailure(code: String) {
        FirebaseCrashlytics.getInstance().recordException(IllegalStateException(code))
    }

    fun recordException(throwable: Throwable) {
        FirebaseCrashlytics.getInstance().recordException(throwable)
    }

    fun testCrash() {
        if (BuildConfig.DEBUG) {
            throw RuntimeException("Debug test crash for Firebase Crashlytics")
        }
    }

    private fun log(name: String) {
        if (!::analytics.isInitialized) return
        analytics.logEvent(name, null)
    }
}
