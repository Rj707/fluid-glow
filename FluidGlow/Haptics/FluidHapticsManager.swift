import UIKit

public enum FluidHapticsManager {
    private static var isHapticsEnabled: Bool {
        UserDefaults.standard.object(forKey: "fluidglow_haptics_enabled") as? Bool ?? true
    }
    
    private static let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private static let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private static let softImpact = UIImpactFeedbackGenerator(style: .soft)
    private static let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
    private static let notificationGenerator = UINotificationFeedbackGenerator()
    
    public static func prepare() {
        guard isHapticsEnabled else { return }
        softImpact.prepare()
        lightImpact.prepare()
    }
    
    public static func fluidSwirl(speed: CGFloat) {
        guard isHapticsEnabled else { return }
        if speed > 30.0 {
            lightImpact.impactOccurred(intensity: 0.7)
        } else {
            softImpact.impactOccurred(intensity: 0.4)
        }
    }
    
    public static func burstPulse() {
        guard isHapticsEnabled else { return }
        mediumImpact.impactOccurred(intensity: 0.85)
    }
    
    public static func presetSwitched() {
        guard isHapticsEnabled else { return }
        rigidImpact.impactOccurred(intensity: 0.9)
    }
    
    public static func success() {
        guard isHapticsEnabled else { return }
        notificationGenerator.notificationOccurred(.success)
    }
}
