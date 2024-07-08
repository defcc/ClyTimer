//
//  GeneralSettingViewController.swift
//  xTimer
//
//  Created by 程超 on 2024/3/28.
//

import Foundation
import Cocoa
import LaunchAtLogin

struct BundleMeta {
    let bundleId: String
    let bundleName: String
}

class GeneralSettingsViewController: NSViewController {
    @IBOutlet weak var launchAtLoginButton: NSButton!
    @IBOutlet weak var notchEntry: NSSwitch!
    @IBOutlet weak var durationInput: NSTextField!
    @IBOutlet weak var startSound: NSPopUpButton!
    @IBOutlet weak var runningSound: NSPopUpButton!
    @IBOutlet weak var timeUpSound: NSPopUpButton!
    
    let appList: [BundleMeta] = [
        BundleMeta(bundleId: "", bundleName: "none"),
        BundleMeta(bundleId: "com.sanci.camera", bundleName: "Camera"),
        BundleMeta(bundleId: "com.sanci.note", bundleName: "Note"),
        BundleMeta(bundleId: "com.sanci.browser", bundleName: "Browser"),
        BundleMeta(bundleId: "com.sanci.emoji", bundleName: "Emoji")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLaunchAtLoginButton()
        setupNotchEntryButton()
        setupDefaultDuration()
        setupStartSoundIdButton()
        setupRunningSound()
        setupTimeUpSound()
    }
    
    override func viewWillAppear() {
        renderLaunchAtLogin()
        renderNotchEntry()
        renderDefaultDurationInput()
        renderSounds()
    }
    
    func renderSounds() {
        startSound.selectItem(withTitle: DataModel.shared.defaultTimerConfig!.startSoundId)
        runningSound.selectItem(withTitle: DataModel.shared.defaultTimerConfig!.runningSoundId)
        timeUpSound.selectItem(withTitle: DataModel.shared.defaultTimerConfig!.timeUpSoundId)
    }
    
    private func renderDefaultDurationInput() {
        let seconds = Float(DataModel.shared.defaultTimerConfig!.duration)
        let minute = seconds / 60
        durationInput.stringValue = "\(minute)"
    }
    
    private func setupDefaultDuration() {
        durationInput.delegate = self
    }
    
    private func setupStartSoundIdButton() {
        startSound.removeAllItems()
        startSound.addItems(withTitles: SoundManager.startSoundList)
        
        startSound.target = self
        startSound.action = #selector(onStartSoundSelect)
    }
    
    @objc func onStartSoundSelect() {
        let selectedId = startSound.titleOfSelectedItem
        DataModel.shared.updateDefaultTimerTemplate(updateBatch: [
            "startSoundId": selectedId
        ])
    }
    
    private func setupRunningSound() {
        runningSound.removeAllItems()
        runningSound.addItems(withTitles: SoundManager.runningSoundList)
        
        runningSound.target = self
        runningSound.action = #selector(onRunningSoundSelect)
    }
    
    @objc func onRunningSoundSelect() {
        let selectedId = runningSound.titleOfSelectedItem
        DataModel.shared.updateDefaultTimerTemplate(updateBatch: [
            "runningSoundId": selectedId
        ])
    }
    
    private func setupTimeUpSound() {
        timeUpSound.removeAllItems()
        timeUpSound.addItems(withTitles: SoundManager.timeUpSoundList)
        
        timeUpSound.target = self
        timeUpSound.action = #selector(onTimeUpSoundSelect)
    }
    
    @objc func onTimeUpSoundSelect() {
        let selectedId = timeUpSound.titleOfSelectedItem
        DataModel.shared.updateDefaultTimerTemplate(updateBatch: [
            "timeUpSoundId": selectedId
        ])
    }
    
    private func setupLaunchAtLoginButton() {
        launchAtLoginButton.target = self
        launchAtLoginButton.action = #selector(onLaunchAtLoginButtonClicked)
    }
    
    private func setupNotchEntryButton() {
        notchEntry.target = self
        notchEntry.action = #selector(onNotchEntryClicked)
    }
    
    @objc private func renderLaunchAtLogin() {
        launchAtLoginButton.state = DataModel.shared.launchAtLogin ? .on : .off
    }
    
    @objc private func renderNotchEntry() {
        notchEntry.state = DataModel.shared.notchApp ? .on : .off
    }
    
    @objc func onLaunchAtLoginButtonClicked() {
        DataModel.shared.updateLaunchAtLogin(launchAtLoginButton.state == .on)
    }
    
    @objc func onNotchEntryClicked() {
        DataModel.shared.updateNotchEntry(notchEntry.state == .on)
    }
}

extension GeneralSettingsViewController: NSTextFieldDelegate {
    func controlTextDidEndEditing(_ obj: Notification) {
        var newDuration = durationInput.stringValue
        guard !newDuration.isEmpty, let duration = Float(newDuration) else {
            return
        }
        
        let newDurationNumber = Int(duration * 60)
        if newDurationNumber != DataModel.shared.defaultTimerConfig?.duration {
            DataModel.shared.updateDefaultTimerTemplate(updateBatch: [
                "duration": newDurationNumber
            ])
        }
    }
}
