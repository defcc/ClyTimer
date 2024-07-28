import Foundation
import Cocoa
import QuickLook
import ApplicationServices
import KeyboardShortcuts


func getViewControllerFromStoryboard(forStoryboard: String, withIdentifier: String) -> NSViewController {
    let storyboard = NSStoryboard(name: forStoryboard, bundle: nil)
    return storyboard.instantiateController(withIdentifier: withIdentifier) as! NSViewController
}

extension NSNotification.Name {
    static let showPaywall = NSNotification.Name("showPaywall")
    static let showWelcomeWindow = NSNotification.Name("showWelcomeWindow")
    static let proSuccessEvt = NSNotification.Name("proSuccessEvt")
    static let showMenu = NSNotification.Name("showMenu")
}

class DragToCreateStatusButton: NSButton {
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        print("")
    }
}


@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItemButtonImage = NSImage(named: NSImage.Name("StatusIcon"))
    var statusItem : NSStatusItem!
    
    var noteStatusItem: NSStatusItem!
    var notePopover: NSPopover!
    
    var isDragged: Bool = false
    var lastChangeCount = 0
    var widgetStatusItemList: [UUID: NSStatusItem] = [:]
    var widgetPopoverList: [UUID: NSPopover] = [:]
    var statusItemButtonList: [NSButton: UUID] = [:]
    
    lazy var settingsWindowController: SettingsWindowController = {
        return SettingsWindowController.createSettingsWindowController()
    }()
    
    lazy var welcomeWindowController: WelcomeWindowController = {
        return WelcomeWindowController.createSettingsWindowController()
    }()
    
    var globalEventMonitor: Any!
    var localEventMonitor: Any!
        
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("ok")
        setupMenubarIcon()
        
        globalEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if !DataModel.shared.notchApp {
                return
            }
            
            let point = event.locationInWindow
            let rect = CGRect(origin: point, size: CGSize(width: 1, height: 1))
            if var notchRect = NSScreen.main!.notchRect {
                let margin: CGFloat = 10.0
                notchRect.origin.y += margin
                if notchRect.contains(rect) {
                    self!.createTimer()
                }
            }
            
        }
        
        localEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown]) { [weak self] event in
            self?.handleMouseDown(event: event)
        }
        
        if !DataModel.shared.hasShowWelcome {
            CollectData.shared.sendLog(for: .onboardingWindowFirstShow)
            showWelcomeWindow()
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showPaywall),
            name: .showPaywall,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showWelcomeWindow),
            name: .showWelcomeWindow,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showMenu),
            name: .showMenu,
            object: nil
        )
        
        registerShortcuts()
        
        CollectData.shared.initUser()
        CollectData.shared.sendLog(for: .appStartup)
    }
    
    func handleMouseDown(event: NSEvent) {
        if let button = statusItem?.button, let window = button.window {
            // Get the button's frame in window coordinates
            let buttonFrameInWindow = button.convert(button.bounds, to: nil)
            // Get the button's frame in screen coordinates
            let buttonFrameInScreen = window.convertToScreen(buttonFrameInWindow)
            // Get the current mouse location in screen coordinates
            let mouseLocation = NSEvent.mouseLocation
            
            if buttonFrameInScreen.contains(mouseLocation) {
                print("Mouse down on status button")
                // Handle mouse down event here
            }
        }
    }
    
    @objc func showQuickCreator() {
        guard let mainScreen = NSScreen.main else { return }
        let mainScreenFrame = mainScreen.frame
        
        let panel = NSPanel(contentRect: NSRect(x: 0, y: 0, width: 300, height: 460),
                            styleMask: [.nonactivatingPanel, .hudWindow],
                            backing: .buffered,
                            defer: false
        )
        panel.level = .popUpMenu
        panel.isOpaque = false
        panel.backgroundColor = .red
        
        
        panel.becomesKeyOnlyIfNeeded = true
        panel.hidesOnDeactivate = false
        
        panel.isExcludedFromWindowsMenu = true
        
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        panel.makeKeyAndOrderFront(nil)
        
        if let mainScreenFrame = NSScreen.main?.frame {
            let panelSize = panel.frame.size
            let xPosition = mainScreenFrame.origin.x + mainScreenFrame.size.width - panelSize.width - 20
            let yPosition = mainScreenFrame.origin.y + mainScreenFrame.size.height - panelSize.height - 100
            
            panel.setFrameOrigin(NSPoint(x: xPosition, y: yPosition))
        }
    }
    
    func setupMenubarIcon() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem.button {
            button.image = statusItemButtonImage
            button.image?.isTemplate = true
            button.setAccessibilityIdentifier("statusItemButton")
            button.action = #selector(showMenu)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }
    
    @objc func showMenu() {
        NSLog("show menu")
        
        statusItem.menu = setupMenuList()
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
        
        return
        
        let event = NSApp.currentEvent!
        if event.type == NSEvent.EventType.rightMouseUp {
            statusItem.menu = setupMenuList()
            statusItem.button?.performClick(nil)
            statusItem.menu = nil
            return
        } else {
            showWidgetPanel()
        }
    }
    
    @objc func showWidgetPanel() {
    }
    
    func setupMenuList() -> NSMenu {
        
        let menu = NSMenu()
        
        _ = menu
//            .with(menuItem: NSMenuItem.separator())
//            .with(menuItem: NSMenuItem(title: NSLocalizedString("Quickly create", comment: ""), action: nil, keyEquivalent: ""))
//            .with(menuItem: NSMenuItem(title: NSLocalizedString("10min Rest Time - FullScreen", comment: ""), action: #selector(createTimer), keyEquivalent: ""))
//            .with(menuItem: NSMenuItem(title: NSLocalizedString("25min Potato Clock - FullScreen", comment: ""), action: #selector(createTimer), keyEquivalent: ""))
//            
//            .with(menuItem: NSMenuItem.separator())
            .with(menuItem: NSMenuItem(title: NSLocalizedString("Create Timer", comment: ""), action: nil, keyEquivalent: ""))
            .with(menuItem: NSMenuItem(title: NSLocalizedString("Countdown Timer", comment: ""), action: #selector(showQuickCreator), keyEquivalent: ""))
            .with(menuItem: NSMenuItem(title: NSLocalizedString("Stopwatch", comment: ""), action: #selector(createCountupTimer), keyEquivalent: ""))
        
//            .with(menuItem: NSMenuItem.separator())
//            .with(menuItem: NSMenuItem(title: NSLocalizedString("Event List", comment: ""), action: nil, keyEquivalent: ""))
//            .with(menuItem: NSMenuItem(title: NSLocalizedString("Year Progress", comment: ""), action: #selector(createTimer), keyEquivalent: ""))
//            .with(menuItem: NSMenuItem(title: NSLocalizedString("Day Progress", comment: ""), action: #selector(createTimer), keyEquivalent: ""))
//            .with(menuItem: NSMenuItem(title: NSLocalizedString("Life Progress", comment: ""), action: #selector(createTimer), keyEquivalent: ""))
//            .with(menuItem: NSMenuItem(title: NSLocalizedString("Wife's Birthday", comment: ""), action: #selector(createTimer), keyEquivalent: ""))
//            .with(menuItem: NSMenuItem(title: NSLocalizedString("Days with ClyApp", comment: ""), action: #selector(createTimer), keyEquivalent: ""))
//            .with(menuItem: NSMenuItem(title: NSLocalizedString("More", comment: ""), action: #selector(createTimer), keyEquivalent: ""))
//        
//            .with(menuItem: NSMenuItem.separator())
//            .with(menuItem: NSMenuItem(title: NSLocalizedString("More", comment: ""), action: nil, keyEquivalent: ""))
//            .with(menuItem: NSMenuItem(title: NSLocalizedString("Create Countdown Event", comment: ""), action: #selector(createTimer), keyEquivalent: ""))
//            .with(menuItem: NSMenuItem(title: NSLocalizedString("Event List", comment: ""), action: #selector(createTimer), keyEquivalent: ""))
            
        
        let systemMenuItemList = ClyTimerMenu.shared.getSystemMenuList()
        systemMenuItemList.forEach {
            _ = menu.with(menuItem: $0)
        }
        return menu
    }
    
    @objc func createTimer() {
        _ = ProLoadingWindow(config: XTimerConfig(
            isFullscreen: DataModel.shared.defaultTimerConfig!.isFullscreen,
            subject: "Break Time",
            selectedTheme: NSColor(hex: "#d9f5d6")!,
            duration: DataModel.shared.defaultTimerConfig!.duration,
            adjustedDuration: DataModel.shared.defaultTimerConfig!.duration,
            startSoundId: DataModel.shared.defaultTimerConfig!.startSoundId,
            runningSoundId: DataModel.shared.defaultTimerConfig!.runningSoundId,
            timeUpSoundId: DataModel.shared.defaultTimerConfig!.timeUpSoundId,
            startSoundPlaybackMode: .specificTimes(count: 1),
            runningSoundPlaybackMode: .infinite,
            timeUpSoundPlaybackMode: .infinite
        ))
        
        CollectData.shared.sendLog(for: .createTimer)
    }
    
    @objc func createCountupTimer() {
        _ = ProLoadingWindow(config: XTimerConfig(
            isFullscreen: DataModel.shared.defaultTimerConfig!.isFullscreen,
            subject: "Break Time",
            selectedTheme: NSColor(hex: "#d9f5d6")!,
            duration: DataModel.shared.defaultTimerConfig!.duration,
            adjustedDuration: DataModel.shared.defaultTimerConfig!.duration,
            isCountdown: false,
            startSoundId: DataModel.shared.defaultTimerConfig!.startSoundId,
            runningSoundId: DataModel.shared.defaultTimerConfig!.runningSoundId,
            startSoundPlaybackMode: .specificTimes(count: 1),
            runningSoundPlaybackMode: .infinite
        ))
        
        CollectData.shared.sendLog(for: .createStopwatch)
    }
    
    
    @objc func showPaywall() {
        CollectData.shared.sendLog(for: .showPaywall)
        ProManager.shared.showPaywall()
    }
    
    @objc func showWelcomeWindow() {
        // If the window isn't visible, show it
        if !self.welcomeWindowController.window!.isVisible {
            self.welcomeWindowController.showWindow(nil)
            self.welcomeWindowController.window?.center()
        }
        
        self.welcomeWindowController.window?.setContentSize(.init(width: 640, height: 620))
        
        // Bring the window to front
        NSApp.activate(ignoringOtherApps: true)
    }
    
    
    deinit {
        if let monitor = self.globalEventMonitor {
            NSEvent.removeMonitor(monitor)
            globalEventMonitor = nil
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        CollectData.shared.sendLog(for: .appQuit)
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
