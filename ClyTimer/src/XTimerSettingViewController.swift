import Foundation
import AppKit

protocol XTimerSettingDelegate {
    func subjectChange(subject: String)
    func fullscreenModeControlChange(isFullscreen: Bool)
    func backgroundColorChange(color: NSColor)
    func forgroundColorChange(color: NSColor)
    func themeChange(color: NSColor)
    func showTitleChange(showTitle: Bool)
    func showDurationChange(show: Bool)
    func timerModeChange(type: Int)
    func durationChange(duration: Int)
    func timeisUpTitleChange(title: String)
    func showExceededTimeChange(show: Bool)
    func showFlashChange(show: Bool)
    func changeDuration(delta: Int)
    
    func onStartSoundIdSelected(soundId: String)
    func onRunningSoundIDSelected(soundId: String)
    func onTimeUpSoundIdSelected(soundId: String)
    
    func onChangeStartSoundEnabled(enabled: Bool)
    func onChangeRunningSoundEnabled(enabled: Bool)
    func onChangeTimeUpSoundEnabled(enabled: Bool)
    
    
    func startSoundPlaybackModeChange(playbackMode: PlaybackMode)
    func runningSoundPlaybackModeChange(playbackMode: PlaybackMode)
    func timeUpSoundPlaybackModeChange(playbackMode: PlaybackMode)
    
    func timeUpSoundInterruptEnabledChange(enabled: Bool)
}

func getRealDurationFromSlider(val: Float) -> Int {
    switch (val) {
    case 0:
        return 5 * 60;
    case 12:
        return 10 * 60;
    case 24:
        return 15 * 60;
    case 36:
        return 30 * 60;
    case 48:
        return 45 * 60;
    case 60:
        return 60 * 60;
    default:
        return 15 * 60
    }
}

func mapToSliderValue(val: Int) -> Float {
    switch val {
    case 300:
        return 0;
    case 600:
        return 12;
    case 900:
        return 24;
    case 1800:
        return 36;
    case 2700:
        return 48;
    case 3600:
        return 60;
    default:
        return 24;
    }
}

struct RuntimeDurationChangeItem {
    let label: String
    let delta: Int
}

class XTimerSettingViewController: NSViewController, NSTextFieldDelegate {
    var delegate: XTimerSettingDelegate?
    var xTimer: XTimerViewController?
    
    // basic setting
    @IBOutlet weak var timerMode: NSSegmentedControl!
    @IBOutlet weak var durationInput: NSTextField!
    @IBOutlet weak var updateDurationInput: NSTextField!
    @IBOutlet weak var modeBoxHeight: NSLayoutConstraint!
    @IBOutlet weak var durationSlider: NSSlider!
    @IBOutlet weak var runtimeChangeDurationIncreaseButton: NSButton!
    @IBOutlet weak var runtimeChangeDurationDecreaseButton: NSButton!
    @IBOutlet weak var soundSettingEntry: NSBox!
    @IBOutlet weak var runtimeDurationChangeSelector: NSPopUpButton!
    
    let runtimeDurationChangeList: [RuntimeDurationChangeItem] = [
        RuntimeDurationChangeItem(label: "1m", delta: 60),
        RuntimeDurationChangeItem(label: "5m", delta: 300),
        RuntimeDurationChangeItem(label: "10m", delta: 600),
        RuntimeDurationChangeItem(label: "30m", delta: 1800),
        RuntimeDurationChangeItem(label: "5s", delta: 5),
        RuntimeDurationChangeItem(label: "10s", delta: 10),
        RuntimeDurationChangeItem(label: "30s", delta: 30)
    ]
    
    
    @IBOutlet weak var targetDateControl: NSDatePicker!
    @IBOutlet weak var startDateControl: NSDatePicker!
    @IBOutlet weak var alignmentControl: NSSegmentedControl!
    @IBOutlet weak var fullscreenModeControl: NSSwitch!
    
    @IBOutlet weak var isCountUpControl: NSSwitch!
    @IBOutlet weak var themeBoxView: NSBox!
    @IBOutlet weak var colorLabel: NSTextField!
    @IBOutlet weak var colorList: NSStackView!
    @IBOutlet weak var textColorList: NSStackView!
    
    var colorListView: ColorSelectorView?
    var defaultThemeList: [[NSColor]] = [XTimerConfig.builtinThemeList.map { $0.backgroundColor }]
    
    @IBOutlet weak var basicBox: NSBox!
    @IBOutlet weak var moreColorBoxButton: NSBox!
    @IBOutlet weak var moreBackgroundBox: NSBox!
    @IBOutlet weak var moreForgroundBox: NSBox!
    @IBOutlet weak var moreColorSelectorBoxLeading: NSLayoutConstraint!
    @IBOutlet weak var backToBasicSettingButton: NSButton!
    
    @IBOutlet weak var advancedEntryBlock: NSBox!
    @IBOutlet weak var advancedSettingView: NSBox!
    @IBOutlet weak var advancedSettingViewLeading: NSLayoutConstraint!
    @IBOutlet weak var advancedSettingViewBackButton: NSButton!
    @IBOutlet weak var advancedSettingShowTitle: NSSwitch!
    @IBOutlet weak var timeTitleInput: NSTextField!
    @IBOutlet weak var advancedSettingShowDuration: NSSwitch!
    @IBOutlet weak var timeisUpInput: NSTextField!
    @IBOutlet weak var showExceededTime: NSSwitch!
    
    // display setting
    @IBOutlet weak var showDurationBlock: NSBox!
    @IBOutlet weak var showExceededTimeBlock: NSBox!
    @IBOutlet weak var timeUpTextBlock: NSBox!
    @IBOutlet weak var showFlashBox: NSBox!
    @IBOutlet weak var last10SecondsFlashSwitch: NSSwitch!
    
    
    // sound setting
    @IBOutlet weak var soundSettingView: NSBox!
    @IBOutlet weak var soundSettingViewLeading: NSLayoutConstraint!
    @IBOutlet weak var soundBackButton: NSButton!
    @IBOutlet weak var startSoundSelectorNew: NSPopUpButton!
    @IBOutlet weak var startSoundDurationInput: NSTextField!
    @IBOutlet weak var runningSoundSelectorNew: NSPopUpButton!
    @IBOutlet weak var timeUpSoundSelectorNew: NSPopUpButton!
    @IBOutlet weak var timeUpKeepPlaying: NSSwitch!
    @IBOutlet weak var timeUpSoundDuration: NSTextField!
    @IBOutlet weak var startSoundDuration: NSTextField!
    @IBOutlet weak var startSoundModeSelector: NSSegmentedControl!
    @IBOutlet weak var startSoundBlock: NSBox!
    @IBOutlet weak var startSoundTextLabel: NSTextField!
    @IBOutlet weak var startSoundTextInput: NSTextField!
    @IBOutlet weak var startSoundValueInputBox: NSBox!
    @IBOutlet weak var startSoundBoxHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var timeUpSoundBox: NSBox!
    @IBOutlet weak var timeUpSoundModeSelector: NSSegmentedControl!
    @IBOutlet weak var timeUpSoundValueInputBox: NSBox!
    @IBOutlet weak var timeUpSoundTextLabel: NSTextField!
    @IBOutlet weak var timeUpSoundTextInput: NSTextField!
    @IBOutlet weak var timeUpSoundInteruptBox: NSBox!
    @IBOutlet weak var timeUpSoundInteruptButton: NSSwitch!
    @IBOutlet weak var timeUpSoundBoxHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var startSoundEnabledSwitch: NSSwitch!
    @IBOutlet weak var runningSoundEnabledSwitch: NSSwitch!
    @IBOutlet weak var timeUpSoundEnabledSwitch: NSSwitch!
    
    
    
    var bgColorListView: ColorSelectorView!
    var fgColorListView: ColorSelectorView!
    
    var moreBackgroundList: [[NSColor]] = [
        [
            NSColor.clear, 
            NSColor.lightGray,
            NSColor.gray,
            NSColor(hex: "#fef1f1")!,
            NSColor(hex: "#fff5eb")!,
            NSColor(hex: "#fefff0")!,
            NSColor(hex: "#f0fbef")!,
            NSColor(hex: "#f0f4ff")!,
            NSColor(hex: "#f6f1fe")!,
        ],
        [
            NSColor.white,
            NSColor.darkGray,
            NSColor.black,
            NSColor(hex: "#fde2e2")!,
            NSColor(hex: "#feead2")!,
            NSColor(hex: "#ffffcc")!,
            NSColor(hex: "#d9f5d6")!,
            NSColor(hex: "#e1eaff")!,
            NSColor(hex: "#ece2fe")!,
        ],
    ]
    
    var moreForgroundList: [[NSColor]] = [
        [
            NSColor.textColor,
            NSColor.black,
            NSColor.white,
            NSColor(hex: "#d83931")!,
            NSColor(hex: "#d83931")!,
            NSColor(hex: "#dc9b04")!,
            NSColor(hex: "#2ea121")!,
            NSColor(hex: "#245bdb")!,
            NSColor(hex: "#6425d0")!,
        ],
    ]
    
    let soundManager = SoundManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeTitleInput.delegate = self
        timeisUpInput.delegate = self
        
//        bindFullscreenModeControl()
        setupThemeSelector()
        setupMoreColor()
        
        
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(onMoreColorBoxButtonClick))
        moreColorBoxButton.addGestureRecognizer(clickGesture)
        
        let advancedEntryClickGesture = NSClickGestureRecognizer(target: self, action: #selector(onAdvancedEntryButtonClick))
        advancedEntryBlock.addGestureRecognizer(advancedEntryClickGesture)
        
        let soundEntryClickGesture = NSClickGestureRecognizer(target: self, action: #selector(onSoundEntryClick))
        soundSettingEntry.addGestureRecognizer(soundEntryClickGesture)
        
        advancedSettingShowTitle.target = self
        advancedSettingShowTitle.action = #selector(onShowTitleChange)
        
        advancedSettingShowDuration.target = self
        advancedSettingShowDuration.action = #selector(onShowDurationChange)
                
        setupRuntimeDurationChangeSelector()
        setupSoundList()
        
    }
    override func viewDidAppear() {
        guard let xTimerConfig = self.xTimer?.xTimerConfig else { return }
//        fullscreenModeControl.state = xTimerConfig.isFullscreen ? .on : .off
        
        timeTitleInput.stringValue = xTimerConfig.subject
        
        durationInput?.delegate = self
        
        if ![300, 600, 900, 1800, 2700, 3600].contains(xTimerConfig.duration) {
            durationInput?.stringValue = "\(Float(xTimerConfig.duration) / 60)"
        } else {
            durationInput?.stringValue = ""
        }
        
        timerMode.selectedSegment = xTimerConfig.isCountdown ? 0 : 1
        advancedSettingShowTitle.state = xTimerConfig.showTitle ? .on : .off
        advancedSettingShowDuration.state = xTimerConfig.showDuration ? .on : .off
        timeisUpInput.stringValue = xTimerConfig.timeisUpString
        durationSlider.floatValue = mapToSliderValue(val: xTimerConfig.duration)
        showExceededTime.state = xTimerConfig.showExceededTime ? .on : .off
        last10SecondsFlashSwitch.state = xTimerConfig.showFlashInTheLast10Seconds ? .on : .off
        
        if xTimerConfig.period == .started {
            durationSlider.isEnabled = false
            durationInput.isEditable = false
        } else {
            durationSlider.isEnabled = true
            durationInput.isEditable = true
        }
        
        self.modeBoxHeight.constant = xTimerConfig.period == .started ? 240 : 198
        
        renderStartSoundBox()
        renderRunningSoundBox()
        renderTimeUpSoundBox()
        
        renderTimerMode()
        
        if xTimerConfig.isCountdown {
            showDurationBlock.isHidden = false
            showExceededTimeBlock.isHidden = false
            timeUpTextBlock.isHidden = false
            showFlashBox.isHidden = false
        } else {
            showDurationBlock.isHidden = true
            showExceededTimeBlock.isHidden = true
            timeUpTextBlock.isHidden = true
            showFlashBox.isHidden = true
        }
    }
    
    func renderDisplaySettingView() {
        guard let xTimerConfig = self.xTimer?.xTimerConfig else { return }
        if xTimerConfig.isCountdown {
            showDurationBlock.isHidden = false
            showExceededTimeBlock.isHidden = false
            timeUpTextBlock.isHidden = false
        } else {
            showDurationBlock.isHidden = true
            showExceededTimeBlock.isHidden = true
            timeUpTextBlock.isHidden = true
        }
    }
    
    func setupRuntimeDurationChangeSelector() {
        runtimeDurationChangeSelector.removeAllItems()
        
        for val in runtimeDurationChangeList {
            runtimeDurationChangeSelector.addItem(withTitle: val.label)
        }
    }
    
    func setupSoundList() {
        startSoundSelectorNew.removeAllItems()
        startSoundSelectorNew.addItems(withTitles: SoundManager.startSoundList)
        startSoundSelectorNew.target = self
        startSoundSelectorNew.action = #selector(onStartSoundIdChange)
        
        startSoundModeSelector.target = self
        startSoundModeSelector.action = #selector(onStartSoundModeSelected)
        startSoundTextInput.delegate = self
        
        runningSoundSelectorNew.removeAllItems()
        runningSoundSelectorNew.addItems(withTitles: SoundManager.runningSoundList)
        runningSoundSelectorNew.target = self
        runningSoundSelectorNew.action = #selector(onRunningSoundIdChange)
        
        timeUpSoundSelectorNew.removeAllItems()
        timeUpSoundSelectorNew.addItems(withTitles: SoundManager.timeUpSoundList)
        timeUpSoundSelectorNew.target = self
        timeUpSoundSelectorNew.action = #selector(onTimeUpSoundIdChange)
        timeUpSoundTextInput.delegate = self
        
        timeUpSoundModeSelector.target = self
        timeUpSoundModeSelector.action = #selector(onTimeUpSoundModeSelected)
        
        timeUpSoundInteruptButton.target = self
        timeUpSoundInteruptButton.action = #selector(onInterruptChange)
        
        
        startSoundEnabledSwitch.target = self
        startSoundEnabledSwitch.action = #selector(onChangeStartSoundEnabled)
        runningSoundEnabledSwitch.target = self
        runningSoundEnabledSwitch.action = #selector(onChangeRunningSoundEnabled)
        timeUpSoundEnabledSwitch.target = self
        timeUpSoundEnabledSwitch.action = #selector(onChangeTimeUpSoundEnabled)
    }
    
    @objc func onChangeStartSoundEnabled() {
        delegate?.onChangeStartSoundEnabled(enabled: startSoundEnabledSwitch.state == .on)
    }
    @objc func onChangeRunningSoundEnabled() {
        delegate?.onChangeRunningSoundEnabled(enabled: runningSoundEnabledSwitch.state == .on)
    }
    @objc func onChangeTimeUpSoundEnabled() {
        delegate?.onChangeTimeUpSoundEnabled(enabled: timeUpSoundEnabledSwitch.state == .on)
    }
    
    @objc func onStartSoundIdChange() {
        let selected = startSoundSelectorNew.indexOfSelectedItem
        let soundId = SoundManager.startSoundList[selected]
        delegate?.onStartSoundIdSelected(soundId: soundId)
    }
    
    @objc func onRunningSoundIdChange() {
        let selected = runningSoundSelectorNew.indexOfSelectedItem
        let soundId = SoundManager.runningSoundList[selected]
        delegate?.onRunningSoundIDSelected(soundId: soundId)
    }
    
    @objc func onTimeUpSoundIdChange() {
        let selected = timeUpSoundSelectorNew.indexOfSelectedItem
        let soundId = SoundManager.timeUpSoundList[selected]
        delegate?.onTimeUpSoundIdSelected(soundId: soundId)
    }
    
    @objc func onStartSoundModeSelected() {
        var playbackMode: PlaybackMode
        let selectedIndex = startSoundModeSelector.selectedSegment
        if selectedIndex == 0 {
            startSoundTextInput.stringValue = "1"
            playbackMode = .specificTimes(count: 1)
        } else if selectedIndex == 1 {
            startSoundTextInput.stringValue = "10"
            playbackMode = .duration(seconds: 10)
        } else {
            playbackMode = .infinite
        }
        delegate?.startSoundPlaybackModeChange(playbackMode: playbackMode)
        renderStartSoundBox()
    }
    
    func renderStartSoundBox() {
        guard let xTimerConfig = self.xTimer?.xTimerConfig else { return }
        startSoundSelectorNew.selectItem(withTitle: xTimerConfig.startSoundId)
        startSoundEnabledSwitch.state = xTimerConfig.startSoundEnabled ? .on : .off
        
        switch xTimerConfig.startSoundPlaybackMode {
        case .specificTimes(let count):
            startSoundTextLabel.stringValue = "Sound Playing Counts"
            startSoundTextInput.stringValue = String(count)
            startSoundValueInputBox.isHidden = false
            startSoundBoxHeightConstraint.constant = 110
            startSoundModeSelector.selectedSegment = 0
        case .infinite:
            startSoundValueInputBox.isHidden = true
            startSoundBoxHeightConstraint.constant = 80
            startSoundModeSelector.selectedSegment = 2
        case .duration(let seconds):
            startSoundTextLabel.stringValue = "Sound Duration (seconds)"
            startSoundTextInput.stringValue = String(seconds)
            startSoundValueInputBox.isHidden = false
            startSoundBoxHeightConstraint.constant = 110
            startSoundModeSelector.selectedSegment = 1
        }
    }
    
    @objc func onTimeUpSoundModeSelected() {
        var playbackMode: PlaybackMode
        let selectedIndex = timeUpSoundModeSelector.selectedSegment
        if selectedIndex == 0 {
            timeUpSoundTextInput.stringValue = "1"
            playbackMode = .specificTimes(count: 1)
        } else if selectedIndex == 1 {
            timeUpSoundTextInput.stringValue = "10"
            playbackMode = .duration(seconds: 10)
        } else {
            playbackMode = .infinite
        }
        delegate?.timeUpSoundPlaybackModeChange(playbackMode: playbackMode)
        renderTimeUpSoundBox()
    }
    
    func renderTimeUpSoundBox() {
        guard let xTimerConfig = self.xTimer?.xTimerConfig else { return }
        
        timeUpSoundSelectorNew.selectItem(withTitle: xTimerConfig.timeUpSoundId)
        timeUpSoundEnabledSwitch.state = xTimerConfig.timeUpSoundEnabled ? .on : .off
        
        timeUpSoundInteruptButton.state = xTimerConfig.timeUpSoundInterruptEnabled ? .on : .off
        
        switch xTimerConfig.timeUpSoundPlaybackMode {
        case .specificTimes(let count):
            timeUpSoundTextLabel.stringValue = "Sound Playing Counts"
            timeUpSoundTextInput.stringValue = String(count)
            timeUpSoundValueInputBox.isHidden = false
            timeUpSoundInteruptBox.isHidden = true
            timeUpSoundBoxHeightConstraint.constant = 110
            
            timeUpSoundModeSelector.selectedSegment = 0
        case .infinite:
            timeUpSoundValueInputBox.isHidden = true
            timeUpSoundInteruptBox.isHidden = false
            timeUpSoundBoxHeightConstraint.constant = 140
            
            timeUpSoundModeSelector.selectedSegment = 2
        case .duration(let seconds):
            timeUpSoundTextLabel.stringValue = "Sound Duration (seconds)"
            timeUpSoundTextInput.stringValue = String(seconds)
            timeUpSoundValueInputBox.isHidden = false
            timeUpSoundInteruptBox.isHidden = true
            timeUpSoundBoxHeightConstraint.constant = 110
            
            timeUpSoundModeSelector.selectedSegment = 1
        }
    }
    
    
    @objc func onInterruptChange() {
        delegate?.timeUpSoundInterruptEnabledChange(enabled: timeUpSoundInteruptButton.state == .on)
    }
    
    func renderRunningSoundBox() {
        guard let xTimerConfig = xTimer?.xTimerConfig else { return }
        runningSoundSelectorNew.selectItem(withTitle: xTimerConfig.runningSoundId)
        
        runningSoundEnabledSwitch.state = xTimerConfig.runningSoundEnabled ? .on : .off
    }
    
    func bindFullscreenModeControl() {
        fullscreenModeControl.target = self
        fullscreenModeControl.action = #selector(fullscreenModeControlChange)
    }
    
    @objc func onShowTitleChange() {
        delegate?.showTitleChange(showTitle: advancedSettingShowTitle.state == .on)
    }
    
    @objc func onShowDurationChange() {
        delegate?.showDurationChange(show: advancedSettingShowDuration.state == .on)
    }
    
    @objc func fullscreenModeControlChange(_ sender: Any) {
        delegate?.fullscreenModeControlChange(isFullscreen: fullscreenModeControl.state == .on)
    }
    
    func onBackgroundColorChange(color: NSColor) {
        delegate?.backgroundColorChange(color: color)
    }
    
    func onForgroundColorChange(color: NSColor) {
        delegate?.forgroundColorChange(color: color)
    }
    
    func setupThemeSelector() {
        colorListView = ColorSelectorView(
            frame: .zero,
            colorList: defaultThemeList,
            size: 40
        )
        colorListView?.colorChange = onThemeChange
        themeBoxView.addSubview(colorListView!)
        
        NSLayoutConstraint.activate([
            colorListView!.leadingAnchor.constraint(equalTo: themeBoxView.leadingAnchor, constant: 10.0),
            colorListView!.trailingAnchor.constraint(equalTo: themeBoxView.trailingAnchor, constant: -10.0),
            colorListView!.topAnchor.constraint(equalTo: themeBoxView.topAnchor, constant: 10.0),
            colorListView!.bottomAnchor.constraint(equalTo: themeBoxView.bottomAnchor, constant: -10),
        ])
        
        colorListView!.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupMoreColor() {
        bgColorListView = ColorSelectorView(
            frame: .zero,
            colorList: moreBackgroundList,
            size: 26
        )
        bgColorListView.colorChange = onBackgroundColorChange
        moreBackgroundBox.addSubview(bgColorListView)
        
        NSLayoutConstraint.activate([
            bgColorListView.leadingAnchor.constraint(equalTo: moreBackgroundBox.leadingAnchor, constant: 0),
            bgColorListView.trailingAnchor.constraint(equalTo: moreBackgroundBox.trailingAnchor, constant: 0),
            bgColorListView.topAnchor.constraint(equalTo: moreBackgroundBox.topAnchor, constant: 0),
            bgColorListView.bottomAnchor.constraint(equalTo: moreBackgroundBox.bottomAnchor, constant: 0),
        ])
        
        bgColorListView.translatesAutoresizingMaskIntoConstraints = false
        
        fgColorListView = ColorSelectorView(
            frame: .zero,
            colorList: moreForgroundList,
            size: 26
        )
        fgColorListView.colorChange = onForgroundColorChange
        moreForgroundBox.addSubview(fgColorListView)
        
        NSLayoutConstraint.activate([
            fgColorListView.leadingAnchor.constraint(equalTo: moreForgroundBox.leadingAnchor, constant: 0),
            fgColorListView.trailingAnchor.constraint(equalTo: moreForgroundBox.trailingAnchor, constant: 0),
            fgColorListView.topAnchor.constraint(equalTo: moreForgroundBox.topAnchor, constant: 0),
            fgColorListView.bottomAnchor.constraint(equalTo: moreForgroundBox.bottomAnchor, constant: 0),
        ])
        
        fgColorListView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func onThemeChange(color: NSColor) {
        delegate?.themeChange(color: color)
    }
    
    @objc func onMoreColorBoxButtonClick(_ gesture: NSGestureRecognizer) {
        DispatchQueue.main.async {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.2
                self.moreColorSelectorBoxLeading.animator().constant = 0
                self.basicBox.animator().alphaValue = 0
                self.view.layoutSubtreeIfNeeded()
            } completionHandler: {                
                self.basicBox.isHidden = true
            }
        }
    }
    
    @objc func onAdvancedEntryButtonClick(_ gesture: NSGestureRecognizer) {
        DispatchQueue.main.async {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.2
                self.advancedSettingViewLeading.animator().constant = 0
                self.basicBox.animator().alphaValue = 0
                self.view.layoutSubtreeIfNeeded()
            } completionHandler: {
                self.basicBox.isHidden = true
            }
        }
    }
    
    @objc func onSoundEntryClick(_ gesture: NSGestureRecognizer) {
        DispatchQueue.main.async {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.2
                self.soundSettingViewLeading.animator().constant = 0
                self.basicBox.animator().alphaValue = 0
                self.view.layoutSubtreeIfNeeded()
            } completionHandler: {
                self.basicBox.isHidden = true
            }
        }
    }
    
    
    func controlTextDidChange(_ obj: Notification) {
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        if let textField = obj.object as? NSTextField {
            // Handle text changes here
            let newText = textField.stringValue
            if textField.isEditable == false {
                return
            }

            print("Text changed to: \(newText)")

            if textField == durationInput {
                if newText.isEmpty {
                    return
                }
                
                let minute = Float(newText)
                guard let minute = minute else { return }
                let seconds = minute * 60
                delegate?.durationChange(duration: Int(seconds))
            } else if textField == timeisUpInput {
                delegate?.timeisUpTitleChange(title: newText)
            } else if textField == startSoundTextInput {
                if let xTimerConfig = xTimer?.xTimerConfig {
                    switch xTimerConfig.startSoundPlaybackMode {
                    case .specificTimes:
                        delegate?.startSoundPlaybackModeChange(playbackMode: .specificTimes(count: Int(newText)!))
                    case .duration:
                        delegate?.startSoundPlaybackModeChange(playbackMode: .duration(seconds: Int(newText)!))
                    default:
                        print("done")
                    }
                }
            } else if textField == timeUpSoundTextInput {
                if let xTimerConfig = xTimer?.xTimerConfig {
                    switch xTimerConfig.timeUpSoundPlaybackMode {
                    case .specificTimes:
                        delegate?.timeUpSoundPlaybackModeChange(playbackMode: .specificTimes(count: Int(newText)!))
                    case .duration:
                        delegate?.timeUpSoundPlaybackModeChange(playbackMode: .duration(seconds: Int(newText)!))
                    default:
                        print("done")
                    }
                }
            }
            else {
                delegate?.subjectChange(subject: newText)
            }
        }
    }
    
    @IBAction func onDurationSliderChange(_ sender: Any) {
        let val = getRealDurationFromSlider(val: durationSlider.floatValue)
        delegate?.durationChange(duration: val)
        
    }
    @IBAction func onBackToBasicButtonClick(_ sender: Any) {
        self.basicBox.isHidden = false
        DispatchQueue.main.async {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.2
                self.moreColorSelectorBoxLeading.animator().constant = 320
                self.basicBox.animator().alphaValue = 1
                self.view.layoutSubtreeIfNeeded()
            } completionHandler: {
            }
        }
    }
    @IBAction func onAdvancedSettingViewBack(_ sender: Any) {
        self.basicBox.isHidden = false
        DispatchQueue.main.async {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.2
                self.advancedSettingViewLeading.animator().constant = 320
                self.basicBox.animator().alphaValue = 1
                self.view.layoutSubtreeIfNeeded()
            } completionHandler: {
            }
        }
    }
    @IBAction func onSoundSettingBack(_ sender: Any) {
        self.basicBox.isHidden = false
        DispatchQueue.main.async {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.2
                self.soundSettingViewLeading.animator().constant = 320
                self.basicBox.animator().alphaValue = 1
                self.view.layoutSubtreeIfNeeded()
            } completionHandler: {
            }
        }
    }
    @IBAction func onRandomColorClick(_ sender: Any) {
        let mainIndex = Int.random(in: 0..<moreForgroundList[0].count)
        
        print("mainIndex \(mainIndex)")
        let fgColor = moreForgroundList[0][mainIndex]
        delegate?.forgroundColorChange(color: fgColor)
        fgColorListView.selectColor(color: fgColor)
        
        let subIndex = Int.random(in: 0..<2)
        let bgColor = moreBackgroundList[subIndex][mainIndex]
        delegate?.backgroundColorChange(color: bgColor)
        bgColorListView.selectColor(color: bgColor)
        
        print("mainIndex \(mainIndex), subIndex \(subIndex)")
    }
    @IBAction func onTimerModeChange(_ sender: Any) {
        print(timerMode.selectedSegment)
        delegate?.timerModeChange(type: timerMode.selectedSegment)
        renderTimerMode()
        renderDisplaySettingView()
    }
    
    func renderTimerMode() {
        guard let xTimerConfig = self.xTimer?.xTimerConfig else { return }
        if xTimerConfig.isCountdown {
            self.durationInput.isHidden = false
        } else {
            self.durationInput.isHidden = true
        }
        
        DispatchQueue.main.async {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.2
                if xTimerConfig.isCountdown {
                    self.modeBoxHeight.animator().constant = self.xTimer?.xTimerConfig?.status == .running ? 240 : 198
                } else {
                    self.modeBoxHeight.animator().constant = 40
                }
                self.view.layoutSubtreeIfNeeded()
            } completionHandler: {
            }
        }
    }
    
    @IBAction func onShowFlashChange(_ sender: Any) {
        delegate?.showFlashChange(show: last10SecondsFlashSwitch.state == .on)
    }
    @IBAction func onShowExceededTimeChange(_ sender: Any) {
        delegate?.showExceededTimeChange(show: showExceededTime.state == .on)
    }
    @IBAction func onIncreaseDuration(_ sender: Any) {
        let changeItemIndex = runtimeDurationChangeSelector.indexOfSelectedItem
        let changeItem = runtimeDurationChangeList[changeItemIndex]
        let changedValue = changeItem.delta
        delegate?.changeDuration(delta: changedValue)
    }
    @IBAction func onDecreaseDuration(_ sender: Any) {
        let changeItemIndex = runtimeDurationChangeSelector.indexOfSelectedItem
        let changeItem = runtimeDurationChangeList[changeItemIndex]
        let changedValue = changeItem.delta
        delegate?.changeDuration(delta: -changedValue)
    }
    @IBAction func previewStartSound(_ sender: Any) {
        let selected = startSoundSelectorNew.indexOfSelectedItem
        let soundId = SoundManager.startSoundList[selected]
        soundManager.previewSound(soundId: soundId)
    }
    @IBAction func previewRunningSound(_ sender: Any) {
        let selected = runningSoundSelectorNew.indexOfSelectedItem
        let soundId = SoundManager.runningSoundList[selected]
        soundManager.previewSound(soundId: soundId)
    }
    @IBAction func previewTimeupSound(_ sender: Any) {
        let selected = timeUpSoundSelectorNew.indexOfSelectedItem
        let soundId = SoundManager.timeUpSoundList[selected]
        soundManager.previewSound(soundId: soundId)
    }
    
    func getSelectedDurationChange(index: Int) -> Int {
        switch index {
        case 0:
            return 60;
        case 1:
            return 5 * 60;
        case 2:
            return 10 * 60;
        case 3:
            return 30 * 60;
        case 4:
            return 10;
        case 5:
            return 30;
        default:
            return 5 * 60
        }
    }
}
