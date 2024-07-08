//
//  ColorSelector.swift
//  xTimer
//
//  Created by 程超 on 2024/1/29.
//

import Foundation
import AppKit

protocol ColorSelectorChangeDelegate {
    func onColorChange(color: NSColor)
}
class ColorSelector: NSView {
    var colorChangeDelegate: ColorSelectorChangeDelegate?
    var size: CGFloat = 10
    var selectedColor: NSColor?
    var onChange: (NSColor) -> Void = {_ in }
    
    lazy var colorListPopover: NSPopover = {
        let popover = NSPopover()
        let colorListViewController = ColorListViewController()
        colorListViewController.onSelectPopoverColor = onSelectPopoverColor
        popover.contentViewController = colorListViewController
        popover.contentSize = .init(width: 250, height: 230)
        popover.behavior = .transient
        return popover
    }()
    
    init(size: CGFloat, selectedColor: NSColor) {
        super.init(frame: .zero)
        self.size = size
        self.selectedColor = selectedColor
        
        setupUI()
        bindClick()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        setupUI()
        bindClick()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        wantsLayer = true
        layer?.cornerRadius = size / 2
        
        if let selectedColor = selectedColor {
            layer?.backgroundColor = selectedColor.cgColor
        }
        layer?.masksToBounds = true
    }
    
    func bindClick() {
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(openPopover))
        self.addGestureRecognizer(clickGesture)
    }
    
    @objc func openPopover(_ sender: NSGestureRecognizer) {
        colorListPopover.show(relativeTo: self.bounds, of: self, preferredEdge: .maxY)
    }
    
    func onSelectPopoverColor(color: NSColor) {
        layer?.backgroundColor = color.cgColor
        onChange(color)
    }
}
