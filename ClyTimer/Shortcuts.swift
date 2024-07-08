import Foundation
import KeyboardShortcuts

func registerShortcuts() {
    
    KeyboardShortcuts.onKeyUp(for: KeyboardShortcuts.Name("ToggleAllWidgetsVisible")) {
        NotificationCenter.default.post(
            name: NSNotification.Name(""),
            object: nil,
            userInfo: nil
        )
    }
}
