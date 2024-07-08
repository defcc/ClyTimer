//
//  ProSettingViewController.swift
//  xTimer
//
//  Created by 程超 on 2024/3/28.
//

import Foundation
import AppKit

func formatDate(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    return formatter.string(from: date)
}

class ProSettingViewController: NSViewController {
    @IBOutlet weak var trialStatusLabel: NSTextField!
    @IBOutlet weak var trialStartAtLabel: NSTextField!
    @IBOutlet weak var trialEndAtLabel: NSTextField!
    @IBOutlet weak var proStatusLabel: NSTextField!
    @IBOutlet weak var proStartAtLabel: NSTextField!
    @IBOutlet weak var boxBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var boxHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var proStartLabel: NSTextField!
    @IBOutlet weak var proEndLabel: NSTextField!
    @IBOutlet weak var proStartValue: NSTextField!
    @IBOutlet weak var proEndValue: NSTextField!
    @IBOutlet weak var upgradeButton: NSButton!
    
    
    override func viewDidLoad() {
        renderProInfo()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onProSuccessEvt), name: .proSuccessEvt, object: nil)
    }
    
    func renderProInfo() {
        let userStatus = DataModel.shared.getUserStatus()
        if !userStatus.isInTrial && userStatus.isVip {
            trialStatusLabel.stringValue = "Expired"
            trialStatusLabel.textColor = NSColor.labelColor
            trialStartAtLabel.stringValue = "--"
            trialEndAtLabel.stringValue = "--"
            
            proStartValue.stringValue = formatDate(date: userStatus.vipStartAt!)
            proStatusLabel.stringValue = "Pro Actived"
            proStatusLabel.textColor = .systemGreen
            
            proStartLabel.isHidden = false
            proStartValue.isHidden = false
            proEndLabel.isHidden = false
            proEndValue.isHidden = false
            upgradeButton.isHidden = true
            
            boxHeightConstraint.constant = 246
            boxBottomConstraint.constant = 20
        } else {
            trialStatusLabel.stringValue = userStatus.isInTrial ? "Trial Actived" : "Trial Expired"
            trialStatusLabel.textColor = userStatus.isInTrial ? NSColor.systemGreen : .systemRed
            trialStartAtLabel.stringValue = formatDate(date: userStatus.trialStartAt)
            trialEndAtLabel.stringValue = formatDate(date: userStatus.trialEndAt)
            
            proStatusLabel.stringValue = "To be Upgraded"
            proStatusLabel.textColor = .labelColor
            
            proStartLabel.isHidden = true
            proStartValue.isHidden = true
            proEndLabel.isHidden = true
            proEndValue.isHidden = true
            
            boxHeightConstraint.constant = 182
        }
    }
    @IBAction func onUpgradeButtonClicked(_ sender: Any) {
        NotificationCenter.default.post(
            name: .showPaywall,
            object: nil,
            userInfo: nil
        )
    }
    
    @objc func onProSuccessEvt() {
        renderProInfo()
    }
}
