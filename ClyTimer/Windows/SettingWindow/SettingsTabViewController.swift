//
//  SettingsTabViewController.swift
//  xTimer
//
//  Created by 程超 on 2024/3/28.
//

import Foundation
import Cocoa


class SettingsTabViewController: NSTabViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabViewItems[0].image = NSImage(systemSymbolName: "gearshape", accessibilityDescription: nil)
        tabViewItems[1].image = NSImage(systemSymbolName: "crown", accessibilityDescription: nil)
        tabViewItems[2].image = NSImage(systemSymbolName: "questionmark.circle", accessibilityDescription: nil)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        tabView.selectTabViewItem(at: 0)
        tabView(tabView, didSelect: tabView.tabViewItem(at: 0))
    }
    
    override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        if let window = tabView.window, let tabViewItem = tabViewItem {
            window.title = tabViewItem.label
        }
    }
}
