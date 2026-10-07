package com.saadapps.fluidglow

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.OpenInNew
import androidx.compose.material.icons.automirrored.filled.VolumeOff
import androidx.compose.material.icons.automirrored.filled.VolumeUp
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.Autorenew
import androidx.compose.material.icons.filled.Bolt
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.ChevronRight
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.DarkMode
import androidx.compose.material.icons.filled.Headphones
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.material.icons.filled.LocalFireDepartment
import androidx.compose.material.icons.filled.Palette
import androidx.compose.material.icons.filled.PhotoCamera
import androidx.compose.material.icons.filled.PlayCircle
import androidx.compose.material.icons.filled.QuestionMark
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.TouchApp
import androidx.compose.material.icons.filled.Vibration
import androidx.compose.material.icons.filled.Water
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.core.content.ContextCompat
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.AdSize
import com.google.android.gms.ads.AdView
import com.saadapps.hskit.ui.HsHaptics
import kotlinx.coroutines.delay

private val Night = Color(0xFF0A0D14)
private val Card = Color(0xFF141A26)
private val Glass = Color(0xFF2A2E36)
private val Accent = Color(0xFF1AD9F2)
private val Gold = Color(0xFFFFC71A)
private val Orange = Color(0xFFFF8C1A)
private val OrangeDeep = Color(0xFFF24D1A)
private val Muted = Color(0xFF8E95A3)

private val VipBrush = Brush.horizontalGradient(listOf(Orange, OrangeDeep))

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
    var showGuide by remember { mutableStateOf(false) }
    var showSplash by remember { mutableStateOf(true) }
    var flashing by remember { mutableStateOf(false) }
    var toast by remember { mutableStateOf<String?>(null) }
    var controlsVisible by remember { mutableStateOf(true) }

    LaunchedEffect(Unit) {
        delay(1400)
        showSplash = false
    }
    LaunchedEffect(toast) {
        if (toast != null) {
            delay(2200)
            toast = null
        }
    }
    LaunchedEffect(flashing) {
        if (flashing) {
            delay(120)
            flashing = false
        }
    }

    fun pulse(strong: Boolean = false) {
        if (!hapticsOn) return
        if (strong) HsHaptics.confirm(context) else HsHaptics.tick(context)
    }

    val savePermission = rememberLauncherForActivityResult(ActivityResultContracts.RequestPermission()) { granted ->
        if (granted) {
            flashing = true
            pulse(strong = true)
            toast = saveWallpaper(canvas, context, graph, activity, vip)
        }
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

            AnimatedVisibility(visible = controlsVisible, enter = fadeIn(), exit = fadeOut()) {
                Column(Modifier.fillMaxSize().statusBarsPadding().navigationBarsPadding().padding(top = 8.dp, bottom = 16.dp)) {
                    Row(
                        Modifier.fillMaxWidth().padding(horizontal = 16.dp),
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
                                tint = if (soundOn) Accent else Color.White.copy(alpha = 0.5f),
                                modifier = Modifier.size(16.dp),
                            )
                        }
                        Spacer(Modifier.weight(1f))
                        ShaderCapsule(preset) {
                            pulse(strong = true)
                            showPresets = true
                        }
                        Spacer(Modifier.weight(1f))
                        CircleButton(onClick = {
                            pulse(strong = true)
                            showSettings = true
                        }) {
                            Icon(Icons.Filled.Settings, contentDescription = "Settings", tint = Color.White, modifier = Modifier.size(16.dp))
                        }
                    }
                    Spacer(Modifier.weight(1f))
                    Row(
                        Modifier.fillMaxWidth().padding(horizontal = 20.dp),
                        horizontalArrangement = if (vip) Arrangement.Center else Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        CapsuleButton(
                            label = "Save Wallpaper",
                            icon = Icons.Filled.PhotoCamera,
                            brush = null,
                        ) {
                            if (Build.VERSION.SDK_INT < 29 &&
                                ContextCompat.checkSelfPermission(context, Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED
                            ) {
                                savePermission.launch(Manifest.permission.WRITE_EXTERNAL_STORAGE)
                            } else {
                                flashing = true
                                pulse(strong = true)
                                toast = saveWallpaper(canvas, context, graph, activity, vip)
                            }
                        }
                        if (!vip) {
                            CapsuleButton(label = "VIP Pass", icon = null, brush = VipBrush, crown = true) {
                                pulse(strong = true)
                                showPaywall = true
                            }
                        }
                    }
                }
            }

            toast?.let { message ->
                Row(
                    Modifier
                        .align(Alignment.TopCenter)
                        .statusBarsPadding()
                        .padding(top = 64.dp)
                        .clip(RoundedCornerShape(50))
                        .background(Glass)
                        .border(1.dp, Color.White.copy(alpha = 0.2f), RoundedCornerShape(50))
                        .padding(horizontal = 18.dp, vertical = 11.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Icon(Icons.Filled.CheckCircle, contentDescription = null, tint = Color(0xFF1AE699), modifier = Modifier.size(16.dp))
                    Spacer(Modifier.width(8.dp))
                    Text(message, color = Color.White, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                }
            }

            if (flashing) {
                Box(Modifier.fillMaxSize().background(Color.White.copy(alpha = 0.85f)))
            }

            if (showPresets) {
                ShaderSheet(
                    current = preset,
                    vip = vip,
                    unlocked = unlocked,
                    graph = graph,
                    onClose = { showPresets = false },
                    onSelect = { item, locked ->
                        pulse(strong = true)
                        if (locked) {
                            showPresets = false
                            showPaywall = true
                        } else {
                            applyPreset(canvas, item) { preset = it }
                            if (BuildConfig.DEBUG && graph.notePresetSwitch(vip)) {
                                graph.ads.showInterstitial(activity)
                            }
                            showPresets = false
                        }
                    },
                    onWatchAd = { item ->
                        pulse(strong = true)
                        val started = graph.ads.showRewarded(activity) {
                            graph.grantTemporaryPreset(item)
                            applyPreset(canvas, item) { preset = it }
                        }
                        showPresets = false
                        if (!started) showPaywall = true
                    },
                )
            }

            if (showSettings) {
                SettingsSheet(
                    vip = vip,
                    price = price ?: "$2.99",
                    soundOn = soundOn,
                    hapticsOn = hapticsOn,
                    privacyOptions = privacyOptions,
                    onSound = {
                        soundOn = it
                        graph.soundEnabled = it
                    },
                    onHaptics = {
                        hapticsOn = it
                        graph.hapticsEnabled = it
                    },
                    onClose = { showSettings = false },
                    onVip = {
                        showSettings = false
                        showPaywall = true
                    },
                    onGuide = {
                        showSettings = false
                        showGuide = true
                    },
                    onRestore = { graph.billing.restore() },
                    onPrivacy = {
                        activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://rj707.github.io/fluid-glow/")))
                    },
                    onPrivacyOptions = { graph.consent.showPrivacyOptions(activity) },
                )
            }

            if (showPaywall) {
                PaywallSheet(
                    price = price ?: "$2.99",
                    onClose = { showPaywall = false },
                    onPurchase = { graph.billing.purchase(activity) },
                    onRestore = { graph.billing.restore() },
                    onPrivacy = {
                        activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://rj707.github.io/fluid-glow/")))
                    },
                )
            }

            if (showWelcome || showGuide) {
                WelcomeGuide(showBack = showGuide || !showWelcome) {
                    if (showWelcome) {
                        graph.markWelcomeSeen()
                        showWelcome = false
                        onWelcomeDismissed()
                    }
                    showGuide = false
                }
            }

            if (showSplash) LaunchSplash()
        }
    }
}

private fun FluidPreset.accent(): Color = when (this) {
    FluidPreset.NeonAurora -> Color(0xFF1AE699)
    FluidPreset.BioluminescentDeep -> Color(0xFF00B3F2)
    FluidPreset.LiquidGold -> Gold
    FluidPreset.CyberpunkPlasma -> Color(0xFFE61AB3)
    FluidPreset.SolarFlare -> Color(0xFFFF591A)
    FluidPreset.MidnightOled -> Color.White
}

private fun FluidPreset.symbol(): ImageVector = when (this) {
    FluidPreset.NeonAurora -> Icons.Filled.AutoAwesome
    FluidPreset.BioluminescentDeep -> Icons.Filled.Water
    FluidPreset.LiquidGold -> Icons.Filled.AutoAwesome
    FluidPreset.CyberpunkPlasma -> Icons.Filled.Bolt
    FluidPreset.SolarFlare -> Icons.Filled.LocalFireDepartment
    FluidPreset.MidnightOled -> Icons.Filled.DarkMode
}

@Composable
private fun CircleButton(onClick: () -> Unit, content: @Composable () -> Unit) {
    Box(
        Modifier
            .size(36.dp)
            .shadow(6.dp, CircleShape, ambientColor = Color.Black, spotColor = Color.Black)
            .clip(CircleShape)
            .background(Color(0xFF3A3F49))
            .clickable(onClick = onClick),
        contentAlignment = Alignment.Center,
    ) { content() }
}

@Composable
private fun ShaderCapsule(preset: FluidPreset, onClick: () -> Unit) {
    val accent = preset.accent()
    Row(
        Modifier
            .shadow(10.dp, RoundedCornerShape(50), ambientColor = accent, spotColor = accent)
            .clip(RoundedCornerShape(50))
            .background(Color(0xFF14181C))
            .border(1.2.dp, accent.copy(alpha = 0.7f), RoundedCornerShape(50))
            .clickable(onClick = onClick)
            .padding(horizontal = 13.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Icon(preset.symbol(), contentDescription = null, tint = accent, modifier = Modifier.size(14.dp))
        Spacer(Modifier.width(6.dp))
        Text(preset.label, color = Color.White, fontWeight = FontWeight.Bold, fontSize = 13.sp, maxLines = 1)
        Spacer(Modifier.width(4.dp))
        Icon(Icons.Filled.KeyboardArrowDown, contentDescription = null, tint = Color.White.copy(alpha = 0.55f), modifier = Modifier.size(14.dp))
    }
}

@Composable
private fun CapsuleButton(
    label: String,
    icon: ImageVector?,
    brush: Brush?,
    crown: Boolean = false,
    onClick: () -> Unit,
) {
    val shape = RoundedCornerShape(50)
    Row(
        Modifier
            .then(
                if (brush != null) {
                    Modifier.shadow(12.dp, shape, ambientColor = Orange, spotColor = Orange)
                } else {
                    Modifier
                },
            )
            .clip(shape)
            .then(if (brush != null) Modifier.background(brush) else Modifier.background(Color(0xFF3A3F49)))
            .clickable(onClick = onClick)
            .padding(horizontal = 16.dp, vertical = 10.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        if (crown) {
            CrownMark(Modifier.size(14.dp), Color(0xFFFFE14A))
            Spacer(Modifier.width(6.dp))
        } else if (icon != null) {
            Icon(icon, contentDescription = null, tint = Color.White.copy(alpha = 0.95f), modifier = Modifier.size(15.dp))
            Spacer(Modifier.width(6.dp))
        }
        Text(label, color = Color.White, fontWeight = if (brush != null) FontWeight.Bold else FontWeight.SemiBold, fontSize = 13.sp)
    }
}

@Composable
private fun CrownMark(modifier: Modifier, tint: Color) {
    Canvas(modifier) {
        val w = size.width
        val h = size.height
        val path = Path().apply {
            moveTo(w * 0.12f, h * 0.78f)
            lineTo(w * 0.22f, h * 0.38f)
            lineTo(w * 0.38f, h * 0.58f)
            lineTo(w * 0.50f, h * 0.18f)
            lineTo(w * 0.62f, h * 0.58f)
            lineTo(w * 0.78f, h * 0.38f)
            lineTo(w * 0.88f, h * 0.78f)
            close()
        }
        drawPath(path, tint)
        drawCircle(tint, radius = w * 0.07f, center = Offset(w * 0.22f, h * 0.32f))
        drawCircle(tint, radius = w * 0.07f, center = Offset(w * 0.50f, h * 0.14f))
        drawCircle(tint, radius = w * 0.07f, center = Offset(w * 0.78f, h * 0.32f))
    }
}

@Composable
private fun SheetScaffold(title: String, onClose: () -> Unit, content: @Composable ColumnScope.() -> Unit) {
    Box(Modifier.fillMaxSize().background(Color.Black.copy(alpha = 0.45f))) {
        Column(
            Modifier
                .fillMaxSize()
                .background(Night)
                .statusBarsPadding()
                .navigationBarsPadding(),
        ) {
            Box(Modifier.fillMaxWidth().padding(top = 8.dp), contentAlignment = Alignment.Center) {
                Box(Modifier.width(40.dp).height(4.dp).clip(RoundedCornerShape(2.dp)).background(Color.White.copy(alpha = 0.25f)))
            }
            Box(Modifier.fillMaxWidth().padding(horizontal = 18.dp, vertical = 8.dp)) {
                Text(title, color = Color.White, fontWeight = FontWeight.Bold, fontSize = 17.sp, modifier = Modifier.align(Alignment.Center))
                Text(
                    "Done",
                    color = Accent,
                    fontWeight = FontWeight.Bold,
                    fontSize = 16.sp,
                    modifier = Modifier.align(Alignment.CenterEnd).clickable(onClick = onClose),
                )
            }
            content()
        }
    }
}

@Composable
private fun ShaderSheet(
    current: FluidPreset,
    vip: Boolean,
    unlocked: Set<String>,
    graph: AppGraph,
    onClose: () -> Unit,
    onSelect: (FluidPreset, Boolean) -> Unit,
    onWatchAd: (FluidPreset) -> Unit,
) {
    SheetScaffold("Fluid Shaders", onClose) {
        Column(Modifier.weight(1f).verticalScroll(rememberScrollState()).padding(horizontal = 20.dp, vertical = 8.dp)) {
            FluidPreset.entries.forEach { item ->
                val locked = !graph.isPresetUnlocked(item, vip) && item.name !in unlocked
                val selected = item == current
                val accent = item.accent()
                Row(
                    Modifier
                        .fillMaxWidth()
                        .padding(bottom = 12.dp)
                        .clip(RoundedCornerShape(16.dp))
                        .background(Color(0xFF1E2633))
                        .border(1.5.dp, if (selected) accent else Color.White.copy(alpha = 0.08f), RoundedCornerShape(16.dp))
                        .clickable { onSelect(item, locked) }
                        .padding(horizontal = 14.dp, vertical = 12.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Box(
                        Modifier.size(42.dp).clip(CircleShape).background(accent.copy(alpha = 0.18f)),
                        contentAlignment = Alignment.Center,
                    ) {
                        if (item == FluidPreset.LiquidGold) CrownMark(Modifier.size(18.dp), accent)
                        else Icon(item.symbol(), contentDescription = null, tint = accent, modifier = Modifier.size(18.dp))
                    }
                    Spacer(Modifier.width(12.dp))
                    Column(Modifier.weight(1f)) {
                        Text(item.label, color = Color.White, fontWeight = FontWeight.Bold, fontSize = 15.sp)
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            if (item.vipOnly && !vip) {
                                CrownMark(Modifier.size(10.dp), Gold)
                                Spacer(Modifier.width(4.dp))
                            }
                            Text(
                                if (item.vipOnly) "VIP Fluid Preset" else "Standard Fluid",
                                color = if (item.vipOnly && !vip) Gold.copy(alpha = 0.9f) else Muted,
                                fontSize = 12.sp,
                            )
                        }
                    }
                    if (selected) {
                        Icon(Icons.Filled.CheckCircle, contentDescription = null, tint = accent, modifier = Modifier.size(22.dp))
                    } else if (locked) {
                        Row(
                            Modifier
                                .clip(RoundedCornerShape(12.dp))
                                .background(Color(0xFF1A3A66))
                                .clickable { onWatchAd(item) }
                                .padding(horizontal = 9.dp, vertical = 5.dp),
                            verticalAlignment = Alignment.CenterVertically,
                        ) {
                            Icon(Icons.Filled.PlayCircle, contentDescription = null, tint = Color(0xFF4DA3FF), modifier = Modifier.size(14.dp))
                            Spacer(Modifier.width(4.dp))
                            Text("Ad", color = Color(0xFF4DA3FF), fontWeight = FontWeight.Bold, fontSize = 12.sp)
                        }
                    }
                }
            }
        }
        AdBanner(graph, Modifier.fillMaxWidth())
    }
}

@Composable
private fun SettingsSheet(
    vip: Boolean,
    price: String,
    soundOn: Boolean,
    hapticsOn: Boolean,
    privacyOptions: Boolean,
    onSound: (Boolean) -> Unit,
    onHaptics: (Boolean) -> Unit,
    onClose: () -> Unit,
    onVip: () -> Unit,
    onGuide: () -> Unit,
    onRestore: () -> Unit,
    onPrivacy: () -> Unit,
    onPrivacyOptions: () -> Unit,
) {
    SheetScaffold("Settings", onClose) {
        Column(Modifier.verticalScroll(rememberScrollState()).padding(horizontal = 18.dp)) {
            if (!vip) {
                Column(
                    Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(20.dp))
                        .background(Brush.linearGradient(listOf(Color(0xFF261F14), Color(0xFF1A1F2B))))
                        .border(1.5.dp, Brush.linearGradient(listOf(Gold.copy(alpha = 0.6f), Orange.copy(alpha = 0.2f))), RoundedCornerShape(20.dp))
                        .clickable(onClick = onVip)
                        .padding(16.dp),
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Box(
                            Modifier.size(44.dp).clip(CircleShape).background(Brush.linearGradient(listOf(Gold.copy(alpha = 0.35f), Orange.copy(alpha = 0.12f)))),
                            contentAlignment = Alignment.Center,
                        ) { CrownMark(Modifier.size(22.dp), Gold) }
                        Spacer(Modifier.width(12.dp))
                        Column {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Text("Lifetime VIP Pass", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 17.sp)
                                Spacer(Modifier.width(6.dp))
                                Text(
                                    "PRO",
                                    color = Color.Black,
                                    fontSize = 9.sp,
                                    fontWeight = FontWeight.Black,
                                    modifier = Modifier.clip(RoundedCornerShape(50)).background(Gold).padding(horizontal = 6.dp, vertical = 2.dp),
                                )
                            }
                            Text("Unlock Everything Permanently", color = Muted, fontSize = 13.sp)
                        }
                    }
                    Spacer(Modifier.height(12.dp))
                    PerkLine("100% Ad-Free (No Banners & Videos)")
                    PerkLine("All 6 Hypnotic Shaders Unlocked")
                    Spacer(Modifier.height(12.dp))
                    Row(
                        Modifier
                            .fillMaxWidth()
                            .shadow(8.dp, RoundedCornerShape(12.dp), ambientColor = Orange, spotColor = Orange)
                            .clip(RoundedCornerShape(12.dp))
                            .background(VipBrush)
                            .padding(horizontal = 16.dp, vertical = 11.dp),
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        Text("Get VIP Pass", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                        Spacer(Modifier.weight(1f))
                        Text("$price • Lifetime", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                        Icon(Icons.Filled.ChevronRight, contentDescription = null, tint = Color.White.copy(alpha = 0.8f), modifier = Modifier.size(16.dp))
                    }
                }
            } else {
                Row(
                    Modifier.fillMaxWidth().clip(RoundedCornerShape(18.dp)).background(Color(0xFF14301F)).border(1.dp, Color(0xFF34C759).copy(alpha = 0.3f), RoundedCornerShape(18.dp)).padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Icon(Icons.Filled.CheckCircle, contentDescription = null, tint = Color(0xFF34C759), modifier = Modifier.size(22.dp))
                    Spacer(Modifier.width(12.dp))
                    Column {
                        Text("VIP Active", color = Color.White, fontWeight = FontWeight.Bold)
                        Text("All Features & Shaders Unlocked", color = Color(0xFF34C759), fontSize = 12.sp)
                    }
                }
            }

            SectionLabel("HOW TO PLAY & GESTURES")
            Row(
                Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(18.dp))
                    .background(Card)
                    .border(1.dp, Color.White.copy(alpha = 0.08f), RoundedCornerShape(18.dp))
                    .clickable(onClick = onGuide)
                    .padding(horizontal = 16.dp, vertical = 14.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                IconBadge(Icons.Filled.QuestionMark, listOf(Color(0xFF00CCF2), Color(0xFF0073E6)))
                Spacer(Modifier.width(12.dp))
                Column(Modifier.weight(1f)) {
                    Text("How to Play & Gesture Guide", color = Color.White, fontWeight = FontWeight.SemiBold, fontSize = 15.sp)
                    Text("Master swirls, bursts & interactive soundscapes", color = Muted, fontSize = 12.sp)
                }
                Icon(Icons.Filled.ChevronRight, contentDescription = null, tint = Muted, modifier = Modifier.size(16.dp))
            }

            SectionLabel("SENSORY CONTROLS")
            Column(
                Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(18.dp))
                    .background(Card)
                    .border(1.dp, Color.White.copy(alpha = 0.08f), RoundedCornerShape(18.dp)),
            ) {
                SensoryToggle(
                    icon = if (soundOn) Icons.AutoMirrored.Filled.VolumeUp else Icons.AutoMirrored.Filled.VolumeOff,
                    colors = listOf(Color(0xFF00D9CC), Color(0xFF0099BF)),
                    title = "Sound Effects",
                    subtitle = "Generative ASMR harmonic chimes",
                    checked = soundOn,
                    track = Accent,
                    onChange = onSound,
                )
                Box(Modifier.padding(start = 64.dp).fillMaxWidth().height(1.dp).background(Color.White.copy(alpha = 0.08f)))
                SensoryToggle(
                    icon = Icons.Filled.Vibration,
                    colors = listOf(Color(0xFFBF40F2), Color(0xFF8C1AD9)),
                    title = "Haptic Feedback",
                    subtitle = "Fluid dynamic micro-vibrations",
                    checked = hapticsOn,
                    track = Color(0xFFBF40F2),
                    onChange = onHaptics,
                )
            }

            Spacer(Modifier.height(22.dp))
            Row(
                Modifier.fillMaxWidth().clickable(onClick = onRestore),
                horizontalArrangement = Arrangement.Center,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Icon(Icons.Filled.Check, contentDescription = null, tint = Accent, modifier = Modifier.size(16.dp))
                Spacer(Modifier.width(6.dp))
                Text("Restore Purchases", color = Accent, fontWeight = FontWeight.SemiBold, fontSize = 14.sp)
            }
            Spacer(Modifier.height(14.dp))
            Row(
                Modifier.fillMaxWidth().clickable(onClick = onPrivacy),
                horizontalArrangement = Arrangement.Center,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Text("Privacy Policy & Terms of Service", color = Muted, fontSize = 12.sp)
                Spacer(Modifier.width(4.dp))
                Icon(Icons.AutoMirrored.Filled.OpenInNew, contentDescription = null, tint = Muted, modifier = Modifier.size(11.dp))
            }
            if (privacyOptions) {
                Text(
                    "Privacy options",
                    color = Muted,
                    fontSize = 12.sp,
                    modifier = Modifier.fillMaxWidth().clickable(onClick = onPrivacyOptions).padding(top = 10.dp),
                    textAlign = TextAlign.Center,
                )
            }
            Text(
                "Fluid Glow v${BuildConfig.VERSION_NAME} (Build ${BuildConfig.VERSION_CODE})",
                color = Muted.copy(alpha = 0.6f),
                fontSize = 11.sp,
                modifier = Modifier.fillMaxWidth().padding(top = 8.dp, bottom = 24.dp),
                textAlign = TextAlign.Center,
            )
        }
    }
}

@Composable
private fun PaywallSheet(
    price: String,
    onClose: () -> Unit,
    onPurchase: () -> Unit,
    onRestore: () -> Unit,
    onPrivacy: () -> Unit,
) {
    Box(Modifier.fillMaxSize().background(Color(0xFF0D121C))) {
        Column(Modifier.fillMaxSize().statusBarsPadding().navigationBarsPadding().padding(horizontal = 20.dp)) {
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.End) {
                Text("Close", color = Color.White.copy(alpha = 0.55f), fontWeight = FontWeight.SemiBold, modifier = Modifier.clickable(onClick = onClose).padding(12.dp))
            }
            Column(Modifier.fillMaxWidth(), horizontalAlignment = Alignment.CenterHorizontally) {
                Box(
                    Modifier.size(44.dp).clip(CircleShape).background(Brush.linearGradient(listOf(Gold.copy(alpha = 0.28f), Orange.copy(alpha = 0.12f)))),
                    contentAlignment = Alignment.Center,
                ) { CrownMark(Modifier.size(22.dp), Gold) }
                Spacer(Modifier.height(6.dp))
                Text("Lifetime VIP Pass", color = Color.White, fontWeight = FontWeight.Black, fontSize = 20.sp)
                Text("$price One-Time • Forever", color = Gold, fontWeight = FontWeight.Bold, fontSize = 13.sp)
            }
            Spacer(Modifier.height(18.dp))
            Column(
                Modifier.fillMaxWidth().clip(RoundedCornerShape(16.dp)).background(Color(0xFF171E2B)).border(1.dp, Color.White.copy(alpha = 0.06f), RoundedCornerShape(16.dp)).padding(14.dp),
            ) {
                PayPerk("100% Ad-Free Forever", "Zero banner ads, popups, or interruptions")
                PayPerk("All 6 Hypnotic Shaders", "Liquid Gold, Cyberpunk Plasma & Solar Flare")
                PayPerk("Generative ASMR Audio", "Uncapped interactive harmonic soundscapes")
                PayPerk("Fluid Dynamic Haptics", "Micro-vibrations synced to your touch")
            }
            Spacer(Modifier.weight(1f))
            Box(
                Modifier
                    .fillMaxWidth()
                    .shadow(12.dp, RoundedCornerShape(16.dp), ambientColor = Orange, spotColor = Orange)
                    .clip(RoundedCornerShape(16.dp))
                    .background(VipBrush)
                    .clickable(onClick = onPurchase)
                    .padding(vertical = 14.dp),
                contentAlignment = Alignment.Center,
            ) {
                Text("Unlock Lifetime VIP • $price", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 16.sp)
            }
            Row(Modifier.fillMaxWidth().padding(top = 12.dp, bottom = 16.dp), horizontalArrangement = Arrangement.Center) {
                Text("Restore Purchases", color = Muted, fontSize = 12.sp, fontWeight = FontWeight.SemiBold, modifier = Modifier.clickable(onClick = onRestore))
                Text("  •  ", color = Muted.copy(alpha = 0.4f))
                Text("Terms & Privacy", color = Muted, fontSize = 12.sp, modifier = Modifier.clickable(onClick = onPrivacy))
            }
        }
    }
}

@Composable
private fun WelcomeGuide(showBack: Boolean, onClose: () -> Unit) {
    Box(Modifier.fillMaxSize().background(Night)) {
        Box(
            Modifier
                .fillMaxWidth()
                .height(280.dp)
                .background(Brush.radialGradient(listOf(Color(0xFF00BFF2).copy(alpha = 0.16f), Color(0xFFBF26D9).copy(alpha = 0.08f), Color.Transparent))),
        )
        Column(Modifier.fillMaxSize().statusBarsPadding().navigationBarsPadding()) {
            Row(Modifier.fillMaxWidth().padding(start = 16.dp, top = 8.dp)) {
                CircleButton(onClick = onClose) {
                    Icon(
                        if (showBack) Icons.AutoMirrored.Filled.ArrowBack else Icons.Filled.Close,
                        contentDescription = if (showBack) "Back" else "Close",
                        tint = Color.White,
                        modifier = Modifier.size(16.dp),
                    )
                }
            }
            Column(Modifier.weight(1f).verticalScroll(rememberScrollState()).padding(horizontal = 24.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                Box(contentAlignment = Alignment.Center) {
                    Box(Modifier.size(86.dp).clip(RoundedCornerShape(24.dp)).background(Brush.sweepGradient(listOf(Accent, Color(0xFFFF4AD4), Color(0xFFBF40F2), Gold, Accent))))
                    Box(
                        Modifier.size(72.dp).clip(RoundedCornerShape(20.dp)).background(Brush.linearGradient(listOf(Color(0xFF1A1F2E), Color(0xFF0D101A)))).border(1.5.dp, Brush.linearGradient(listOf(Accent.copy(alpha = 0.7f), Color(0xFFFF4AD4).copy(alpha = 0.5f))), RoundedCornerShape(20.dp)),
                        contentAlignment = Alignment.Center,
                    ) {
                        Icon(Icons.Filled.AutoAwesome, contentDescription = null, tint = Accent, modifier = Modifier.size(32.dp))
                    }
                }
                Spacer(Modifier.height(12.dp))
                Text("WELCOME TO", color = Color.White.copy(alpha = 0.6f), fontWeight = FontWeight.Bold, fontSize = 13.sp, letterSpacing = 1.5.sp)
                Text(
                    "Fluid Glow",
                    fontSize = 34.sp,
                    fontWeight = FontWeight.Black,
                    style = TextStyle(brush = Brush.horizontalGradient(listOf(Color(0xFF26E6D9), Color(0xFFD940F2), Gold))),
                )
                Text("ASMR SENSORY & LIQUID PHYSICS", color = Gold, fontWeight = FontWeight.Black, fontSize = 12.sp, letterSpacing = 1.2.sp)
                Spacer(Modifier.height(24.dp))
                GuideRow(Icons.Filled.TouchApp, listOf(Color(0xFF00D9F2), Color(0xFF0080E6)), "One-Finger Swirl", "Drag across the canvas to draw silky glowing streams that flow with realistic fluid physics.")
                GuideRow(Icons.Filled.Autorenew, listOf(Color(0xFFBF40F2), Color(0xFF801AD9)), "Multi-Touch Vortex", "Use 2 or 3 fingers simultaneously to create intense swirling whirlpools and gravitational vortexes.")
                GuideRow(Icons.Filled.AutoAwesome, listOf(Orange, OrangeDeep), "Tap Stardust Burst", "Tap anywhere to trigger an instant radial explosion of glowing particles and soft ASMR pops.")
                GuideRow(Icons.Filled.Palette, listOf(Color(0xFFF23399), Color(0xFFCC0D73)), "6 Hypnotic Shaders", "Switch between Neon Aurora, Liquid Gold, Bioluminescent Deep, Cyberpunk Plasma, and OLED.")
                GuideRow(Icons.Filled.Headphones, listOf(Color(0xFF1AD98C), Color(0xFF0D994D)), "Generative ASMR Audio", "Put on headphones. Ambient harmonic chimes and soothing frequencies react to your swirl speed.")
                Spacer(Modifier.height(16.dp))
            }
            Box(
                Modifier
                    .padding(horizontal = 24.dp, vertical = 12.dp)
                    .fillMaxWidth()
                    .shadow(12.dp, RoundedCornerShape(50), ambientColor = Accent, spotColor = Color(0xFFB333E6))
                    .clip(RoundedCornerShape(50))
                    .background(Brush.horizontalGradient(listOf(Color(0xFF00BFF2), Color(0xFFB333E6))))
                    .clickable(onClick = onClose)
                    .padding(vertical = 16.dp),
                contentAlignment = Alignment.Center,
            ) {
                Text("Start Swirling  •  ✦  Relax", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 17.sp)
            }
        }
    }
}

@Composable
private fun GuideRow(icon: ImageVector, colors: List<Color>, title: String, body: String) {
    Row(Modifier.fillMaxWidth().padding(bottom = 20.dp), verticalAlignment = Alignment.Top) {
        Box(
            Modifier.size(46.dp).shadow(8.dp, CircleShape, ambientColor = colors.first(), spotColor = colors.first()).clip(CircleShape).background(Brush.linearGradient(colors)),
            contentAlignment = Alignment.Center,
        ) {
            Icon(icon, contentDescription = null, tint = Color.White, modifier = Modifier.size(22.dp))
        }
        Spacer(Modifier.width(16.dp))
        Column {
            Text(title, color = Color.White, fontWeight = FontWeight.Bold, fontSize = 16.sp)
            Text(body, color = Color.White.copy(alpha = 0.72f), fontSize = 13.sp)
        }
    }
}

@Composable
private fun LaunchSplash() {
    Column(
        Modifier.fillMaxSize().background(Color.Black),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Image(
            painter = painterResource(R.drawable.splash_icon),
            contentDescription = null,
            modifier = Modifier.size(132.dp).clip(CircleShape),
        )
        Spacer(Modifier.height(24.dp))
        Text(
            "Fluid Glow",
            fontSize = 34.sp,
            fontWeight = FontWeight.Black,
            style = TextStyle(brush = Brush.horizontalGradient(listOf(Color(0xFF1AE699), Color(0xFF00B3F2), Color(0xFFE61AB3)))),
        )
        Spacer(Modifier.height(8.dp))
        Text("ASMR SENSORY RELAX", color = Color.White.copy(alpha = 0.65f), fontSize = 12.sp, fontWeight = FontWeight.Bold, letterSpacing = 3.5.sp)
    }
}

@Composable
private fun SectionLabel(text: String) {
    Text(text, color = Muted, fontSize = 11.sp, fontWeight = FontWeight.Bold, letterSpacing = 1.2.sp, modifier = Modifier.padding(start = 6.dp, top = 22.dp, bottom = 8.dp))
}

@Composable
private fun PerkLine(text: String) {
    Row(Modifier.padding(bottom = 6.dp), verticalAlignment = Alignment.CenterVertically) {
        Icon(Icons.Filled.Check, contentDescription = null, tint = Gold, modifier = Modifier.size(14.dp))
        Spacer(Modifier.width(8.dp))
        Text(text, color = Color.White.copy(alpha = 0.9f), fontSize = 13.sp)
    }
}

@Composable
private fun PayPerk(title: String, subtitle: String) {
    Column(Modifier.padding(vertical = 6.dp)) {
        Text(title, color = Color.White, fontWeight = FontWeight.Bold, fontSize = 13.sp)
        Text(subtitle, color = Muted, fontSize = 11.sp)
    }
}

@Composable
private fun IconBadge(icon: ImageVector, colors: List<Color>) {
    Box(
        Modifier.size(36.dp).shadow(6.dp, RoundedCornerShape(10.dp), ambientColor = colors.first(), spotColor = colors.first()).clip(RoundedCornerShape(10.dp)).background(Brush.linearGradient(colors)),
        contentAlignment = Alignment.Center,
    ) {
        Icon(icon, contentDescription = null, tint = Color.White, modifier = Modifier.size(18.dp))
    }
}

@Composable
private fun SensoryToggle(
    icon: ImageVector,
    colors: List<Color>,
    title: String,
    subtitle: String,
    checked: Boolean,
    track: Color,
    onChange: (Boolean) -> Unit,
) {
    Row(Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 12.dp), verticalAlignment = Alignment.CenterVertically) {
        IconBadge(icon, colors)
        Spacer(Modifier.width(12.dp))
        Column(Modifier.weight(1f)) {
            Text(title, color = Color.White, fontWeight = FontWeight.SemiBold, fontSize = 15.sp)
            Text(subtitle, color = Muted, fontSize = 12.sp)
        }
        Switch(
            checked = checked,
            onCheckedChange = onChange,
            colors = SwitchDefaults.colors(checkedTrackColor = track, uncheckedTrackColor = Color.White.copy(alpha = 0.18f)),
        )
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
): String {
    val view = canvas ?: return "Could not save photo"
    if (view.width == 0 || view.height == 0) return "Could not save photo"
    val saved = WallpaperSaver.save(context, view.captureBitmap())
    if (saved && !vip) graph.ads.showInterstitial(activity)
    return if (saved) "Wallpaper Saved to Photos" else "Could not save photo"
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
