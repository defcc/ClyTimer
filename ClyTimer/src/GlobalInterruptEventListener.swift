import Foundation
import AppKit

class GlobalInterruptEventListener {
    var globalEventMonitor: Any!
    var localEventMonitor: Any!
    
    func start(onInterrupt: @escaping () -> Void) {
        globalEventMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown, .mouseMoved, .keyDown]
        ) { [weak self] event in
            print("interrupt")
            onInterrupt()
        }
        
        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .leftMouseDown, .rightMouseDown, .mouseMoved]) { event in
            print("keydown")
            onInterrupt()
            return event
        }
        
    }
    
    func stop() {
        if let monitor = globalEventMonitor {
            NSEvent.removeMonitor(monitor)
            globalEventMonitor = nil
        }
        
        if let localMonitor = localEventMonitor {
            NSEvent.removeMonitor(localMonitor)
            localEventMonitor = nil
        }
    }
}
