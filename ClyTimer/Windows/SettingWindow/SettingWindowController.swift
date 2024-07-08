//
//  SettingWindowController.swift
//  xTimer
//
//  Created by 程超 on 2024/3/28.
//

import Foundation
import Foundation
import AppKit

class SettingsWindowController: NSWindowController {
    
    static func createSettingsWindowController() -> SettingsWindowController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("SettingStoryboard"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier(stringLiteral: "SettingsWindowController")
        guard let windowController = storyboard.instantiateController(withIdentifier: identifier) as? SettingsWindowController else {
            fatalError("Failed to load SettingsWindowController of type SettingsWindowController from the Main storyboard.")
        }
        return windowController
    }
}
