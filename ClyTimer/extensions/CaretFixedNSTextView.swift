//
//  CaretFixedNSTextView.swift
//  Float Shelf
//
//  Created by 程超 on 2023/12/26.
//

import Foundation
import AppKit

class CaretFixedNSTextView: NSTextView {
    var placeholderString: String = "Enter text" {
        didSet {
            setNeedsDisplay(bounds)
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        if string.isEmpty && window?.firstResponder == self {
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: NSColor.placeholderTextColor,
                .font: font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
            ]
            
            let placeholderRect = NSInsetRect(bounds, textContainerOrigin.x + 4, 0)
            placeholderString.draw(in: placeholderRect, withAttributes: attributes)
        }
    }
    
    override func didChangeText() {
        super.didChangeText()
        setNeedsDisplay(bounds)
    }
    
    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        if result {
            ensureCursorBlink()
        }
        return result
    }

    func ensureCursorBlink() {
        if string.isEmpty {
            string = ""
        }
    }
}
