//
//  HotkeyViewController.swift
//  xTimer
//
//  Created by 程超 on 2024/4/15.
//

import Foundation
import AppKit
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggleWidgetPanel = Self("toggleWidgetPanel")
}

class FlippedClipView: NSClipView {
    override var isFlipped: Bool {
        return true
    }
}

class WidgetHotkeyView: NSView {
    let hotkeyLabel: String
    let hotkeyName: String
    
    init(hotkeyLabel: String, hotkeyName: String) {
        self.hotkeyLabel = hotkeyLabel
        self.hotkeyName = hotkeyName
        super.init(frame: .zero)
        setupView()
    }
    
    private func setupView() {
        let box = NSBox()
        box.title = "hello"
        box.boxType = .primary
        box.titlePosition = .noTitle
        box.autoresizingMask = [.width, .height]
        box.wantsLayer = true

        let textView = NSTextField()
        textView.isEditable = false
        textView.isBordered = false
        textView.isBezeled = false
        textView.isSelectable = true
        textView.stringValue = hotkeyLabel
        textView.drawsBackground = false
        textView.backgroundColor = .clear
        box.addSubview(textView)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 20),
            textView.centerYAnchor.constraint(equalTo: box.centerYAnchor, constant: 0),
        ])
        
        addSubview(box)
        
        box.contentView?.layer?.backgroundColor = NSColor.blue.cgColor
        
        
        box.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            box.leadingAnchor.constraint(equalTo: leadingAnchor),
            box.trailingAnchor.constraint(equalTo: trailingAnchor),
            box.topAnchor.constraint(equalTo: topAnchor),
            box.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        let recorder = KeyboardShortcuts.RecorderCocoa(for: .init(hotkeyName))
        addSubview(recorder)
        
        recorder.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recorder.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -20),
            recorder.centerYAnchor.constraint(equalTo: box.centerYAnchor, constant: 0),
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

struct WidgetHotkeyItem {
    let hotkeyName: String
    let hotkeyLabel: String
}

class HotkeyViewController: NSViewController {
    
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var widgetListHolder: NSView!
    
    override func viewDidLoad() {
        scrollView.scrollerStyle = .overlay
        let widgetHotkeyView = WidgetHotkeyView(hotkeyLabel: "Toggle Widget Panel", hotkeyName: "ToggleWidgetPanel")
        widgetListHolder.addSubview(widgetHotkeyView)
        
        
        
        widgetHotkeyView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widgetHotkeyView.leadingAnchor.constraint(equalTo: widgetListHolder.leadingAnchor, constant: 0),
            widgetHotkeyView.trailingAnchor.constraint(equalTo: widgetListHolder.trailingAnchor, constant: 0),
            widgetHotkeyView.topAnchor.constraint(equalTo: widgetListHolder.topAnchor, constant: 0),
            widgetHotkeyView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        
        widgetHotkeyView.translatesAutoresizingMaskIntoConstraints = false
        
        var lastElement = widgetHotkeyView
        
        let widgetList: [WidgetHotkeyItem] = [
            WidgetHotkeyItem(hotkeyName: "ToggleAllWidgetsVisible", hotkeyLabel: "Toggle All Widgets Visible"),
            WidgetHotkeyItem(hotkeyName: "com.sanci.browser", hotkeyLabel: "Show Browser widget"),
            WidgetHotkeyItem(hotkeyName: "com.sanci.emoji", hotkeyLabel: "Show Emoji widget"),
            WidgetHotkeyItem(hotkeyName: "com.sanci.note", hotkeyLabel: "Show Note widget"),
            WidgetHotkeyItem(hotkeyName: "com.sanci.camera", hotkeyLabel: "Show camera widget"),
            WidgetHotkeyItem(hotkeyName: "com.sanci.image", hotkeyLabel: "Show image widget"),
            WidgetHotkeyItem(hotkeyName: "com.sanci.clock", hotkeyLabel: "Show clock widget"),
//            WidgetHotkeyItem(hotkeyName: "com.sanci.timezone", hotkeyLabel: "Show timezone widget"),
        ]
        
        widgetList.forEach { item in
            let widgetHotkeyView = WidgetHotkeyView(hotkeyLabel: item.hotkeyLabel, hotkeyName: item.hotkeyName)
            widgetListHolder.addSubview(widgetHotkeyView)
            
            widgetHotkeyView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                widgetHotkeyView.leadingAnchor.constraint(equalTo: widgetListHolder.leadingAnchor, constant: 0),
                widgetHotkeyView.trailingAnchor.constraint(equalTo: widgetListHolder.trailingAnchor, constant: 0),
                widgetHotkeyView.topAnchor.constraint(equalTo: lastElement.bottomAnchor, constant: 10),
                widgetHotkeyView.heightAnchor.constraint(equalToConstant: 40)
            ])
            
            lastElement = widgetHotkeyView
        }
    }
}
