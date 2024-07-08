//
//  ColorSelectorView.swift
//  Float Shelf
//
//  Created by 程超 on 2023/12/23.
//

import Foundation
import AppKit

class ColorSelectorView: NSView {
    var trackingAreasList: [NSTrackingArea] = []
    var colorViews: [NSView] = []
    var allColorList: [NSColor] {
        get {
            var rs: [NSColor] = []
            colorList.forEach {
                $0.forEach { item in
                    rs.append(item)
                }
            }
            return rs
        }
    }
    
    var selectedColor: NSColor?
    var selectedView: NSView?
    var size = 22.0
    var defaultBorderColor = NSColor.lightGray.withAlphaComponent(0.5).cgColor
    
    var colorList: [[NSColor]] = [] {
        didSet {
            createColorList()
        }
    }
    
    var colorChange: (NSColor) -> Void = {_ in }
    
    func createColorList() {
        
        var idx = 0
        for colorRow in colorList {
            var anchorElement: NSView? = self
            for color in colorRow {
                let colorView = NSView()
                addSubview(colorView)
                
                var leadingConstant = 0.0
                if anchorElement != self {
                    leadingConstant = size + 5
                }
                
                NSLayoutConstraint.activate([
                    colorView.leadingAnchor.constraint(equalTo: anchorElement!.leadingAnchor, constant: leadingConstant),
                    colorView.topAnchor.constraint(equalTo: topAnchor, constant: 0 + CGFloat(idx) * 30.0),
                    colorView.widthAnchor.constraint(equalToConstant: size),
                    colorView.heightAnchor.constraint(equalToConstant: size)
                ])
                
                colorView.translatesAutoresizingMaskIntoConstraints = false
                colorView.wantsLayer = true
                colorView.layer?.backgroundColor = NSColor.clear.cgColor
                colorView.layer?.borderColor = defaultBorderColor
                colorView.layer?.borderWidth = 1.0
                colorView.layer?.cornerRadius = 4.0
                
                let innerView = NSView()
                colorView.addSubview(innerView)
                
                NSLayoutConstraint.activate([
                    innerView.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 2),
                    innerView.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 2),
                    innerView.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -2),
                    innerView.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: -2)
                ])
                
                innerView.translatesAutoresizingMaskIntoConstraints = false
                innerView.wantsLayer = true
                innerView.layer?.cornerRadius = 2.0
                innerView.layer?.backgroundColor = color.cgColor
                
                // 添加点击手势
                let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(colorViewClicked(_:)))
                colorView.addGestureRecognizer(clickGesture)
                anchorElement = colorView
                colorViews.append(colorView)
            }
            idx += 1
        }
    }
    
    @objc func colorViewClicked(_ gesture: NSClickGestureRecognizer) {
        if let colorView = gesture.view as? NSView {
            // 处理点击事件，您可以在这里获取选定的颜色
            selectedView?.layer?.borderColor = defaultBorderColor
            
            if let backgroundColor = colorView.subviews.first?.layer?.backgroundColor {
                let currentColor = NSColor(cgColor: backgroundColor)
                print("Selected color: \(currentColor)")
                selectedColor = currentColor
                colorView.layer?.borderColor = NSColor.systemBlue.cgColor
                selectedView = colorView
                colorChange(currentColor!)
            }
        }
    }
    
    func selectColor(color: NSColor) {
        selectedView?.layer?.borderColor = defaultBorderColor
        
        
        let idx = allColorList.firstIndex {
            return $0 == color
        }
        
        guard let idx = idx else { return }
        
        let currentView = colorViews[idx]
        currentView.layer?.borderColor = NSColor.systemBlue.cgColor
        
        selectedView = currentView
    }
    
    override func mouseEntered(with event: NSEvent) {
        if let colorView = event.trackingArea?.owner as? NSView {
            let currentColor = colorView.subviews.first?.layer?.backgroundColor
            
            let currentNSColor = NSColor(cgColor: currentColor!)
            
            if currentNSColor?.getRGBAString() == selectedColor?.getRGBAString() {
                return
            }
            colorView.layer?.borderColor = NSColor.blue.cgColor
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        if let colorView = event.trackingArea?.owner as? NSView {
            let currentColor = colorView.subviews.first?.layer?.backgroundColor
            
            let currentNSColor = NSColor(cgColor: currentColor!)
            
            if currentNSColor?.getRGBAString() == selectedColor?.getRGBAString() {
                return
            }
            colorView.layer?.borderColor = defaultBorderColor
        }
    }
    
    init(frame frameRect: NSRect, colorList: [[NSColor]], size: CGFloat = 22) {
        super.init(frame: frameRect)
        self.colorList = colorList
        self.size = size
        createColorList()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupMouseenterAndExitEvents() {
        for colorView in colorViews {
            // 移除旧的 tracking area
            if let oldTrackingArea = colorView.trackingAreas.first {
                colorView.removeTrackingArea(oldTrackingArea)
            }
            
            // 添加新的 tracking area
            let trackingArea = NSTrackingArea(rect: colorView.bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: colorView, userInfo: nil)
            colorView.addTrackingArea(trackingArea)
        }
    }
    
    override func layout() {
        super.layout()
        setupMouseenterAndExitEvents()
    }
}
