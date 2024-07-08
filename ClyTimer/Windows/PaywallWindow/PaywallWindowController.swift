import Foundation
import Cocoa

class PaywallWindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    static func createWindowController() -> PaywallWindowController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Paywall"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier(stringLiteral: "PaywallWindowController")
        guard let windowController = storyboard.instantiateController(withIdentifier: identifier) as? PaywallWindowController else {
            fatalError("Failed to load PaywallWindowController of type PaywallWindowController from the Main storyboard.")
        }
        return windowController
    }
}
