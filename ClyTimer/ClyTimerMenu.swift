import Foundation
import AppKit

class ClyTimerMenu {
    static var shared = ClyTimerMenu()
    
    lazy var settingsWindowController: SettingsWindowController = {
        return SettingsWindowController.createSettingsWindowController()
    }()
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(onProSuccessEvt), name: .proSuccessEvt, object: nil)
    }
    
    func getSystemMenuList() -> [NSMenuItem] {
        
        var menuItemList: [NSMenuItem] = [NSMenuItem.separator()]
        
        if DataModel.shared.isNeedToProVersion() {
            let upgradePro = NSMenuItem()
            let title = NSMutableAttributedString(string: NSLocalizedString("Upgrade to Pro", comment: ""), attributes: [NSAttributedString.Key.font: NSFont.menuFont(ofSize: 14)])
            
            var noticeMsg = ""
            if DataModel.shared.isInTrial {
                let trialCountdown = daysBetweenDates(Date(), DataModel.shared.trialEnd!)
                noticeMsg = "\(NSLocalizedString("Trial will expired in", comment: "")) \(trialCountdown) days"
            } else {
                noticeMsg = NSLocalizedString("3 days trial has expired", comment: "")
            }
            
            let subtitle = NSAttributedString(
                string: "\n\(noticeMsg)",
                attributes: [
                    NSAttributedString.Key.font: NSFont.menuFont(ofSize: 11),
                    NSAttributedString.Key.foregroundColor: NSColor.red
                ]
            )
            title.append(subtitle)
            upgradePro.attributedTitle = title
            upgradePro.action = #selector(showPaywall)
            upgradePro.keyEquivalent = ""
            
            
            upgradePro.image = NSImage(systemSymbolName: "crown", accessibilityDescription: nil)
            
            menuItemList.append(upgradePro)
            menuItemList.append(NSMenuItem.separator())
        }
        
        menuItemList.append(NSMenuItem(title: NSLocalizedString("Rate the App", comment: ""), action: #selector(openRateApp), keyEquivalent: ""))
        
        menuItemList.append(NSMenuItem(title: NSLocalizedString("Send Feedback", comment: ""), action: #selector(sayHello), keyEquivalent: ""))
        
        menuItemList.append(NSMenuItem(title: NSLocalizedString("About", comment: ""), action: #selector(showAboutWindow), keyEquivalent: ""))
        
        menuItemList.append(NSMenuItem.separator())
        
        menuItemList.append(NSMenuItem(title: NSLocalizedString("Settings", comment: ""), action: #selector(showSettings), keyEquivalent: ","))
        
        menuItemList.append(NSMenuItem.separator())
        
        menuItemList.append(NSMenuItem(title: NSLocalizedString("Quit ClyTimer", comment: ""), action: #selector(quit), keyEquivalent: "q"))
        
        menuItemList.forEach {
            $0.target = self
        }
        
        return menuItemList
    }
    
    @objc func sayHello() {
        if let url = URL(string: "mailto:\(DataModel.shared.email)?subject=ClyTimer issue") {
            let workspace = NSWorkspace.shared
            workspace.open(url)
        }
    }
    
    @objc func showSettings() {
        // If the window isn't visible, show it
        if !self.settingsWindowController.window!.isVisible {
            self.settingsWindowController.showWindow(nil)
            self.settingsWindowController.window?.center()
        }
        
        self.settingsWindowController.window?.setContentSize(.init(width: 480, height: 460))
        
        // Bring the window to front
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func onProSuccessEvt() {
        ProManager.shared.hidePaywall()
    }
    
    @objc func showPaywall() {
        ProManager.shared.showPaywall()
    }
    
    @objc func openRateApp() {
        let url = URL(string: "macappstore://apps.apple.com/app/id6504454659?action=write-review")
        NSWorkspace.shared.open(url!)
    }
    
    @objc func showAboutWindow() {
        NSApplication.shared.orderFrontStandardAboutPanel()
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
}
