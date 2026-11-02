# AdMob & Google Play Closed Testing Playbook
### Standard Operating Procedure for FluidGlow Android
**Applies to:** `FluidGlow` (`com.saadapps.fluidglow`), and all personal Google Play developer account apps.

---

## 1. Executive Summary & The Golden Rule

> [!CAUTION]
> **NEVER serve live/production AdMob ads to a 20-tester Closed Testing group.**
> When only 12–20 people test an app, normal curiosity or accidental taps cause the Click-Through Rate (CTR) to spike from a normal 1–2% up to 20–50%. Because traffic is coming from a small circle of devices and IP addresses, Google’s automated fraud bots flag it as **Invalid Traffic (IVT)**, which results in a **30-day Ad Serving Limit** or permanent AdMob account suspension.

---

## 2. The 2-Phase Release Strategy

Every new app launched under a personal Google Play developer account follows this exact two-phase lifecycle:

```
[Phase 1: Closed Testing (14 Days)]
      ↓ (Uses Google Test Ad Unit IDs)
   • 20 testers test app features & watch test ads
   • Google fraud bots ignore all test clicks (0% risk)
   • Complete 14 consecutive days of testing
      ↓
[Apply for Production Access on Play Console]
      ↓ (Approved by Google Play Review)
[Phase 2: Production Release (v1.0.1)]
      ↓ (Uses Real Production Ad Unit IDs)
   • Link app in AdMob ("Add store" → Google Play)
   • Real commercial ads serve to the global public
   • Future updates go live in 1–2 days (NO 14-day wait!)
```

---

## 3. Google Official Sample / Test Ad Unit IDs

Google provides permanent test ad units specifically for development and testing. Clicks and impressions on these IDs are **never billed to advertisers and never penalized**:

| Ad Format | Official Google Test Ad Unit ID |
| :--- | :--- |
| **Banner** | `ca-app-pub-3940256099942544/6300978111` (or adaptive: `.../9214589741`) |
| **Rewarded Video** | `ca-app-pub-3940256099942544/5224354917` |
| **Interstitial** | `ca-app-pub-3940256099942544/1033173712` |
| **App Open** | `ca-app-pub-3940256099942544/9257395921` |

---

## 4. Code Architecture Implementation in FluidGlow

In `AppGraph.kt`, the explicit environment flag is configured:

```kotlin
// In com.saadapps.fluidglow.AppGraph companion object:
// Set to TRUE during the 14-day Closed Testing track
// Set to FALSE when building the final Production release
const val IS_CLOSED_TESTING = true 

val ads = HsAdController(
    context = context,
    units = if (BuildConfig.DEBUG || IS_CLOSED_TESTING) {
        // Safe Google Test Ads: zero risk of AdMob account bans
        AdUnits.googleTest
    } else {
        // Real Production Ads: for live public store only
        AdUnits.productionOrOff(
            banner = "ca-app-pub-4042428849777474/1629636157",
            interstitial = "ca-app-pub-4042428849777474/1960808648",
            rewarded = "ca-app-pub-4042428849777474/9316554486",
            appOpen = "ca-app-pub-4042428849777474/5433149792",
        )
    },
    premium = billing,
    consent = consent,
    onPresentationChanged = { showing ->
        if (showing) tones.pauseForAd() else tones.resumeAfterAd()
    },
)
```

---

## 5. Frequently Asked Questions (FAQ)

### Q1: Will Google Play Console become suspicious if I upload a new build with Test Ads?
**Answer: Absolutely NOT.**
1. **Testing is the exact purpose of Closed Testing:** Google expects developers to upload multiple build updates (`versionCode 1`, `2`, `3`, `4`) during the 14-day testing period as bugs are discovered and fixed.
2. **Google Play Scanner does not inspect AdMob IDs:** The automated Play Store security review only checks for viruses, malware, Target SDK 36 compliance, and Android security permissions. It does not evaluate internal AdMob strings.
3. **It is Google's official recommendation:** Google AdMob's developer docs explicitly tell developers: *"Always use test ads during testing and pre-release tracks."*

### Q2: Do I have to repeat the 14-day test when I add real ads in update v1.0.1?
**Answer: NO.**
* The 14-day test with 20 testers is a **one-time gateway** per new app to unlock **Production Access**.
* Once Production Access is granted, all subsequent updates (such as `v1.0.1` switching `IS_CLOSED_TESTING = false`) go through standard 1–2 day review and immediately publish to the live store.

### Q3: What about the next new app?
**Answer:**
* Each **brand-new app** on a personal developer account must complete its own 14-day closed test before its first public release.
* Every app follows this exact same playbook:
  1. Build with `AdUnits.googleTest` for Closed Testing (14 days).
  2. Apply for Production.
  3. Once approved, switch to real Ad IDs in update `v1.0.1`.

---

## 6. Pre-Submission Verification Checklist

Before uploading any `.aab` to Google Play Console:

- [x] `compileSdk = 36` and `targetSdk = 36` (Android 16).
- [x] Google Play Billing Library is updated to `8.0.0+`.
- [x] For **Closed Testing Build**: `IS_CLOSED_TESTING = true` (`units` uses `AdUnits.googleTest`).
- [ ] For **Production Build (Phase 2)**: `IS_CLOSED_TESTING = false` (`units` uses real `pub-4042428849777474` IDs).
- [ ] `versionCode` incremented by +1 in `build.gradle.kts` for each release bundle.
