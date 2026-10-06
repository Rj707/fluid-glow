# 📦 HSKit Standardization & Multi-App Migration Guide

This document records **what has been standardized in HSKit**, how **Decibel Pro** and **FluidGlow** were migrated as production references, and the **exact steps the remaining apps (`ReaderLab`, `EmojiRiddle`) must follow**.

---

## 📑 Table of Contents
1. [Executive Summary & Purpose](#-executive-summary--purpose)
2. [What Was Standardized (The Transformation)](#-what-was-standardized-the-transformation)
3. [File-by-File Changes Across HSKit & Production Apps](#-file-by-file-changes-across-hskit--production-apps)
4. [Standardized API Reference](#-standardized-api-reference)
5. [Action Checklist for Remaining Apps](#-action-checklist-for-remaining-apps)
6. [App-Specific Implementation Recipes](#-app-specific-implementation-recipes)
7. [Verification & Reference Code](#-verification--reference-code)

---

## 🎯 Executive Summary & Purpose

### The Problem
Previously, each portfolio app implemented large monetization and utility subsystems locally (`AdManager.swift`, `ProFeatureManager.swift`, `ConsentManager.swift`, `AppTheme.swift`) instead of pulling them from HSKit. 
* Every AdMob SDK update or App Tracking Transparency (ATT) policy change required manual edits in **4 separate projects**.
* StoreKit 2 transaction verification, receipt restoration, and cooldown logic were duplicated and prone to inconsistencies.

### The Solution
We extracted all generic behavior into **HSKit** modules (`HSCore`, `HSAds`, `HSUI`), establishing HSKit as the **single source of truth**. Each app now maintains only a thin configuration file with its own unique bundle IDs, ad unit IDs, and custom feature gates.

---

## 🔄 What Was Standardized (The Transformation)

| Capability | Legacy Local Pattern | Standardized in HSKit | What the App Now Does |
| :--- | :--- | :--- | :--- |
| **Privacy / ATT Consent** | Custom `ATTrackingManager` boilerplate across multiple files. | `HSConsentManager` in `HSCore`. | 1-line call: `HSConsentManager.shared.requestTrackingPermission()`. |
| **StoreKit 2 Purchases** | Full StoreKit 2 transaction loops, async listeners, and sync logic. | `HSStoreManager` in `HSCore`. | Passes app Product IDs to `HSStoreManager.shared.configure(productIDs:)`. |
| **Passes & Rewarded Unlocks** | Duplicate expiration timestamp math and local storage keys. | `HSStoreManager` temporary passes and feature keys. | Calls `grantTemporaryPass(seconds:)` and `isProductUnlocked(...)`. |
| **Google AdMob Engine** | Hundreds of lines of GAD objects, loading callbacks, and VC finding. | `HSAdManager` & `HSAdConfiguration` in `HSAds`. | Configures ad unit IDs, Pro suppression closure, and audio ducking hooks. |
| **Ad Cooldown State Machine** | Hardcoded timestamps and redundant timers. | `HSAdCooldownTracker` in `HSAds` (4h App Open, 2m Interstitial, 60s post-ad buffer). | Automatically enforced by `HSAdManager`. |
| **Bottom Adaptive Banner** | Redundant `UIViewControllerRepresentable` and fallback layouts. | `HSBannerAdView` in `HSAds`. | Declarative SwiftUI view: `HSBannerAdView(adUnitID: ..., isProUnlocked: ...)`. |
| **Theme Management** | Duplicate `UserDefaults` persistence and color maps. | `HSThemeManager` & `HSThemeMode` in `HSUI`. | Aliases `HSThemeMode` and binds `.preferredColorScheme(theme.preferredColorScheme)`. |

---

## 📁 File-by-File Changes Across HSKit & Production Apps

### 1. Standardized Modules in HSKit
* **`HSKit/Sources/HSCore/ConsentManager.swift`** (`HSConsentManager`): Centralized Google UMP + Apple ATT authorization with window-readiness dispatch.
* **`HSKit/Sources/HSCore/StoreManager.swift`** (`HSStoreManager`): Complete StoreKit 2 engine, transaction listener, purchase execution, restores, and temporary passes.
* **`HSKit/Sources/HSCore/HapticsManager.swift`** (`HSHapticsManager`): Standardized impact, notification, and selection feedback generators.
* **`HSKit/Sources/HSAds/HSAdManager.swift`** (`HSAdManager`, `HSAdConfiguration`): Full AdMob manager with safe audio ducking, preloading, and cooldowns.
* **`HSKit/Sources/HSAds/HSBannerAdView.swift`** (`HSBannerAdView`): Reusable 50px adaptive bottom banner with automatic Pro suppression.
* **`HSKit/Sources/HSUI/ThemeManager.swift`** (`HSThemeManager`, `HSThemeMode`): Dynamic theme persistence engine synced with `UserDefaults`.

### 2. Files Standardized in Decibel Pro (Audio Reference)
* **`DecibelPro/Sources/DecibelPro/Managers/AdManager.swift`**: Configures `HSAdManager` with Decibel Pro ad unit IDs; pauses audio measuring during ad presentation.
* **`DecibelPro/Sources/DecibelPro/Managers/ProFeatureManager.swift`**: Delegates StoreKit 2 transactions to `HSStoreManager`.
* **`DecibelPro/Sources/DecibelPro/Components/BannerAdContainerView.swift`**: Replaced with `HSBannerAdView`.
* **`DecibelPro/Sources/DecibelPro/Theme/AppTheme.swift`**: Synchronized with `HSThemeManager`.

### 3. Files Standardized in FluidGlow (Interactive Physics & ASMR Reference)
* **`FluidGlow/Resources/Info.plist`**: Added `NSUserTrackingUsageDescription` for safe ATT initialization.
* **`FluidGlow/Services/ASMRAudioEngine.swift`**: Added `pauseAudio()` and `resumeAudio()` hooks to safely duck ASMR chimes while ads display.
* **`FluidGlow/Managers/AdManager.swift`**: Configured `HSAdManager` with FluidGlow unit IDs, wired `ASMRAudioEngine` pause/resume lifecycle hooks, and provided fast synchronous reward execution under unit tests.
* **`FluidGlow/Managers/ProFeatureManager.swift`**: Delegated StoreKit 2 purchases and entitlements to `HSStoreManager` with session-scoped preset unlocks.
* **`FluidGlow/Views/BannerAdContainerView.swift`**: Adopted `HSBannerAdView` with `@ObservedObject` reactive Pro state binding.
* **`FluidGlow/Theme/AppTheme.swift`**: Aliased `AppThemeMode = HSThemeMode` and synchronized with `HSThemeManager`.
* **`FluidGlow/FluidGlowApp.swift`**: Wired `HSConsentManager` on launch, safe App Open ad lifecycle guarded against splash screen presentation, and `.preferredColorScheme` synchronization.

---

## 🛠️ Standardized API Reference

### 1. Tracking Consent & Cold-Launch Safe Ads
```swift
import SwiftUI
import HSCore
import HSAds
import HSUI

@main
struct MyApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @ObservedObject private var theme = HSThemeManager.shared
    @State private var isSplashActive = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                MainContentView()
                
                if isSplashActive {
                    SplashView(isActive: $isSplashActive)
                }
            }
            .preferredColorScheme(theme.preferredColorScheme)
            .onAppear {
                // Request ATT & UMP once window is ready, then preload ads
                HSConsentManager.shared.requestTrackingPermission { _ in
                    HSAdManager.shared.preloadAds()
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                // Only trigger App Open ads on genuine returns when splash is not active
                if newPhase == .active && !isSplashActive {
                    HSAdManager.shared.showAppOpenAdIfAvailable()
                }
            }
        }
    }
}
```

### 2. In-App Purchases & StoreKit 2 (`HSCore`)
```swift
import HSCore

// Initialize once at app launch:
HSStoreManager.shared.configure(productIDs: [
    "com.saadapps.yourapp.lifetime"
])

// Purchase:
let success = await HSStoreManager.shared.purchase(productID: "com.saadapps.yourapp.lifetime")

// Check entitlement:
let isPro = HSStoreManager.shared.isProductUnlocked("com.saadapps.yourapp.lifetime")

// Restore purchases:
await HSStoreManager.shared.restorePurchases()

// Temporary Rewarded Pass (24-Hour):
HSStoreManager.shared.grantTemporaryPass(seconds: 86400)
let hasPass = HSStoreManager.shared.hasActivePass
```

### 3. Audio-Safe Ads Management (`HSAds`)
```swift
import HSAds

let config = HSAdConfiguration(
    appOpenAdUnitID: "ca-app-pub-...",
    rewardedAdUnitID: "ca-app-pub-...",
    interstitialAdUnitID: "ca-app-pub-...",
    bannerAdUnitID: "ca-app-pub-..."
)

HSAdManager.shared.configure(
    configuration: config,
    onPrepareAudio: {
        // Safe ducking: Pause audio engine / microphone
        AudioService.shared.pauseAudio()
    },
    isProUnlockedCheck: {
        // Suppress interstitial & app open ads for paying users
        return ProManager.shared.isProUnlocked
    }
)

// Show Rewarded Video with audio restoration:
HSAdManager.shared.showRewardedAd(
    onReward: {
        AudioService.shared.resumeAudio()
        // Grant reward
    },
    onFailure: {
        AudioService.shared.resumeAudio()
    }
)

// Show Interstitial (Enforces 2m cooldown automatically):
HSAdManager.shared.showInterstitialAd {
    AudioService.shared.resumeAudio()
}
```

### 4. Bottom Banner Component (`HSAds`)
```swift
import SwiftUI
import HSAds

public struct BannerAdContainerView: View {
    @ObservedObject private var proManager = ProFeatureManager.shared

    public var body: some View {
        if !proManager.isProUnlocked {
            HSBannerAdView(
                adUnitID: AdMobConfig.bannerAdUnitID,
                isProUnlocked: proManager.isProUnlocked
            )
        }
    }
}
```

### 5. Multi-Theme Engine (`HSUI`)
```swift
import HSUI

// Synchronize theme:
HSThemeManager.shared.currentTheme = .midnightOLED

// Observe in SwiftUI:
@ObservedObject private var theme = HSThemeManager.shared

// ColorScheme for WindowGroup:
.preferredColorScheme(theme.preferredColorScheme)

// Access standardized palette tokens:
let palette = theme.palette
// palette.background, palette.surface, palette.primaryText, palette.accent
```

---

## ✅ Action Checklist for Remaining Apps

Follow this checklist when migrating **ReaderLab** or **EmojiRiddle**:

- [ ] **Step 1: Link HSKit Package**
  - Add local package dependency `../HSKit` in your Xcode project.
  - Link `HSCore`, `HSAds`, and `HSUI` under Frameworks and Libraries.
- [ ] **Step 2: Update Info.plist & Privacy Keys**
  - Ensure `GADApplicationIdentifier` is set with your AdMob App ID.
  - Add `NSUserTrackingUsageDescription` with clear user justification.
  - Ensure `SKAdNetworkItems` includes Google AdMob identifiers.
  - Verify `PrivacyInfo.xcprivacy` covers `UserDefaults` API reasons.
- [ ] **Step 3: Replace Ad Management Boilerplate**
  - Replace raw GADInterstitialAd / GADRewardedAd loading with `HSAdManager`.
  - Add `AdMobConfig` wrapping `HSAdConfiguration`.
  - Wrap bottom banner in `HSBannerAdView`.
- [ ] **Step 4: Standardize StoreKit 2 Engine**
  - Replace raw StoreKit transaction listeners with `HSStoreManager.shared.configure(productIDs:)`.
  - Wire purchase, restore, and entitlement checks through `HSStoreManager`.
- [ ] **Step 5: Adopt Shared Theme & Audio Ducks**
  - Hook any sound or speech synthesizer to `onPrepareAudio` / `onResumeAudio`.
  - Replace custom theme selection with `HSThemeManager`.
  - Wire standard UI button feedback to `HSHapticsManager`.

---

## 📱 App-Specific Implementation Recipes

### 1. `ReaderLab`
* **Ad Configuration**: Set ReaderLab unit IDs. Rewarded ads can unlock **1 Free Document OCR Scan** or **24-Hour VIP Reading Pass**.
* **Audio Hook**: Connect `AVSpeechSynthesizer` or text-to-speech engine to `onPrepareAudio` so speech reading pauses during ad presentations and resumes upon dismissal.
* **Entitlements**: Register `com.saadapps.readerlab.lifetime` with `HSStoreManager`. Check `HSStoreManager.shared.isProductUnlocked(...)` to gate unlimited summaries or dark mode reading themes.

### 2. `FluidGlow` (Completed ✅)
* **Ad Configuration**: Rewarded video unlocks session-scoped fluid shaders (`FluidShaderPreset`).
* **Audio Hook**: `ASMRAudioEngine.shared.pauseAudio()` and `resumeAudio()` safely duck ASMR harmonic chimes.
* **Haptics**: High-frequency velocity fluid swirls remain in `FluidHapticsManager.fluidSwirl(speed:)`, while button taps and rewards trigger `HSHapticsManager`.
* **Entitlements**: `com.saadapps.fluidglow.vip` managed by `HSStoreManager`.

### 3. `EmojiRiddle`
* **Monetization Loop**:
  - **Rewarded Video**: Call `HSAdManager.shared.showRewardedAd` when user taps "Free Hint" or "Skip Riddle".
  - **Interstitial Ads**: Call `HSAdManager.shared.showInterstitialAd` on riddle level completions (2-minute cooldown ensures users are never spammed).
  - **In-App Purchase**: Register `"com.saadapps.emojiriddle.noads"` in `HSStoreManager` to permanently mute all non-rewarded ads.
* **Haptics**: Trigger `HSHapticsManager.success()` on correct riddle answers and `HSHapticsManager.error()` on wrong guesses.

---

## 🔍 Verification & Reference Code
Refer to these production implementations:
* **Decibel Pro**:
  - `DecibelPro/Sources/DecibelPro/Managers/AdManager.swift`
  - `DecibelPro/Sources/DecibelPro/Managers/ProFeatureManager.swift`
  - `DecibelPro/Sources/DecibelPro/Components/BannerAdContainerView.swift`
  - `DecibelPro/Sources/DecibelPro/Theme/AppTheme.swift`
* **FluidGlow**:
  - `FluidGlow/FluidGlow/Managers/AdManager.swift`
  - `FluidGlow/FluidGlow/Managers/ProFeatureManager.swift`
  - `FluidGlow/FluidGlow/Services/ASMRAudioEngine.swift`
  - `FluidGlow/FluidGlow/Views/BannerAdContainerView.swift`
  - `FluidGlow/FluidGlow/Theme/AppTheme.swift`
  - `FluidGlow/FluidGlow/FluidGlowApp.swift`
