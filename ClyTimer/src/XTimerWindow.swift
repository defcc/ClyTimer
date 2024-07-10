import Foundation
import Cocoa
import AppKit

enum TimerStatus {
    case inited
    case started
    case running
    case paused
}

enum TimerPeriod {
    case inited
    case preparation
    case started
    case expired
}

struct BuiltinTheme {
    var backgroundColor: NSColor
    var forgroundColor: NSColor
}

enum PlaybackMode {
    case specificTimes(count: Int)
    case infinite
    case duration(seconds: Int)
}

struct XTimerConfig {
    var isFullscreen: Bool
    var subject: String
    var selectedTheme: NSColor {
        didSet {
            let currentTheme = XTimerConfig.builtinThemeList.first {
                return $0.backgroundColor.getRGBAString() == selectedTheme.getRGBAString()
            }
            
            guard let currentTheme = currentTheme else { return }
            backgroundColor = currentTheme.backgroundColor
            forgroundColor = currentTheme.forgroundColor
        }
    }
    var duration: Int
    var adjustedDuration: Int = 0
    var elapsed: Int = 0
    var isCountdown: Bool = true
    var showDuration: Bool = false
    var showTitle: Bool = false
    var status: TimerStatus = .inited
    var period: TimerPeriod = .inited
    var backgroundColor: NSColor = .clear
    var forgroundColor: NSColor = .textColor
    var timeisUpString: String = "Time's Up"
    var showExceededTime: Bool = true
    
    var showFlashInTheLast10Seconds: Bool = true
    
    var startSoundId: String = ""
    var runningSoundId: String = ""
    var timeUpSoundId: String = ""
    //
    var startSoundPlaybackMode: PlaybackMode = .specificTimes(count: 1)
    var runningSoundPlaybackMode: PlaybackMode = .infinite
    var timeUpSoundPlaybackMode: PlaybackMode = .infinite
    var timeUpSoundInterruptEnabled: Bool = true
    
    var startSoundEnabled: Bool = true
    var runningSoundEnabled: Bool = true
    var timeUpSoundEnabled: Bool = true
    
    
    // runtime state
    var runtimeTimeIsUp: Bool = false
    var runtimeTimerCountInSeconds: Int = 0
    
    static let builtinThemeList: [BuiltinTheme] = [
        BuiltinTheme(backgroundColor: .clear, forgroundColor: .textColor),
        BuiltinTheme(backgroundColor: .white, forgroundColor: .black),
        BuiltinTheme(backgroundColor: .gray, forgroundColor: .white),
        BuiltinTheme(backgroundColor: .black, forgroundColor: .white),
        BuiltinTheme(backgroundColor: NSColor(hex: "#ffffcc")!, forgroundColor: NSColor(hex: "#dc9b04")!),
        BuiltinTheme(backgroundColor: NSColor(hex: "#d9f5d6")!, forgroundColor: NSColor(hex: "#2ea121")!)
    ]
}



class XTimerWindow: NSObject {
    var xTimerConfig: XTimerConfig
    var panel: NSWindow?
    var lastWindowSize: CGSize?
    
    init(config: XTimerConfig) {
        xTimerConfig = config
        super.init()
        createTimerPanel()
        panel?.center()
        panel?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)        
    }
    
    func createTimerPanel() {
        var targetFrame = NSRect(x: 0, y: 0, width: 390, height: 280)
        
        if xTimerConfig.isFullscreen {
            guard let mainScreen = NSScreen.main else { return }
            let mainScreenFrame = mainScreen.frame
            
            let panelWidth = mainScreenFrame.size.width
            let panelHeight = mainScreenFrame.size.height + 20 // Adjust this height as needed
            targetFrame = NSRect(x: mainScreenFrame.origin.x, y: mainScreenFrame.origin.y, width: panelWidth, height: panelHeight)
        }
        
        let panel = HudPanel(contentRect: targetFrame,
                             styleMask: [.resizable, .fullSizeContentView, .hudWindow],
                            backing: .buffered,
                            defer: false
        )
        
        if !xTimerConfig.isFullscreen {
            panel.styleMask.insert(.titled)
        }
        
        panel.isOpaque = false
        panel.hasShadow = true
        panel.backgroundColor = .clear
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        
        panel.standardWindowButton(.closeButton)?.isHidden = true
        panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
        panel.standardWindowButton(.zoomButton)?.isHidden = true
        
        
        let storyboardHud = NSStoryboard(name: NSStoryboard.Name("XTimerWindow"), bundle: nil)
        if let viewController = storyboardHud.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("XTimerViewController")) as? XTimerViewController {
            viewController.view.frame = panel.contentView!.bounds
            viewController.xTimerConfig = xTimerConfig
            panel.contentViewController = viewController
            
            // Force the view to layout its subviews
            viewController.view.needsLayout = true
            viewController.view.layoutSubtreeIfNeeded()
            viewController.xTimerWindowDelegate = self
            viewController.initData()
        }
        
        panel.isOpaque = false
        
        panel.level = .popUpMenu
        
        
        panel.hidesOnDeactivate = false
        
        panel.isExcludedFromWindowsMenu = true
        
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        
        panel.isMovable = true
        panel.isMovableByWindowBackground = true
        panel.delegate = self
        
        if xTimerConfig.isFullscreen {
            setToFullscreen()
        }
        
        self.panel = panel
    }
    
    func setToFullscreen() {
        panel?.alphaValue = 0
        DispatchQueue.main.async {
            guard let panel = self.panel else { return }
            
            let windowFrame = panel.frame
            guard let screen = NSScreen.screens.first(where: { $0.frame.intersects(windowFrame) }) else { return }
            
            let frame = screen.frame
            
            let panelWidth = frame.size.width
            let panelHeight = frame.size.height + 20
            let panelFrame = NSRect(x: frame.origin.x, y: frame.origin.y, width: panelWidth, height: panelHeight)
            self.panel?.setContentSize(panelFrame.size)
            self.panel?.setFrameOrigin(panelFrame.origin)
            
            self.panel?.alphaValue = 1
            self.panel?.isMovableByWindowBackground = false
        }
    }
}

extension XTimerWindow: XTimerWindowDelegate {
    func onEnterFullscreen() {
        lastWindowSize = panel?.frame.size
        
        panel?.styleMask.remove(.titled)
        setToFullscreen()
    }
    
    func onExitFullscreen() {
        panel?.styleMask.insert(.titled)
        DispatchQueue.main.async {
            self.panel?.titleVisibility = .hidden
            self.panel?.titlebarAppearsTransparent = true
            
            self.panel?.standardWindowButton(.closeButton)?.isHidden = true
            self.panel?.standardWindowButton(.miniaturizeButton)?.isHidden = true
            self.panel?.standardWindowButton(.zoomButton)?.isHidden = true
            
            var targetSize = NSSize(width: 390, height: 280)
            if let lastSize = self.lastWindowSize {
                targetSize = lastSize
            }
            
            self.animatePanelSizeChange(to: targetSize)
        }
        panel?.isMovableByWindowBackground = true
    }
    
    
    func animatePanelSizeChange(to newSize: NSSize, duration: TimeInterval = 0.25) {
        if let panel = self.panel {
            let currentFrame = panel.frame
            let newOrigin = NSPoint(
                x: currentFrame.origin.x - (newSize.width - currentFrame.size.width) / 2,
                y: currentFrame.origin.y - (newSize.height - currentFrame.size.height) / 2
            )
            let newFrame = NSRect(origin: newOrigin, size: newSize)
            
            NSAnimationContext.runAnimationGroup { context in
                context.duration = duration
                panel.animator().setFrame(newFrame, display: true)
            }
        }
    }
    

}

extension XTimerWindow: NSWindowDelegate {
    func windowDidResize(_ notification: Notification) {
        guard let vc = panel?.contentViewController as? XTimerViewController else {
            return
        }
        
        print("window resize changed \(panel?.frame.size)")
        vc.calculateFontSize()
        vc.onResize()
    }
}
