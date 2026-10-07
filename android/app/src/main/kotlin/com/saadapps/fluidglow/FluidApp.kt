package com.saadapps.fluidglow

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import android.os.Build
import android.widget.Toast
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.automirrored.filled.VolumeOff
import androidx.compose.material.icons.automirrored.filled.VolumeUp
import androidx.compose.material.icons.filled.Star
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.core.content.ContextCompat
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.AdSize
import com.google.android.gms.ads.AdView
import com.saadapps.hskit.ui.HsHaptics

private val Glass = Color.White.copy(alpha = 0.12f)
private val Ink = Color(0xFF0A0C10)

@Composable
fun FluidApp(
    graph: AppGraph,
    activity: Activity,
    onWelcomeDismissed: () -> Unit,
) {
    val vip by graph.billing.removesAds.collectAsStateWithLifecycle()
    val privacyOptions by graph.consent.privacyOptionsRequired.collectAsStateWithLifecycle()
    val unlocked by graph.temporaryPresets.collectAsStateWithLifecycle()
    val price by graph.billing.price.collectAsStateWithLifecycle()
    val context = LocalContext.current
    var canvas by remember { mutableStateOf<FluidCanvasView?>(null) }
    var preset by remember { mutableStateOf(FluidPreset.NeonAurora) }
    var soundOn by remember { mutableStateOf(graph.soundEnabled) }
    var hapticsOn by remember { mutableStateOf(graph.hapticsEnabled) }
    var showPresets by remember { mutableStateOf(false) }
    var showSettings by remember { mutableStateOf(false) }
    var showPaywall by remember { mutableStateOf(false) }
    var showWelcome by remember { mutableStateOf(!graph.hasSeenWelcome()) }
    var controlsVisible by remember { mutableStateOf(true) }

    fun pulse(strong: Boolean = false) {
        if (!hapticsOn) return
        if (strong) HsHaptics.confirm(context) else HsHaptics.tick(context)
    }

    val savePermission = rememberLauncherForActivityResult(ActivityResultContracts.RequestPermission()) { granted ->
        if (granted) saveWallpaper(canvas, context, graph, activity, vip)
    }

    MaterialTheme(colorScheme = MaterialTheme.colorScheme.copy(background = Color.Black)) {
        Box(Modifier.fillMaxSize().background(Color.Black)) {
            AndroidView(
                modifier = Modifier.fillMaxSize(),
                factory = { viewContext ->
                    FluidCanvasView(viewContext).also { view ->
                        canvas = view
                        view.onBurst = {
                            graph.tones.playBurst()
                            pulse(strong = true)
                            controlsVisible = true
                        }
                        view.onSwirl = { speed ->
                            graph.tones.playSwirl(speed)
                            if (speed > 8f) pulse()
                            controlsVisible = false
                        }
                        view.onGestureFinished = { controlsVisible = true }
                    }
                },
            )

            if (controlsVisible) {
                Column(Modifier.fillMaxSize().statusBarsPadding().padding(bottom = if (vip) 0.dp else 72.dp).navigationBarsPadding()) {
                    Row(
                        Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 8.dp),
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        CircleButton(onClick = {
                            soundOn = !soundOn
                            graph.soundEnabled = soundOn
                            pulse()
                        }) {
                            Icon(
                                if (soundOn) Icons.AutoMirrored.Filled.VolumeUp else Icons.AutoMirrored.Filled.VolumeOff,
                                contentDescription = "Sound",
                                tint = if (soundOn) Color(0xFF1AE6A0) else Color.White.copy(alpha = 0.5f),
                            )
                        }
                        Spacer(Modifier.weight(1f))
                        Row(
                            Modifier
                                .clip(RoundedCornerShape(50))
                                .background(Glass)
                                .border(1.dp, Color.White.copy(alpha = 0.25f), RoundedCornerShape(50))
                                .clickable {
                                    pulse(strong = true)
                                    showPresets = true
                                }
                                .padding(horizontal = 14.dp, vertical = 8.dp),
                            verticalAlignment = Alignment.CenterVertically,
                        ) {
                            Text(preset.label, color = Color.White, fontWeight = FontWeight.Bold)
                            Icon(Icons.Filled.KeyboardArrowDown, contentDescription = null, tint = Color.White.copy(alpha = 0.6f))
                        }
                        Spacer(Modifier.weight(1f))
                        CircleButton(onClick = {
                            pulse(strong = true)
                            showSettings = true
                        }) {
                            Icon(Icons.Filled.Settings, contentDescription = "Settings", tint = Color.White)
                        }
                    }
                    Spacer(Modifier.weight(1f))
                    Row(
                        Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 8.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        CapsuleButton("Save Wallpaper") {
                            if (Build.VERSION.SDK_INT < 29 &&
                                ContextCompat.checkSelfPermission(context, Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED
                            ) {
                                savePermission.launch(Manifest.permission.WRITE_EXTERNAL_STORAGE)
                            } else {
                                saveWallpaper(canvas, context, graph, activity, vip)
                            }
                        }
                        if (!vip) {
                            CapsuleButton("VIP Pass") {
                                pulse(strong = true)
                                showPaywall = true
                            }
                        }
                    }
                }
            }
            AdBanner(
                graph,
                Modifier.align(Alignment.BottomCenter).navigationBarsPadding().padding(bottom = 8.dp),
            )

            if (showPresets) {
                Sheet(title = "Shaders", onClose = { showPresets = false }) {
                    FluidPreset.entries.forEach { item ->
                        val locked = !graph.isPresetUnlocked(item, vip) && item.name !in unlocked
                        Row(
                            Modifier
                                .fillMaxWidth()
                                .clip(RoundedCornerShape(16.dp))
                                .background(if (item == preset) Glass else Color.Transparent)
                                .clickable {
                                    if (locked) {
                                        val started = graph.ads.showRewarded(activity) {
                                            graph.grantTemporaryPreset(item)
                                            applyPreset(canvas, item) { preset = it }
                                        }
                                        if (!started) showPaywall = true
                                    } else {
                                        applyPreset(canvas, item) { preset = it }
                                    }
                                    pulse(strong = true)
                                    showPresets = false
                                }
                                .padding(14.dp),
                            verticalAlignment = Alignment.CenterVertically,
                        ) {
                            Text(item.label, color = Color.White, modifier = Modifier.weight(1f))
                            if (item.vipOnly) {
                                Icon(
                                    if (locked) Icons.Filled.Lock else Icons.Filled.Star,
                                    contentDescription = null,
                                    tint = Color(0xFFFFD54A),
                                )
                            }
                        }
                    }
                }
            }

            if (showSettings) {
                Sheet(title = "Settings", onClose = { showSettings = false }) {
                    SettingRow("Sound", soundOn) {
                        soundOn = it
                        graph.soundEnabled = it
                    }
                    SettingRow("Haptics", hapticsOn) {
                        hapticsOn = it
                        graph.hapticsEnabled = it
                    }
                    TextButton(onClick = { graph.billing.restore() }) {
                        Text("Restore purchases", color = Color.White)
                    }
                    if (privacyOptions) {
                        TextButton(onClick = { graph.consent.showPrivacyOptions(activity) }) {
                            Text("Privacy options", color = Color.White)
                        }
                    }
                    if (!vip) {
                        Button(onClick = { showSettings = false; showPaywall = true }, modifier = Modifier.fillMaxWidth()) {
                            Text("Lifetime VIP Pass")
                        }
                    }
                }
            }

            if (showPaywall) {
                Sheet(title = "Lifetime VIP Pass", onClose = { showPaywall = false }) {
                    Text("Ad-free, all six shaders, sound, and haptics. One purchase.", color = Color.White.copy(alpha = 0.8f))
                    Spacer(Modifier.height(16.dp))
                    Button(
                        onClick = { graph.billing.purchase(activity) },
                        modifier = Modifier.fillMaxWidth(),
                        colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFFFD54A), contentColor = Color.Black),
                    ) {
                        Text(price ?: "Unlock")
                    }
                    TextButton(onClick = { graph.billing.restore() }) {
                        Text("Restore purchases", color = Color.White)
                    }
                }
            }

            if (showWelcome) {
                Sheet(title = "Fluid Glow", onClose = {
                    graph.markWelcomeSeen()
                    showWelcome = false
                    onWelcomeDismissed()
                }) {
                    Text("Drag to swirl glowing liquid. Tap a shader to change the color. Save any frame as a wallpaper.", color = Color.White.copy(alpha = 0.85f))
                    Spacer(Modifier.height(16.dp))
                    Button(
                        onClick = {
                            graph.markWelcomeSeen()
                            showWelcome = false
                            onWelcomeDismissed()
                        },
                        modifier = Modifier.fillMaxWidth(),
                    ) {
                        Text("Start")
                    }
                }
            }
        }
    }
}

private fun applyPreset(canvas: FluidCanvasView?, preset: FluidPreset, assign: (FluidPreset) -> Unit) {
    canvas?.engine?.setPreset(preset)
    assign(preset)
}

private fun saveWallpaper(
    canvas: FluidCanvasView?,
    context: android.content.Context,
    graph: AppGraph,
    activity: Activity,
    vip: Boolean,
) {
    val view = canvas ?: return
    if (view.width == 0 || view.height == 0) return
    val saved = WallpaperSaver.save(context, view.captureBitmap())
    Toast.makeText(context, if (saved) "Wallpaper saved" else "Could not save photo", Toast.LENGTH_SHORT).show()
    if (saved && !vip) graph.ads.showInterstitial(activity)
}

@Composable
private fun CircleButton(onClick: () -> Unit, content: @Composable () -> Unit) {
    Box(
        Modifier
            .size(36.dp)
            .clip(CircleShape)
            .background(Glass)
            .clickable(onClick = onClick),
        contentAlignment = Alignment.Center,
    ) {
        content()
    }
}

@Composable
private fun CapsuleButton(label: String, onClick: () -> Unit) {
    Text(
        label,
        color = Color.White,
        fontWeight = FontWeight.SemiBold,
        modifier = Modifier
            .clip(RoundedCornerShape(50))
            .background(Glass)
            .clickable(onClick = onClick)
            .padding(horizontal = 16.dp, vertical = 10.dp),
    )
}

@Composable
private fun Sheet(title: String, onClose: () -> Unit, content: @Composable () -> Unit) {
    Box(Modifier.fillMaxSize().background(Color.Black.copy(alpha = 0.55f)).clickable(onClick = onClose)) {
        Column(
            Modifier
                .align(Alignment.BottomCenter)
                .fillMaxWidth()
                .clip(RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp))
                .background(Ink)
                .navigationBarsPadding()
                .clickable { }
                .verticalScroll(rememberScrollState())
                .padding(20.dp),
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(title, color = Color.White, fontWeight = FontWeight.Bold, modifier = Modifier.weight(1f))
                Icon(Icons.Filled.Close, contentDescription = "Close", tint = Color.White, modifier = Modifier.clickable(onClick = onClose))
            }
            Spacer(Modifier.height(12.dp))
            content()
        }
    }
}

@Composable
private fun SettingRow(label: String, checked: Boolean, onChange: (Boolean) -> Unit) {
    Row(Modifier.fillMaxWidth().padding(vertical = 6.dp), verticalAlignment = Alignment.CenterVertically) {
        Text(label, color = Color.White, modifier = Modifier.weight(1f))
        Switch(checked = checked, onCheckedChange = onChange)
    }
}

@Composable
private fun AdBanner(graph: AppGraph, modifier: Modifier = Modifier) {
    val premium by graph.billing.removesAds.collectAsStateWithLifecycle()
    val consent by graph.consent.canRequestAds.collectAsStateWithLifecycle()
    if (premium || !consent || !graph.ads.bannerAllowed()) return
    val unitId = graph.ads.units.banner
    AndroidView(
        modifier = modifier.fillMaxWidth().height(50.dp),
        factory = { context ->
            AdView(context).apply {
                setAdSize(AdSize.BANNER)
                adUnitId = unitId
                loadAd(AdRequest.Builder().build())
            }
        },
        onRelease = { it.destroy() },
    )
}
