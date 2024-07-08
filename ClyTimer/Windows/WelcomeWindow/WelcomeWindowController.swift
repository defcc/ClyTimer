//
//  WelcomeWindowController.swift
//  xTimer
//
//  Created by 程超 on 2024/3/30.
//
import Foundation
import AppKit

class WelcomeWindowController: NSWindowController {
    
    static func createSettingsWindowController() -> WelcomeWindowController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("WelcomeStoryboard"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier(stringLiteral: "WelcomeWindowController")
        guard let windowController = storyboard.instantiateController(withIdentifier: identifier) as? WelcomeWindowController else {
            fatalError("Failed to load SettingsWindowController of type SettingsWindowController from the Main storyboard.")
        }
        return windowController
    }
}
