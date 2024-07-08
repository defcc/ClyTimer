import Foundation
import AppKit

class ProManager {
    static var shared = ProManager()
    
    lazy var paywallWindow = {
        let window = PaywallWindowController.createWindowController()
        return window
    }()
    
    func showPaywall() {
        // If the window isn't visible, show it
        if !paywallWindow.window!.isVisible {
            paywallWindow.showWindow(nil)
            paywallWindow.window?.center()
        }
        paywallWindow.window?.level = .floating
        paywallWindow.showWindow(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
        paywallWindow.window?.makeKeyAndOrderFront(nil)
        // Bring the window to front
    }
    
    func hidePaywall() {
        paywallWindow.window?.close()
    }
}
