# 🚀 Indie iOS App Standard Pre-Release & Architecture Checklist
> **Applies to:** All portfolio iOS apps (e.g., *DecibelPro*, *Emoji Riddle*, and future apps)  
> **Target:** Zero-rejection App Store submissions, sustainable monetization, and consistent UX excellence.

---

## 📋 The 10 Essential Pillars

```mermaid
flowchart TD
    P1["1. Core Architecture & UX"] --> P2["2. StoreKit 2 (VIP/Pro)"]
    P2 --> P3["3. Google AdMob Engine"]
    P3 --> P4["4. Multi-Theme Engine"]
    P4 --> P5["5. 6-Locale Localization"]
    P5 --> P6["6. Legal, Privacy & Terms"]
    P6 --> P7["7. Automated Unit Tests"]
    P7 --> P8["8. ASO Metadata Package"]
    P8 --> P9["9. App Store Screenshots (6.7\")"]
    P9 --> P10["10. Fastlane CI/CD Pipeline"]
```

---

## Pillar 1: Core Architecture & UX Polish
- [ ] **Modern SwiftUI + MVVM**: Strict separation between UI Views, State ViewModels, and Data Models.
- [ ] **Local Data Persistence**: Offline-first storage using `UserDefaults` or `SwiftData` for progress, currencies, unlocks, and settings.
- [ ] **Haptics Engine (`HSHapticsManager`)**: Sensory feedback on taps, reveals, error states, and completions using `UIImpactFeedbackGenerator` & `UINotificationFeedbackGenerator`.
- [ ] **Sound Manager (`SoundManager`)**: Custom audio effects with user toggle in Settings.
- [ ] **Safe Area & Device Adaptation**: Seamless layout on Dynamic Island, notch devices, home indicator, and iPad split views.
- [ ] **Onboarding & Game Guide (`WelcomeGuideView`)**: First-launch walkthrough explaining core value, controls, and rules.

---

## Pillar 2: StoreKit 2 Monetization (VIP / Pro Pass)
- [ ] **Product Model**: One-time non-consumable purchase (e.g., `$2.99 Lifetime VIP / Pro Pass`) or auto-renewable subscription.
- [ ] **`ProFeatureManager` / `VIPManager`**:
  - [ ] Built on modern Swift async/await (`Product.products(for:)`, `product.purchase()`).
  - [ ] Background transaction listener (`Transaction.updates`) to capture Family Sharing, outside purchases, and auto-renewals.
  - [ ] Reliable **Restore Purchases** flow calling `AppStore.sync()` and updating state.
- [ ] **Perks Structure**:
  - [ ] 100% ad removal permanently.
  - [ ] Welcome bonus virtual currency (e.g., +1,000 coins).
  - [ ] Permanent progression multiplier (e.g., 2× reward on solved items).
  - [ ] Daily replenished hints/perks with timestamp checks.
- [ ] **Settings Integration**: Dedicated VIP banner/card, active badge state, and restore button.

---

## Pillar 3: Google AdMob Engine & `app-ads.txt`
- [ ] **`AdManager` Singleton**:
  - [ ] Preloading and caching of ad instances.
  - [ ] Instant bypass for Pro/VIP users (`isVIPActive == true`).
- [ ] **The 3 Core Ad Formats**:
  1. **Adaptive Sticky Banner**: Anchored at bottom safe area. Disappears cleanly when VIP is purchased.
  2. **Level Transition Interstitial**: Shown periodically between actions (frequency-capped to avoid user fatigue).
  3. **Opt-in Rewarded Video**: Used for lifelines, extra coins, or hints (user-initiated only).
- [ ] **Google `app-ads.txt`**:
  - [ ] Published at domain root (`https://<domain>/app-ads.txt`).
  - [ ] Formatted correctly: `google.com, pub-XXXXXXXXXXXXXXXX, DIRECT, f08c47fec0942fa0`.
- [ ] **Privacy Framework**: App Tracking Transparency (ATT) prompt if serving personalized ads.

---

## Pillar 4: Multi-Theme Engine & Appearance
- [ ] **`AppTheme` Centralized Color Tokens**:
  - Primary accent, secondary accent, card backgrounds, surfaces, and text hierarchies.
- [ ] **5 Standard Appearance Modes**:
  1. ⚙️ **System**: Automatically matches iOS device appearance (Light/Dark).
  2. 🌙 **Modern Dark**: Sleek deep gray (#151922) with vibrant contrast.
  3. 🖤 **Midnight OLED**: Pure black (#000000) for OLED power saving.
  4. ⚡ **Cyber Neon / Vibrant**: High-energy themed palette with colored borders.
  5. ☀️ **Minimal Light**: Clean, high-legibility light theme.
- [ ] **Row Tap Feedback & Visual Verification**: Checkmarks and instant visual state transitions.

---

## Pillar 5: Multi-Language Localization (6 Locales)
- [ ] **Format**: Modern `Localizable.xcstrings` String Catalog.
- [ ] **6 Tier-1 Supported Languages**:
  - 🇺🇸 **English (`en`)** — Base language
  - 🇪🇸 **Spanish (`es`)**
  - 🇩🇪 **German (`de`)**
  - 🇫🇷 **French (`fr`)**
  - 🇯🇵 **Japanese (`ja`)**
  - 🇧🇷 **Portuguese - Brazil (`pt-BR`)**
- [ ] **100% Coverage Scope**:
  - All gameplay text, error prompts, hints, lifelines, level badges.
  - Settings, theme names, sound toggles, and VIP perk bullets.
  - Welcome Guide walkthrough titles and full descriptions.
- [ ] **SwiftUI Dynamic Resolution**: Wrap dynamic `String` variables in `LocalizedStringKey(...)` inside subviews to prevent bypassing catalog translation.
- [ ] **Automated Test Verification**: `LocalizationTests.swift` validating zero missing or empty keys across all 6 locales.

---

## Pillar 6: Legal, Privacy Policy & Terms of Service
- [ ] **Live Web Deployment**: Hosted via GitHub Pages (`https://rj707.github.io/<app-slug>/`).
- [ ] **Privacy Policy Requirements (Apple Guideline 5.1.1)**:
  - Disclose zero personal data (PII) collection.
  - Disclose on-device data storage via `UserDefaults`.
  - Disclose Apple StoreKit 2 handling all billing and receipts.
  - Disclose Google AdMob ad identifier processing and ATT opt-out instructions.
  - COPPA certification for family-friendly apps (zero tracking of children under 13).
- [ ] **Terms of Service (EULA)**:
  - Apple Standard EULA incorporation.
  - Virtual currency & non-consumable digital purchase terms.
  - Intellectual property notice & limitation of liability.
- [ ] **Developer Support & Help**:
  - Clear email contact (`hmsu1989@gmail.com`).
  - Frequently Asked Questions (how to restore purchases, how perks work).
- [ ] **In-App Link**: Clickable link inside SettingsView pointing to the live URL.

---

## Pillar 7: Automated Unit Test Suite
- [ ] **Xcode Test Target**: Integrated `<AppName>Tests` target in `.xcodeproj` scheme.
- [ ] **Mandatory Test Suites**:
  1. **ViewModel Tests**: State machines, progression logic, rewards, streak counting, persistent error recovery.
  2. **StoreKit 2 Tests**: Entitlement identifiers, product IDs, bonus granting logic, restore mocks.
  3. **AdManager Tests**: VIP bypass enforcement, singleton initialization.
  4. **Data Integrity Tests**: JSON decoding, puzzle/level count, duplicate key checks.
  5. **Localization Tests**: Complete string catalog key verification for all 6 languages.
- [ ] **Standard**: 100% pass rate (`** TEST SUCCEEDED **`) on latest iOS Simulator.

---

## Pillar 8: App Store Connect Metadata & ASO
- [ ] **`AppStoreMetadata.md` Document**:
  - **App Title**: Max 30 characters (Brand + Primary Keyword).
  - **Subtitle**: Max 30 characters (Clear value proposition).
  - **Keywords**: Max 100 characters (Comma-separated, no duplicate words, no spaces).
  - **Promotional Text**: Max 170 characters (Highlight key feature / VIP pass).
  - **Description**: Compelling hook, bulleted features, VIP pass breakdown, and legal footer.
- [ ] **App Store Categories**: Primary & Secondary category selections.
- [ ] **Age Rating Declaration**: Completed questionnaire for ads and in-app purchases.
- [ ] **In-App Purchase Setup**: Product ID registered with screenshot and display name.

---

## Pillar 9: App Store Marketing Screenshots (6.7" Super Retina XDR)
- [ ] **Specifications**:
  - Exact Apple 6.7" resolution: **1290 × 2796 pixels** (Portrait, PNG, 72+ DPI, sRGB).
- [ ] **5-Slide Storyboard**:
  - **Slide 1 (Hero)**: Main gameplay hook + value proposition headline.
  - **Slide 2 (Progression)**: Difficulty tiers, ranks, or level depth.
  - **Slide 3 (Customization)**: OLED Dark Mode, theme picker, or UI versatility.
  - **Slide 4 (Monetization)**: Lifetime VIP / Pro paywall highlighting 100% Ad-Free & Bonus perks.
  - **Slide 5 (Engagement)**: Welcome Guide, interactive tutorial, or smart hints.
- [ ] **Visual Standards**:
  - Realistic titanium/glass device frame.
  - SF Pro Rounded typography with high-contrast colored headlines.
  - Vibrant gradient backdrop matching app brand identity.

---

## Pillar 10: Fastlane & Release Pipeline
- [ ] **`fastlane/Appfile`**: Configured with `app_identifier` and `apple_id`.
- [ ] **`fastlane/Fastfile` Lanes**:
  - `lane :test`: Executes unit test suite across destination simulator.
  - `lane :build`: Archives the project with `build_app` (`gym`) into signed `.ipa`.
  - `lane :beta`: Builds and uploads directly to TestFlight via `upload_to_testflight`.
- [ ] **Git Synchronization**:
  - All features committed on `main`.
  - Tagged release versions (`v1.0.0`).
  - Synced to remote GitHub repository.

---

## 📊 App Readiness Scorecard (Template)

| Pillar | Requirement | Target Status | Verified Date |
| :--- | :--- | :---: | :---: |
| **1. Architecture** | SwiftUI MVVM + Offline Storage + Haptics | `DONE` | [ ] |
| **2. StoreKit 2** | $2.99 Lifetime Pro/VIP + Restore Flow | `DONE` | [ ] |
| **3. AdMob** | Banner + Interstitial + Rewarded + `app-ads.txt` | `DONE` | [ ] |
| **4. Themes** | 5 Modes (System, Dark, OLED, Cyber, Light) | `DONE` | [ ] |
| **5. Localization**| 6 Languages (en, es, de, fr, ja, pt-BR) + Tests | `DONE` | [ ] |
| **6. Legal / Privacy**| Live GitHub Pages Site + EULA + Support Email | `DONE` | [ ] |
| **7. Unit Tests** | 100% Pass Rate across Core, Pro, Ads, Loc | `DONE` | [ ] |
| **8. ASO Metadata** | Title, Subtitle, Keywords, Description | `DONE` | [ ] |
| **9. Screenshots** | 5x 6.7" Posters (1290x2796) with framing | `DONE` | [ ] |
| **10. Fastlane** | `test`, `build`, and `beta` lanes configured | `DONE` | [ ] |

---
*Maintained by Saad Indie App Studio • Built for repeatable 5-star iOS app releases.*
