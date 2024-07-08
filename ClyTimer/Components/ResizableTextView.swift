//
//  ResizableTextView.swift
//  xTimer
//
//  Created by 程超 on 2024/6/19.
//

import Foundation
import Cocoa

class ResizableTextView: NSView {
    private let textField: NSTextField
    
    override init(frame frameRect: NSRect) {
        textField = NSTextField(frame: frameRect)
        super.init(frame: frameRect)
        setupTextField()
    }
    
    required init?(coder: NSCoder) {
        textField = NSTextField()
        super.init(coder: coder)
        setupTextField()
    }
    
    private func setupTextField() {
        textField.isBordered = false
        textField.isEditable = false
        textField.isSelectable = false
        textField.alignment = .center
        textField.backgroundColor = .clear
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func setText(_ text: String) {
        textField.stringValue = text
        adjustFontSizeToFit()
    }
    
    override func layout() {
        super.layout()
        adjustFontSizeToFit()
    }
    
    private func adjustFontSizeToFit() {
        guard let font = textField.font else { return }
        let text = textField.stringValue as NSString
        let viewSize = bounds.size
        
        var minFontSize: CGFloat = 4.0
        var maxFontSize: CGFloat = 256.0
        var fontSize: CGFloat = maxFontSize
        
        while minFontSize <= maxFontSize {
            fontSize = (minFontSize + maxFontSize) / 2
            let newFont = NSFont(descriptor: font.fontDescriptor, size: fontSize)!
            let textSize = text.size(withAttributes: [NSAttributedString.Key.font: newFont])
            
            if textSize.width <= viewSize.width && textSize.height <= viewSize.height {
                minFontSize = fontSize + 0.1
            } else {
                maxFontSize = fontSize - 0.1
            }
        }
        
        textField.font = NSFont(descriptor: font.fontDescriptor, size: fontSize)
    }
}
