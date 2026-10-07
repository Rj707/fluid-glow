package com.saadapps.fluidglow

import android.app.Application
import android.content.Context
import com.saadapps.hskit.ads.AdUnits
import com.saadapps.hskit.ads.ConsentController
import com.saadapps.hskit.ads.HsAdController
import com.saadapps.hskit.billing.PlayBillingRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

class FluidApplication : Application() {
    lateinit var graph: AppGraph
        private set

    override fun onCreate() {
        super.onCreate()
        graph = AppGraph(this)
        graph.billing.start()
    }
}

class AppGraph(context: Context) {
    val billing = PlayBillingRepository(context, LIFETIME_PRODUCT)
    val tones = ToneSynth()
    val consent = ConsentController(context)
    val ads = HsAdController(
        context = context,
        units = if (BuildConfig.DEBUG) {
            AdUnits.googleTest
        } else {
            AdUnits.productionOrOff(
                banner = "",
                interstitial = "",
                rewarded = "",
                appOpen = "",
            )
        },
        premium = billing,
        consent = consent,
        onPresentationChanged = { showing ->
            if (showing) tones.pauseForAd() else tones.resumeAfterAd()
        },
    )

    private val prefs = context.applicationContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
    private val _temporaryPresets = MutableStateFlow<Set<String>>(emptySet())
    val temporaryPresets: StateFlow<Set<String>> = _temporaryPresets.asStateFlow()
    private var presetSwitches = 0
    var soundEnabled: Boolean
        get() = prefs.getBoolean(SOUND, true)
        set(value) {
            prefs.edit().putBoolean(SOUND, value).apply()
            tones.enabled = value
        }

    var hapticsEnabled: Boolean
        get() = prefs.getBoolean(HAPTICS, true)
        set(value) {
            prefs.edit().putBoolean(HAPTICS, value).apply()
        }

    fun hasSeenWelcome(): Boolean = prefs.getBoolean(WELCOME, false)

    fun markWelcomeSeen() {
        prefs.edit().putBoolean(WELCOME, true).apply()
    }

    fun isPresetUnlocked(preset: FluidPreset, vip: Boolean): Boolean {
        if (!preset.vipOnly || vip) return true
        return _temporaryPresets.value.contains(preset.name)
    }

    fun grantTemporaryPreset(preset: FluidPreset) {
        _temporaryPresets.value = _temporaryPresets.value + preset.name
    }

    /** Debug builds can still preview the shader-change interstitial. Release builds keep it off. */
    fun notePresetSwitch(vip: Boolean): Boolean {
        if (!BuildConfig.DEBUG || vip) return false
        presetSwitches += 1
        if (presetSwitches < 3) return false
        presetSwitches = 0
        return true
    }

    init {
        tones.enabled = soundEnabled
    }

    companion object {
        const val LIFETIME_PRODUCT = "com.saadapps.fluidglow.vip"
        private const val PREFS = "fluidglow"
        private const val SOUND = "sound_enabled"
        private const val HAPTICS = "haptics_enabled"
        private const val WELCOME = "seen_guide"
    }
}
