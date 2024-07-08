//
//  ColorListViewController.swift
//  xTimer
//
//  Created by 程超 on 2024/1/29.
//

import Foundation
import AppKit

class ColorListViewController: NSViewController {
    var colorList: [[NSColor]] = [
        [
            NSColor.clear, NSColor.white,  NSColor.gray, NSColor.lightGray, NSColor.darkGray,
            NSColor(hex: "#400c0c")!, NSColor(hex: "#0e3f29")!, NSColor(rgbaString: "rgba(238, 84, 0, 1)")!
        ],
        [
            NSColor.black,NSColor(hex: "#646a73")!, NSColor(hex: "#d83931")!, NSColor(hex: "#de7802")!,
            NSColor(hex: "#dc9b04")!, NSColor(hex: "#2ea121")!, NSColor(hex: "#245bdb")!, NSColor(hex: "#6425d0")!
        ],
        [
            NSColor(hex: "#e7feed")!, NSColor(hex: "#f5f6f7")!, NSColor(hex: "#fef1f1")!, NSColor(hex: "#fff5eb")!,
            NSColor(hex: "#fefff0")!, NSColor(hex: "#f0fbef")!, NSColor(hex: "#f0f4ff")!,
            NSColor(rgbaString: "rgba(246, 241, 254, 1)")!
        ],
        [
            NSColor(hex: "#f2f3f5")!, NSColor(hex: "#eff0f1")!, NSColor(hex: "#fde2e2")!,
            NSColor(hex: "#feead2")!, NSColor(hex: "#ffffcc")!, NSColor(hex: "#d9f5d6")!,
            NSColor(hex: "#e1eaff")!, NSColor(hex: "#ece2fe")!
        ],
        [
            NSColor(hex: "#2d2139")!, NSColor(hex: "#eff0f1")!, NSColor(hex: "#fbbfbc")!, NSColor(hex: "#fed4a4")!,
            NSColor(hex: "#fff67a")!, NSColor(hex: "#b7edb1")!, NSColor(hex: "#bacefd")!,
            NSColor(hex: "#cdb2fa")!
        ],
        [ NSColor(hex: "#ffe5e6")!]
    ]
    
    var colorListView: ColorSelectorView?
    
    var onSelectPopoverColor: (NSColor) -> Void =  {_ in }
    
    override func viewDidLoad() {
        colorListView = ColorSelectorView(
            frame: .zero,
            colorList: colorList
        )
        colorListView?.colorChange = onBorderColorChange
        view.addSubview(colorListView!)
        view.wantsLayer = true
        NSLayoutConstraint.activate([
            colorListView!.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0),
            colorListView!.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0),
            colorListView!.topAnchor.constraint(equalTo: view.topAnchor, constant: 20.0),
            colorListView!.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
        ])
        
        colorListView!.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func onBorderColorChange(color: NSColor) {
        print("onBorderColorChange \(color)")
        onSelectPopoverColor(color)
    }
}
