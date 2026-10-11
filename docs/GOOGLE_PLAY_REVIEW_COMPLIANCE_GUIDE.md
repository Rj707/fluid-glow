# 🤖 Google Play Store Review Compliance Guide
### Standard Operating Procedure for Android Apps: Fluid Glow (`com.saadapps.fluidglow`)

While Apple relies heavily on human reviewers in Cupertino, Google Play uses **automated static-analysis bots, policy scanners, and Firebase Test Lab robos**. Failing to comply can result not just in an app rejection, but in **account strikes** (3 strikes lead to permanent developer account termination).

AI coding agents and developers working on Android apps MUST follow these mandatory standards without exception.

---

## Table of Contents
1. [Google Play vs Apple Review: Key Differences](#1-google-play-vs-apple-review-key-differences)
2. [Data Safety Form vs Manifest Permissions (The Zero-Mismatch Rule)](#2-data-safety-form-vs-manifest-permissions-the-zero-mismatch-rule)
3. [Minimum Functionality & The Rewarded Ad Fallback](#3-minimum-functionality--the-rewarded-ad-fallback)
4. [Target API Level, 64-Bit & Android App Bundle (AAB)](#4-target-api-level-64-bit--android-app-bundle-aab)
5. [Target Audience & The Families Policy Trap](#5-target-audience--the-families-policy-trap)
6. [Better Ads Experience & Deceptive Ad Placement](#6-better-ads-experience--deceptive-ad-placement)
7. [Android Vitals: Crash Rates & ANR Thresholds](#7-android-vitals-crash-rates--anr-thresholds)
8. [The 20-Tester Closed Testing Requirement (New Accounts)](#8-the-20-tester-closed-testing-requirement-new-accounts)
9. [Pre-Submission Verification Checklist](#9-pre-submission-verification-checklist)

---

## 1. Google Play vs Apple Review: Key Differences

| Dimension | Apple App Store | Google Play Store |
| :--- | :--- | :--- |
| **Review Method** | Human reviewers in Cupertino test on physical devices/sandboxes. | Automated static analyzers, policy bots, and Firebase Test Lab robos. |
| **Rejection Impact** | Rejection note with resolution center dialog. | Policy violations, app removals, or **account strikes**. |
| **Data Disclosure** | App Privacy Nutrition Labels. | **Data Safety Form** (strictly cross-referenced against APK/AAB code). |
| **Crash Testing** | Manual smoke testing. | **Pre-Launch Report** runs automated monkey tests across 10+ physical devices. |
| **New Accounts** | Instant TestFlight & manual review queue. | **Mandatory 14-day closed testing with 20 testers** (for personal accounts created after Nov 2023). |

---

## 2. Data Safety Form vs Manifest Permissions (The Zero-Mismatch Rule)

> [!CRITICAL]
> Google Play's automated scanners extract every permission and third-party SDK from your compiled `.aab` and compare it against your **Data Safety** answers. Any discrepancy is flagged as **"Deceptive / False Data Safety Declaration"**.

### 1. Storage & Photos / Videos (`WRITE_EXTERNAL_STORAGE`)
* **Manifest**: `<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28" />`
* **Data Safety Answer**:
  * **Photos & Videos Collection**: Select **NO**.
  * **Explanation**: Fluid Glow only saves generated fluid wallpapers locally to the device Gallery/MediaStore. No photos are collected, uploaded, or transmitted to any server.

### 2. Audio & Microphone
* **Manifest**: Zero microphone permissions requested (`ToneSynth` generates tones entirely in software).
* **Data Safety Answer**:
  * **Audio Collection**: Select **NO**.

### 3. Advertising ID (`AD_ID`)
If Google Mobile Ads (AdMob) is included:
* **Manifest**: Google Play services adds `com.google.android.gms.permission.AD_ID` automatically.
* **Data Safety Answer**:
  * **Device or other IDs**: Select **YES**.
  * **Shared**: **YES** (shared with Google AdMob).
  * **Purposes**: Select **Advertising or marketing** and **Analytics**.
  * **Ephemeral**: Select **NO**.

### 4. Crash Diagnostics
* **Crash logs & Diagnostics**: Select **YES**.
* **Purposes**: Select **Analytics** and **App functionality**.
* **Encryption in Transit**: Select **YES** (all network requests use HTTPS/TLS).

---

## 3. Minimum Functionality & The Rewarded Ad Fallback

Google Play's **Minimum Functionality Policy** bans apps that have broken buttons, dead links, or fail to deliver advertised features.

### The Problem on Android:
* During automated testing (Pre-Launch Report) or initial launch, Google AdMob has **no fill (Error 3)** for brand-new ad unit IDs or offline test bots.
* If a user or bot taps *"Ad"* to unlock a fluid shader and AdMob fails to return an ad:
  > **If the app does nothing or redirects to a paywall, Google flags the feature as broken / non-functional.**

### Mandatory Solution: The Graceful Fallback Pattern
In Kotlin / Jetpack Compose:
```kotlin
onWatchAd = { item ->
    pulse(strong = true)
    val started = graph.ads.showRewarded(activity) {
        graph.grantTemporaryPreset(item)
        applyPreset(canvas, item) { preset = it }
    }
    showPresets = false
    if (!started) {
        // CRITICAL FALLBACK:
        // If AdMob has no fill (Error 3) or network is offline,
        // grant reward immediately so button is never dead or deceptive!
        graph.grantTemporaryPreset(item)
        applyPreset(canvas, item) { preset = it }
    }
}
```

---

## 4. Target API Level, 64-Bit & Android App Bundle (AAB)

Google Play Console enforces strict technical build requirements:

1. **Target SDK Requirement**:
   * All new apps MUST target **API Level 34 (Android 14)** or **API Level 35 (Android 15)**.
   * In `android/app/build.gradle.kts`:
     ```kotlin
     android {
         compileSdk = 35
         defaultConfig {
             targetSdk = 35
             minSdk = 26 // Covers 95%+ of active devices
         }
     }
     ```
2. **Format Requirement**:
   * Must upload an **Android App Bundle (`.aab`)**, NOT an `.apk`.
   * Built via: `cd android && ./gradlew bundleRelease`
3. **64-bit Native Libraries**:
   * If using native C/C++ audio code, you must include 64-bit architectures (`arm64-v8a`, `x86_64`).

---

## 5. Target Audience & The Families Policy Trap

Google Play's **Families Policy** is one of the most common causes of app suspensions:

> [!WARNING]
> If you select children under 13 as your target audience:
> 1. You CANNOT use standard AdMob ads. You must only use Google Families Self-Certified Ads SDKs.
> 2. You cannot collect Advertising IDs without strict COPPA compliance.
> 3. Your privacy policy must pass special scrutiny for children's data.

### Standard Recommendation:
In **Play Console → Policy → Target Audience and Content**:
* Select: **13 and older** (or 18+).
* In the question *"Could your store listing unintentionally appeal to children under 13?"*: Select **NO**.
* This allows standard AdMob monetization and standard data safety declarations.

---

## 6. Better Ads Experience & Deceptive Ad Placement

Google strictly enforces the **Better Ads Standards**:

1. **No Unexpected Interstitial Ads**:
   * Never show full-screen ads when the user is opening the app or when they press the Android Back button to exit.
   * Interstitials should only appear after a natural pause or completed action (e.g. after successfully saving a wallpaper).
2. **Audio Ducking / Muting**:
   * Synthesizer and sound effects must pause immediately when an ad presents (`tones.pauseForAd()`) and resume on ad dismissal (`tones.resumeAfterAd()`).
3. **5-Second Close Rule**:
   * Full-screen ads must have an explicit "X" close button after a maximum of 5 seconds.
4. **Banner Ad Collapse on No Fill**:
   * Never leave empty gray rectangles or blank slots if ads fail to fill.

---

## 7. Android Vitals: Crash Rates & ANR Thresholds

Google Play monitors your app's performance in real time via **Android Vitals**:

* **Bad Behavior Thresholds**:
  * **User-perceived Crash Rate**: Must stay **below 1.09%**.
  * **User-perceived ANR (Application Not Responding) Rate**: Must stay **below 0.47%**.
* **Impact of Exceeding Thresholds**:
  * Google Play will penalize your app by reducing organic search visibility and excluding it from editorial features and top charts.
* **Pre-Launch Report**:
  * Check the **Play Console → Quality → Pre-launch report** after uploading each release. If any device crashes on cold launch, fix the issue immediately before rolling out to production.

---

## 8. The 20-Tester Closed Testing Requirement (New Accounts)

For personal Google Play developer accounts created **after November 13, 2023**:

1. **Closed Testing Track**:
   * You cannot release directly to Production.
   * You must first run a **Closed Test** with at least **20 testers** who remain opted-in for at least **14 consecutive days**.
2. **Applying for Production Access**:
   * After 14 continuous days of testing, an "Apply for Production" button will appear in Play Console.
   * Google will ask a series of questions about your testing feedback, bug fixes, and release readiness before granting production rollout privileges.

---

## 9. Pre-Submission Verification Checklist

Before uploading an `.aab` bundle to Google Play Console, verify each item:

- [x] **Target SDK**: `targetSdk = 35` in `android/app/build.gradle.kts`.
- [x] **Data Safety**: All permissions (`AD_ID`, MediaStore) match the Play Console form exactly.
- [x] **Rewarded Fallback**: Tapping "Ad" grants reward immediately if AdMob returns Error 3 (No Fill) or offline.
- [x] **Feature Graphic**: `1024 × 500 px` generated in `docs/play_store/feature_graphic_1024x500.png`.
- [x] **App Icon**: `512 × 512 px` 24-bit RGB PNG generated in `docs/play_store/icon_512x512.png`.
- [x] **Screenshots**: 5 flagship 20:9 screenshots generated in `docs/play_store/screenshots/`.
- [x] **Target Audience**: Declared as 13+ (avoids Families Policy restrictions).
- [x] **Audio Safety**: Generative audio pauses cleanly when an ad displays.
- [ ] **Release Bundle**: Build with `cd android && ./gradlew bundleRelease` (AAB format, signed with upload keystore).
