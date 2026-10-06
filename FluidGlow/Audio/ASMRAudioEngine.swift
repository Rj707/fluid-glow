import AVFoundation
import SwiftUI

public final class ASMRAudioEngine: ObservableObject {
    public static let shared = ASMRAudioEngine()
    
    @Published public var isSoundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSoundEnabled, forKey: "fluidglow_sound_enabled")
            if !isSoundEnabled {
                stopAllAudio()
            }
        }
    }
    
    private var engine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var isEngineRunning = false
    private var isAudioPausedForAd = false
    
    public init() {
        self.isSoundEnabled = UserDefaults.standard.object(forKey: "fluidglow_sound_enabled") as? Bool ?? true
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }
    
    public func pauseAudio() {
        isAudioPausedForAd = true
        stopAllAudio()
    }
    
    public func resumeAudio() {
        isAudioPausedForAd = false
    }
    
    public func playSwirlTone(speed: CGFloat) {
        guard isSoundEnabled, !isAudioPausedForAd else { return }
        // Play smooth haptic chime tone or gentle frequency response
        // Using system sounds or synthesized pitch based on speed
        let pitchTier = min(Int(speed / 15.0), 3)
        let soundIDs: [SystemSoundID] = [1103, 1104, 1105, 1106]
        let soundID = soundIDs[pitchTier]
        AudioServicesPlaySystemSound(soundID)
    }
    
    public func playBurstTone() {
        guard isSoundEnabled, !isAudioPausedForAd else { return }
        AudioServicesPlaySystemSound(1057) // Soft bubble pop
    }
    
    private func stopAllAudio() {
        playerNode?.stop()
        engine?.stop()
        isEngineRunning = false
    }
}
