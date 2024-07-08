//
//  SupportSettingViewController.swift
//  xTimer
//
//  Created by 程超 on 2024/3/28.
//

import Foundation
import AppKit

class SupportSettingViewController: NSViewController {
    @IBOutlet weak var emailButton: NSButton!
    
    @IBOutlet weak var websiteButton: NSButton!
    @IBOutlet weak var featureButton: NSButton!
    
    
    override func viewDidLoad() {
        emailButton.action = #selector(openEmail)
        emailButton.target = self
        
        websiteButton.action = #selector(openWebsite)
        websiteButton.target = self
        
        featureButton.action = #selector(openFeatureUrl)
        featureButton.target = self
    }
    
    @objc func openEmail() {
        if let url = URL(string: "mailto:\(DataModel.shared.email)") {
            let workspace = NSWorkspace.shared
            workspace.open(url)
        }
    }
    
    @objc func openWebsite() {
        if let url = URL(string: DataModel.shared.helpUrl) {
            let workspace = NSWorkspace.shared
            workspace.open(url)
        }
    }
    
    @objc func openFeatureUrl() {
        if let url = URL(string: "https://tally.so/r/wkyzKM") {
            let workspace = NSWorkspace.shared
            workspace.open(url)
        }
    }
    @IBAction func onPrivacyClick(_ sender: Any) {
        if let url = URL(string: "https://beauty-of-pixel.tech/privacy.html") {
            let workspace = NSWorkspace.shared
            workspace.open(url)
        }
    }
    @IBAction func onWelcomeClick(_ sender: Any) {
        NotificationCenter.default.post(name: .showWelcomeWindow, object: nil, userInfo: nil)
    }
}
