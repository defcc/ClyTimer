import Foundation
import AVFAudio

class SoundManager: NSObject {
    static var soundList: [String: String] = [
        "Beep": "Beep.aiff",
        "Bell": "Bell.aiff",
        "Digital": "Digital.aiff",
        "Doorbell": "Doorbell.aiff",
        "Gong": "Gong.aiff",
        "Klaxon": "Klaxon.aiff",
        "Mechanical": "Mechanical.aiff",
        "Notification": "Notification-1.wav",
        "Tweet": "Tweet.aiff",
        "Wall clock": "740545__sadiquecat__wall-clock-denoised.wav",
        "Calm Alarm": "640368__dan2008__calm-alarm.wav",
        "Hen Alarm": "575201__trp__alarm-clock-08.mp3",
        "Harp Motif2": "563311__davince21__harp-motif2.mp3",
        "Clock Tick": "257456__monter__116636__zermonths_clock_tick_cleaned-up_loop-ready.flac",
        "DiDi Alarm": "104475__rparson__alarm-clock-e.mp3",
        "Old Scots Tick": "42139__fauxpress__old-scots-clock-ticking.wav"
    ]
    
    static let startSoundList: [String] = [
        "Beep", "Bell", "Doorbell", "Gong", "Klaxon", "Notification", "Tweet"
    ]
    
    static let runningSoundList: [String] = [
        "Wall clock", "Clock Tick", "Old Scots Tick"
    ]
    
    static let timeUpSoundList: [String] = [
        "Beep", "Bell", "Doorbell", "Gong", "Klaxon", "Notification", "Tweet",
        "Digital", "Calm Alarm", "Hen Alarm", "DiDi Alarm", "Harp Motif2"
    ]
    
    var audioPlayer: AVAudioPlayer?
    var lastSound = ""
    var playBackDurationTimer: Timer?
    var onEnd: () -> Void = {}
    
    func playSound(soundId: String, playbackMode: PlaybackMode, onEnd: @escaping () -> Void = {}) {
        pauseSound()
        
        switch playbackMode {
        case .duration(let seconds):
            playSound(soundId: soundId, loop: -1)
            playBackDurationTimer = Timer.scheduledTimer(
                timeInterval: TimeInterval(seconds), target: self,
                selector: #selector(playbackDurationEnd), userInfo: nil, repeats: false)
        case .specificTimes(let count):
            playSound(soundId: soundId, loop: count - 1)
        default:
            playSound(soundId: soundId, loop: -1)
        }
        self.onEnd = onEnd
    }
    
    func updateSoundById(soundId: String, playbackMode: PlaybackMode) {
        pauseSound()
        
        switch playbackMode {
        case .specificTimes(let count):
            playSound(soundId: soundId, loop: count - 1)
        case .infinite:
            playSound(soundId: soundId, loop: -1)
        case .duration(let seconds):
            playSound(soundId: soundId, loop: -1)
        }
    }
    
    @objc func playbackDurationEnd() {
        stopPlayback()
        self.onEnd()
    }
    @objc func stopPlayback() {
        pauseSound()
        playBackDurationTimer?.invalidate()
        playBackDurationTimer = nil
    }
    
    func previewSound(soundId: String) {
        playSound(soundId: soundId, loop: 0)
    }
    
    func loadAudio(_ sound: String, loop: Int = 1) {
        lastSound = sound
        let soundFile = SoundManager.soundList[sound]
        if let audioFileURL = Bundle.main.url(forResource: soundFile, withExtension: nil, subdirectory: "sound-resource") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: audioFileURL)
                audioPlayer?.prepareToPlay()
                audioPlayer?.numberOfLoops = loop
                audioPlayer?.delegate = self
            } catch {
                print("Error loading audio file: \(error.localizedDescription)")
            }
        } else {
            print("Audio file not found.")
        }
    }
    
    func playSound(soundId: String, loop: Int = 1) {
        pauseSound()
        loadAudio(soundId, loop: loop)
        audioPlayer?.currentTime = 0
        audioPlayer?.play()
    }
    
    func pauseSound() {
        audioPlayer?.pause()
    }
}

extension SoundManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.onEnd()
    }
}
