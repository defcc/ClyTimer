import Foundation
import AppKit

class ProLoadingWindow: NSObject {
    var xTimerConfig: XTimerConfig
    var panel: NSWindow?
    var proLoadingView: ProLoadingView!
    
    init(config: XTimerConfig) {
        xTimerConfig = config
        super.init()
        
        if DataModel.shared.isVip {
            _ = XTimerWindow(config: self.xTimerConfig)
            return
        }
        
        createTimerPanel()
        panel?.makeKeyAndOrderFront(nil)
        panel?.center()
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func createTimerPanel() {
        let panelFrame = NSRect(x: 0, y: 0, width: 400, height: 500)
        let panel = NSWindow(contentRect: panelFrame,
                             styleMask: [.fullSizeContentView, .titled, .closable],
                             backing: .buffered,
                             defer: false
        )
        
        proLoadingView = ProLoadingView()
        proLoadingView.frame.size = .init(width: 400, height: 500)
        panel.contentView = proLoadingView
        
        proLoadingView.start(count: 10) {
            self.panel?.performClose(nil)
            _ = XTimerWindow(config: self.xTimerConfig)
        }
        
        panel.titlebarAppearsTransparent = true
        panel.isMovable = true
        panel.isMovableByWindowBackground = true
        panel.isReleasedWhenClosed = false
        panel.delegate = self
        self.panel = panel
    }
}

extension ProLoadingWindow: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        proLoadingView.invalidTimer()
    }
}
