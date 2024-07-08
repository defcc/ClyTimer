import Foundation
import AppKit

class SoundConfigView: NSView {
    var title: String?
    var soundId: String?
    var soundList: [String] = []
    var mode: PlaybackMode?
    
    
    convenience init(title: String, soundId: String, soundList: [String]) {
        self.init(frame: .zero)
        self.title = title
        self.soundId = soundId
        self.soundList = soundList
        setupUI()
    }
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
    }
}
