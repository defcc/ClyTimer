//
//  WelcomeViewController.swift
//  xTimer
//
//  Created by 程超 on 2024/3/30.
//

import Foundation
import AppKit

class WelcomeViewController: NSViewController {
    
    @IBOutlet weak var menubarImageView: NSImageView!
    
    @IBOutlet weak var trialLeftDaysLabel: NSTextField!
    @IBOutlet weak var upgradeButton: NSButton!
    
    override func viewDidLoad() {
        menubarImageView.wantsLayer = true
        menubarImageView.layer?.cornerRadius = 6
        menubarImageView.layer?.masksToBounds = true
        
        if !DataModel.shared.isNeedToProVersion() {
            upgradeButton.isEnabled = false
            upgradeButton.title = NSLocalizedString("Actived", comment: "")
        }
    }
    @IBAction func onUpgradeButtonClick(_ sender: Any) {
        NotificationCenter.default.post(
            name: .showPaywall,
            object: nil,
            userInfo: nil
        )
    }
    @IBAction func onStartButtonClick(_ sender: Any) {
        view.window?.close()
        
        NotificationCenter.default.post(
            name: .showMenu,
            object: nil,
            userInfo: nil
        )
    }
}
