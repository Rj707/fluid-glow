import Foundation
#if canImport(FirebaseCore)
import FirebaseCore
#endif
#if canImport(FirebaseAnalytics)
import FirebaseAnalytics
#endif
#if canImport(FirebaseCrashlytics)
import FirebaseCrashlytics
#endif

/// Crash reports stay on. Usage analytics stay off until the privacy check allows them.
public enum AppReports {
    public static func start() {
        #if canImport(FirebaseCore)
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        #endif
        setCollectionAllowed(false)
    }

    public static func setCollectionAllowed(_ allowed: Bool) {
        #if canImport(FirebaseAnalytics)
        Analytics.setAnalyticsCollectionEnabled(allowed)
        #endif
    }

    public static func wallpaperSaved() {
        log("wallpaper_saved")
    }

    public static func presetSelected(_ presetName: String) {
        #if canImport(FirebaseAnalytics)
        Analytics.logEvent("preset_selected", parameters: ["preset_name": presetName])
        #endif
    }

    public static func vipUnlocked() {
        log("vip_unlocked")
    }

    public static func record(_ error: Error) {
        #if canImport(FirebaseCrashlytics)
        Crashlytics.crashlytics().record(error: error)
        #endif
    }

    public static func testCrash() {
        #if DEBUG
        fatalError("Debug test crash for Firebase Crashlytics")
        #endif
    }

    private static func log(_ name: String) {
        #if canImport(FirebaseAnalytics)
        Analytics.logEvent(name, parameters: nil)
        #endif
    }
}
