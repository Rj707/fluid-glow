package com.saadapps.fluidglow

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.ProcessLifecycleOwner

class MainActivity : ComponentActivity() {
    private var foregroundVisits = 0
    private var welcomeBlockingAds = true

    override fun onCreate(savedInstanceState: Bundle?) {
        installSplashScreen()
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        val graph = (application as FluidApplication).graph
        welcomeBlockingAds = !graph.hasSeenWelcome()
        graph.consent.gather(this) {
            graph.ads.startIfAllowed()
        }
        ProcessLifecycleOwner.get().lifecycle.addObserver(
            LifecycleEventObserver { _, event ->
                if (event != Lifecycle.Event.ON_START) return@LifecycleEventObserver
                foregroundVisits += 1
                if (foregroundVisits > 1 && !welcomeBlockingAds) {
                    graph.ads.showAppOpenIfEligible(this)
                }
            },
        )
        setContent {
            FluidApp(
                graph = graph,
                activity = this,
                onWelcomeDismissed = { welcomeBlockingAds = false },
            )
        }
    }
}
