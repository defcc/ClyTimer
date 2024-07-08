//
//  HUDPanel.swift
//  XTimer
//
//  Created by 程超 on 2024/2/6.
//

import Foundation
import AppKit
class HudPanel: NSWindow {
    override var canBecomeMain: Bool { true }
    override var canBecomeKey: Bool { true }
    override var acceptsFirstResponder: Bool { true }
    
    override init(contentRect: NSRect, styleMask aStyle: NSWindow.StyleMask, backing bufferingType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: aStyle, backing: bufferingType, defer: flag)
        
        // Set window properties
        self.backgroundColor = NSColor(red: 1, green: 1, blue: 1, alpha: 0.1) // Set your desired background color and opacity
        // todo immersiveMode
        // self.hasShadow = false
        self.isOpaque = false
        self.hasShadow = true
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        self.isReleasedWhenClosed = false
        
        self.contentView?.frame = self.contentRect(forFrameRect: self.frame)
        self.standardWindowButton(.closeButton)?.isHidden = true
        self.standardWindowButton(.miniaturizeButton)?.isHidden = true
        self.standardWindowButton(.zoomButton)?.isHidden = true
        self.isMovableByWindowBackground = true
    }
    
    func windowDidResize(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else {
            return
        }

        // Calculate the new width based on the height to maintain the aspect ratio
        var newFrame = window.frame
        newFrame.size.width = window.frame.size.height * aspectRatio.width / aspectRatio.height

        // Adjust the window frame
        window.setFrame(newFrame, display: true)
    }
    
    private var lastEvent: NSEvent?
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if lastEvent != nil && lastEvent?.timestamp == event.timestamp {
            return true
        }
        lastEvent = event
        
        guard let vc = contentViewController as? XTimerViewController  else {
            return true
        }
        
        // Check if the key pressed is Command + W
        if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "w" {
            vc.onCloseButtonClick("")
            return true
        }
        
        print("event keycode \(event.keyCode)")
         
        // space
        if event.keyCode == 49 {
            vc.onActionButtonClicked("")
            return true
        }
        // enter
        if event.keyCode == 36 {
            vc.onResetButtonClick("")
            return true
        }
        
        // Call the superclass implementation for other key equivalents
        return super.performKeyEquivalent(with: event)
    }
}
