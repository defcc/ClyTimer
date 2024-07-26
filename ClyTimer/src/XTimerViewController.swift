import Foundation
import AppKit
import Cocoa

protocol XTimerWindowDelegate {
    func onEnterFullscreen() -> Void
    func onExitFullscreen() -> Void
}

class XTimerViewController: NSViewController {
    @IBOutlet weak var actionButton: NSButton!
    @IBOutlet weak var actionLabel: NSTextField!
    @IBOutlet weak var resetButton: NSButton!
    @IBOutlet weak var soundButton: NSButton!
    @IBOutlet weak var editButton: NSButton!
    @IBOutlet weak var closeButton: NSButton!
    @IBOutlet weak var rootView: NSVisualEffectView!
    @IBOutlet weak var backgroundView: NSBox!
    @IBOutlet weak var toggleFullscreenButton: NSButton!
    @IBOutlet weak var soundButtonTrailingConstraint: NSLayoutConstraint!
    
    var xTimerConfig: XTimerConfig? {
        didSet {
            updateTimerDisplay()
        }
    }
    var panel: NSPanel?
    var countdownLabel: NSTextField?
    var timer: Timer?
    var flashTimer: DispatchSourceTimer?
    var flashTimerFlag: Bool = true
    
    var totalDurationLabel: String {
        get {
            guard let xTimerConfig = xTimerConfig else { return "" }
            return getDisplayTimerString(seconds: xTimerConfig.adjustedDuration)
        }
    }
    var timeisUp: Bool = false
    var fontSize: CGFloat = 0
    var controlButton: NSButton?
    
    var trackingArea: NSTrackingArea?
    
    var xTimerWindowDelegate: XTimerWindowDelegate?
    
    lazy var settingPopover: NSPopover = {
        let popover = NSPopover()
        guard let settingVC = getViewControllerFromStoryboard(forStoryboard: "XTimerWindow", withIdentifier: "XTimerSettingViewControllerNew") as? XTimerSettingViewController else {
            return popover
        }
        settingVC.delegate = self
        settingVC.xTimer = self
        popover.contentViewController = settingVC
        popover.behavior = .transient
        popover.appearance = NSAppearance(named: NSAppearance.Name.aqua)
        popover.contentSize = CGSize(width: 320, height: 540)
        return popover
    }()
    
    lazy var timerTitle: NSTextField = {
        let title = NSTextField()
        title.stringValue = "25:00 - Break Time"
        title.isBezeled = false
        title.isEditable = false
        title.drawsBackground = false
        title.isBordered = false
        title.font = .systemFont(ofSize: 14)
        title.alignment = .center
        return title
    }()
    
    lazy var exceededLabel: NSTextField = {
        let label = NSTextField()
        label.stringValue = "Overtime 00:10:30"
        label.isBezeled = false
        label.isBordered = false
        label.isEditable = false
        label.drawsBackground = false
        label.font = .systemFont(ofSize: 14)
        label.alignment = .center
        return label
    }()
    
    var soundManager = SoundManager()
    var globalInterruptMonitor = GlobalInterruptEventListener()
    
    override func viewDidLoad() {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        backgroundView.wantsLayer = true
        
        addHoverButtonStyle(buttonList: [closeButton, editButton, soundButton])
        
        setupCountdownLabel()
        setupControlButton()
        setupTitle()
        setupExceedTime()
    }
    
    func addHoverButtonStyle(buttonList: [NSButton]) {
        buttonList.forEach {
            $0.wantsLayer = true
            $0.layer?.cornerRadius = 8
            $0.layer?.masksToBounds = true
            
            let trackingArea = NSTrackingArea(
                rect: soundButton.bounds,
                options: [.mouseEnteredAndExited, .activeAlways],
                owner: self,
                userInfo: ["moreButton": $0]
            )
            $0.addTrackingArea(trackingArea)
        }
        
    }
    
    func setupTitle() {
        timerTitle.translatesAutoresizingMaskIntoConstraints = false
        rootView.addSubview(timerTitle)
        
        NSLayoutConstraint.activate([
            timerTitle.bottomAnchor.constraint(equalTo: countdownLabel!.topAnchor, constant: -20),
            timerTitle.centerXAnchor.constraint(equalTo: countdownLabel!.centerXAnchor, constant: 0),
            timerTitle.widthAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])
    }
    
    func setupExceedTime() {
        exceededLabel.translatesAutoresizingMaskIntoConstraints = false
        exceededLabel.isHidden = true
        backgroundView.addSubview(exceededLabel)
        NSLayoutConstraint.activate([
            exceededLabel.topAnchor.constraint(equalTo: countdownLabel!.bottomAnchor, constant: 20),
            exceededLabel.centerXAnchor.constraint(equalTo: countdownLabel!.centerXAnchor, constant: 0),
            exceededLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])
    }
    
    func initData() {
        calculateFontSize()
        updateTimerDisplay()
        setupViewTrackingArea()
        updateThemeColor()
    }
    
    func updateThemeColor() {
        guard let xTimerConfig = xTimerConfig else { return }
        let currentTheme = XTimerConfig.builtinThemeList.first {
            return $0.backgroundColor.getRGBAString() == xTimerConfig.selectedTheme.getRGBAString()
        }
        
        guard let currentTheme = currentTheme else { return }
        backgroundView.layer?.backgroundColor = currentTheme.backgroundColor.cgColor
        updateTimerDisplay(forgroundColor: currentTheme.forgroundColor)
    }
    
    func setupViewTrackingArea() {
        trackingArea = NSTrackingArea(rect: view.bounds,
                                      options: [.mouseEnteredAndExited, .activeAlways],
                                      owner: self,
                                      userInfo: ["type": "full"])
        view.addTrackingArea(trackingArea!)
    }
    
    func updateTrackingArea() {
        if let trackingArea = trackingArea {
            view.removeTrackingArea(trackingArea)
        }
        
        trackingArea = NSTrackingArea(rect: view.bounds,
                                      options: [.mouseEnteredAndExited, .activeAlways],
                                      owner: self,
                                      userInfo: ["type": "full"])
        view.addTrackingArea(trackingArea!)
    }
    
    func setupCountdownLabel() {
        countdownLabel = NSTextField()
        
        guard let countdownLabel = countdownLabel else { return }
        countdownLabel.stringValue = ""
        countdownLabel.alignment = .center
        countdownLabel.isEditable = false
        countdownLabel.isSelectable = false
        countdownLabel.isBezeled = false
        countdownLabel.isBordered = false
        countdownLabel.drawsBackground = false
        
        backgroundView.addSubview(countdownLabel)
        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            countdownLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countdownLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func setupControlButton() {
        controlButton = NSButton()
        controlButton?.isHidden = true
        controlButton?.title = "Start"
        controlButton?.translatesAutoresizingMaskIntoConstraints = false
        rootView.addSubview(controlButton!)
        
        NSLayoutConstraint.activate([
            controlButton!.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            controlButton!.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
        controlButton?.target = self
    }
    
    @IBAction func onActionButtonClicked(_ sender: Any) {
        guard let xTimerConfig = xTimerConfig else { return }
        switch xTimerConfig.status {
        case .inited:
            self.xTimerConfig?.status = .started
            self.xTimerConfig?.period = .preparation
            playStartSound()
        case .running:
            actionLabel.stringValue = "PAUSED"
            actionButton.image = NSImage(systemSymbolName: "play.circle.fill", accessibilityDescription: "")
            self.xTimerConfig?.status = .paused
            stopClockTimer()
            soundManager.stopPlayback()
        case .paused:
            actionLabel.stringValue = "Pause"
            self.xTimerConfig?.status = .running
            actionButton.image = NSImage(systemSymbolName: "pause.circle.fill", accessibilityDescription: "")
            startClockTimer()
            playRunningSound()
        default:
            print("default")
        }
        updateTimerDisplay()
    }
    
    func changeStateToRunning() {
        self.actionLabel.stringValue = "Pause"
        self.xTimerConfig?.status = .running
        self.xTimerConfig?.period = .started
        self.actionButton.image = NSImage(systemSymbolName: "pause.circle.fill", accessibilityDescription: "")
        self.startClockTimer()
        self.playRunningSound()
    }
    
    func playStartSound() {
        guard let xTimerConfig = xTimerConfig else { return }
        if !xTimerConfig.startSoundEnabled || xTimerConfig.startSoundId.isEmpty {
            self.changeStateToRunning()
            return
        }
        soundManager.playSound(soundId: xTimerConfig.startSoundId, playbackMode: xTimerConfig.startSoundPlaybackMode) {
            self.changeStateToRunning()
        }
    }
    
    func playTimeUpSound() {
        guard let xTimerConfig = xTimerConfig else { return }
        if !xTimerConfig.timeUpSoundEnabled || xTimerConfig.timeUpSoundId.isEmpty {
            return
        }
        soundManager.playSound(soundId: xTimerConfig.timeUpSoundId, playbackMode: xTimerConfig.timeUpSoundPlaybackMode)
    }
    
    func playRunningSound() {
        guard let xTimerConfig = xTimerConfig else { return }
        if !xTimerConfig.runningSoundEnabled || xTimerConfig.runningSoundId.isEmpty {
            return
        }
        soundManager.playSound(soundId: xTimerConfig.runningSoundId, playbackMode: xTimerConfig.runningSoundPlaybackMode)
    }
    
    @objc func toggleFullscreen() {
        guard let xTimerConfig = xTimerConfig else { return }
        self.xTimerConfig?.isFullscreen.toggle()
        
        if xTimerConfig.isFullscreen {
            xTimerWindowDelegate?.onEnterFullscreen()
        } else {
            xTimerWindowDelegate?.onExitFullscreen()
        }
    }
    
    override func mouseEntered(with event: NSEvent) {
        if let button = event.trackingArea?.userInfo?["moreButton"] as? NSButton {
            button.layer?.backgroundColor = NSColor.quaternaryLabelColor.cgColor
        }
        
        if let userInfo = event.trackingArea?.userInfo {
            if let userType = userInfo["type"] as? String {
                if userType == "full" {
                    if xTimerConfig?.status == .paused {
                        actionLabel.isHidden = true
                    }
                    actionButton.isHidden = false
                    resetButton.isHidden = false
                    toggleFullscreenButton.isHidden = false
                    closeButton.isHidden = false
                    editButton.isHidden = false
                    
                    DispatchQueue.main.async {
                        NSAnimationContext.runAnimationGroup { context in
                            context.duration = 0.2
                            self.soundButtonTrailingConstraint.animator().constant = -15
                        } completionHandler: {
                        }
                    }
                }
            }
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        if let button = event.trackingArea?.userInfo?["moreButton"] as? NSButton {
            button.layer?.backgroundColor = .clear
        }
        
        if let userInfo = event.trackingArea?.userInfo {
            if let userType = userInfo["type"] as? String {
                if userType == "full" {
                    if xTimerConfig?.status == .paused {
                        actionLabel.isHidden = false
                        actionButton.isHidden = false
                    } else {
                        actionButton.isHidden = true
                    }
                    resetButton.isHidden = true
                    toggleFullscreenButton.isHidden = true
                    closeButton.isHidden = true
                    editButton.isHidden = true
                    
                    DispatchQueue.main.async {
                        NSAnimationContext.runAnimationGroup { context in
                            context.duration = 0.2
                            self.soundButtonTrailingConstraint.animator().constant = 15
                        } completionHandler: {
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func onEditButtonClick(_ sender: NSButton) {
        
        if let window = self.view.window {
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            if let settingPopoverVC = settingPopover.contentViewController as? XTimerSettingViewController {
                settingPopover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .maxY)
            }
        }
    }
    
    @IBAction func onMoreButtonClick(_ sender: NSButton) {
        let buttonRect = sender.bounds
        
        // Calculate the origin of the menu
        let origin = NSPoint(x: buttonRect.origin.x, y: buttonRect.origin.y + buttonRect.size.height)
        
        let moreMenu = NSMenu()
        let systemMenuItemList = ClyTimerMenu.shared.getSystemMenuList()
        systemMenuItemList.forEach {
            moreMenu.with(menuItem: $0)
        }
        
        // Display the menu
        moreMenu.popUp(positioning: nil, at: origin, in: sender)
    }
    @IBAction func onResetButtonClick(_ sender: Any) {
        guard let xTimerConfig = xTimerConfig else { return }
        
        self.xTimerConfig?.elapsed = 0
        
        let duration = self.xTimerConfig?.duration
        self.xTimerConfig?.adjustedDuration = (duration)!
        
        timeisUp = false
        
        stopClockTimer()
        stopFlashTimer()
        
        self.xTimerConfig?.status = .inited
        self.xTimerConfig?.period = .inited
        
        updateTimerDisplay()
        actionButton.image = NSImage(systemSymbolName: "play.circle.fill", accessibilityDescription: "")
        
        soundManager.stopPlayback()
    }
    @IBAction func onCloseButtonClick(_ sender: Any) {
        stopClockTimer()
        soundManager.stopPlayback()
        view.window?.close()
    }
    @IBAction func onToggleFullscreenButtonClicked(_ sender: Any) {
        fullscreenModeControlChange(isFullscreen: true)

        guard let xTimerConfig = xTimerConfig else { return }

        if xTimerConfig.isFullscreen {
            toggleFullscreenButton.image = NSImage(systemSymbolName: "rectangle.center.inset.filled", accessibilityDescription: "")
        } else {
            toggleFullscreenButton.image = NSImage(systemSymbolName: "rectangle.inset.filled", accessibilityDescription: "")
        }
    }
    @IBAction func onSoundButtonClick(_ sender: Any) {
        self.xTimerConfig?.silent.toggle()
        
        guard let xTimerConfig = xTimerConfig else { return }
        
        if xTimerConfig.silent {
            soundButton.image = NSImage(systemSymbolName: "speaker.slash.fill", accessibilityDescription: "")
            soundButton.image
        } else {
            soundButton.image = NSImage(named: NSImage.touchBarAudioOutputVolumeHighTemplateName)
        }
    }
}


extension XTimerViewController {
    var displayCountdownString: String {
        get {
            guard let xTimerConfig = xTimerConfig else { return ""}
            guard countdownLabel != nil else {return ""}
            
            var timerCountInSeconds = xTimerConfig.elapsed
            if xTimerConfig.isCountdown {
                timerCountInSeconds = xTimerConfig.adjustedDuration - xTimerConfig.elapsed
            }
            
            let originCountdownString = getDisplayTimerString(seconds: timerCountInSeconds)
            if timeisUp {
                return xTimerConfig.timeisUpString
            }
            return originCountdownString
        }
    }
    func stopClockTimer() {
        timer?.invalidate()
        timer = nil
    }
    func startClockTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateClock), userInfo: nil, repeats: true)
        timer?.tolerance = 0.1
        RunLoop.current.add(timer!, forMode: .common)
    }
    func getDisplayTimerString(seconds: Int) -> String {
        let totalSeconds = Int(seconds)
        
        let hours = Int(totalSeconds / (60 * 60))
        let minutes = Int((totalSeconds - hours * 60 * 60) / 60)
        let seconds = totalSeconds - hours * 60 * 60 - minutes * 60
        let s = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        return s
    }
    
    func onResize() {
        calculateFontSize()
        updateTrackingArea()
    }
    
    func calculateFontSize() {
        let fontName = "Digital-7 Mono"
        fontSize = calculateMaxFontSize(for: displayCountdownString, fontName: fontName, in: (view.bounds))
        updateTimerDisplay()
    }
    
    func updateTimerDisplay(forgroundColor: NSColor? = nil) {
        guard let xTimerConfig = xTimerConfig else { return }
        guard let countdownLabel = countdownLabel else {return}
        
        var countdownString = displayCountdownString
        var forgroundColor = xTimerConfig.forgroundColor
        var backgroundColor = xTimerConfig.backgroundColor
        
        if timeisUp {
            forgroundColor = NSColor.white
            backgroundColor = NSColor.red
        }
        
        var stringAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedDigitSystemFont(ofSize: fontSize, weight: .regular)
        ]
        
        if xTimerConfig.status != .running {
            stringAttributes[.foregroundColor] = forgroundColor.withAlphaComponent(0.6)
        } else {
            stringAttributes[.foregroundColor] = forgroundColor
        }
        
        let attributedString = NSAttributedString(string: countdownString, attributes: stringAttributes)
        countdownLabel.attributedStringValue = attributedString
        
        backgroundView.layer?.backgroundColor = backgroundColor.cgColor
        
        actionButton.contentTintColor = forgroundColor
        editButton.contentTintColor = forgroundColor
        closeButton.contentTintColor = forgroundColor
        resetButton.contentTintColor = forgroundColor
        toggleFullscreenButton.contentTintColor = forgroundColor
        
        if xTimerConfig.showTitle || xTimerConfig.showDuration {
            var title: [String] = []
            if xTimerConfig.showDuration {
                title.append(totalDurationLabel)
            }
            if xTimerConfig.showTitle {
                title.append(xTimerConfig.subject)
            }
            timerTitle.stringValue = title.joined(separator: "・")
            timerTitle.isHidden = false
            timerTitle.font = .systemFont(ofSize: fontSize * 0.2)
            timerTitle.textColor = forgroundColor.withAlphaComponent(0.5)
        } else {
            timerTitle.isHidden = true
        }
        if xTimerConfig.showExceededTime && timeisUp {
            exceededLabel.font = .systemFont(ofSize: fontSize * 0.2)
            exceededLabel.textColor = forgroundColor.withAlphaComponent(0.8)
            let exceededTime = xTimerConfig.elapsed - xTimerConfig.adjustedDuration
            exceededLabel.stringValue = "Overtime \(getDisplayTimerString(seconds: exceededTime))"
            exceededLabel.isHidden = false
        } else {
            exceededLabel.isHidden = true
        }
    }
    
    @objc func updateClock() {
        guard let xTimerConfig = xTimerConfig else { return }
        if xTimerConfig.isCountdown {
            if timeisUp {
                self.xTimerConfig?.elapsed += 1
            } else {
                self.xTimerConfig?.elapsed += 1
                
                let timerCountInSeconds = (self.xTimerConfig?.adjustedDuration)! - (self.xTimerConfig?.elapsed)!
                
                if timerCountInSeconds <= 0 {
                    timeisUp = true
                    self.xTimerConfig?.period = .expired
                    playTimeUpSound()
                    
                    switch xTimerConfig.timeUpSoundPlaybackMode {
                    case .infinite:
                        if xTimerConfig.timeUpSoundInterruptEnabled {
                            registerGlobalActionInterrupt()
                        }
                    default:
                        print("_")
                    }
                    
                }
            }
        } else {
            self.xTimerConfig?.elapsed += 1
        }
        updateTimerDisplay()
        checkFlashTimer()
    }
    
    func checkFlashTimer() {
        guard let xTimerConfig = xTimerConfig else { return }
        
        if xTimerConfig.isCountdown && !timeisUp  && xTimerConfig.showFlashInTheLast10Seconds {
            let timerCountInSeconds = (self.xTimerConfig?.adjustedDuration)! - (self.xTimerConfig?.elapsed)!
            if timerCountInSeconds <= 10 {
                startFlashTimer()
            } else {
                stopFlashTimer()
            }
        } else {
            stopFlashTimer()
        }
    }
    
    func flashBackground() {
        if flashTimerFlag {
            backgroundView.layer?.backgroundColor = NSColor.red.cgColor
        } else {
            backgroundView.layer?.backgroundColor = xTimerConfig?.backgroundColor.cgColor
        }
        
        flashTimerFlag.toggle()
    }
    
    func registerGlobalActionInterrupt() {
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(startInterruppt), userInfo: nil, repeats: false)
    }
    
    @objc func startInterruppt() {
        guard let xTimerConfig = xTimerConfig else { return }
        
        if xTimerConfig.period == .expired && xTimerConfig.status == .running {
            globalInterruptMonitor.start() {
                self.soundManager.stopPlayback()
                self.globalInterruptMonitor.stop()
            }
        }
    }
}

extension XTimerViewController {
    func startFlashTimer() {
        if flashTimer == nil {
            flashTimer = DispatchSource.makeTimerSource(queue: .main)
            flashTimer?.schedule(deadline: .now(), repeating: 0.5)
            flashTimer?.setEventHandler { [weak self] in
                self?.flashBackground()
            }
            flashTimer?.resume()
        }
    }
    
    func stopFlashTimer() {
        flashTimer?.cancel()
        flashTimer = nil
    }
}

extension XTimerViewController: XTimerSettingDelegate {
    func onChangeStartSoundEnabled(enabled: Bool) {
        xTimerConfig?.startSoundEnabled = enabled
        
        if xTimerConfig?.period == .preparation {
            if enabled {
                soundManager.updateSoundById(soundId: xTimerConfig!.startSoundId, playbackMode: (xTimerConfig?.startSoundPlaybackMode)!)
            } else {
                soundManager.stopPlayback()
            }
        }
    }
    func onChangeRunningSoundEnabled(enabled: Bool) {
        xTimerConfig?.runningSoundEnabled = enabled
        
        if xTimerConfig?.period == .started {
            if enabled {
                soundManager.updateSoundById(soundId: xTimerConfig!.runningSoundId, playbackMode: (xTimerConfig?.runningSoundPlaybackMode)!)
            } else {
                soundManager.stopPlayback()
            }
        }
    }
    func onChangeTimeUpSoundEnabled(enabled: Bool) {
        xTimerConfig?.timeUpSoundEnabled = enabled
        
        if xTimerConfig?.period == .expired {
            if enabled {
                soundManager.updateSoundById(soundId: xTimerConfig!.timeUpSoundId, playbackMode: (xTimerConfig?.timeUpSoundPlaybackMode)!)
            } else {
                soundManager.stopPlayback()
            }
        }
    }
    func timeUpSoundInterruptEnabledChange(enabled: Bool) {
        xTimerConfig?.timeUpSoundInterruptEnabled = enabled
    }
    func startSoundPlaybackModeChange(playbackMode: PlaybackMode) {
        xTimerConfig?.startSoundPlaybackMode = playbackMode
    }
    func runningSoundPlaybackModeChange(playbackMode: PlaybackMode) {
        xTimerConfig?.runningSoundPlaybackMode = playbackMode
    }
    func timeUpSoundPlaybackModeChange(playbackMode: PlaybackMode) {
        xTimerConfig?.timeUpSoundPlaybackMode = playbackMode
    }
    
    func onStartSoundIdSelected(soundId: String) {
        xTimerConfig?.startSoundId = soundId
        
        if xTimerConfig?.status == .started {
            if let enabled = xTimerConfig?.startSoundEnabled {
                soundManager.updateSoundById(soundId: soundId, playbackMode: (xTimerConfig?.startSoundPlaybackMode)!)
            }
        }
    }
    
    func onRunningSoundIDSelected(soundId: String) {
        xTimerConfig?.runningSoundId = soundId
        
        if xTimerConfig?.status == .running {
            if let enabled = xTimerConfig?.runningSoundEnabled {
                soundManager.updateSoundById(soundId: soundId, playbackMode: (xTimerConfig?.runningSoundPlaybackMode)!)
            }
        }
    }
    
    func onTimeUpSoundIdSelected(soundId: String) {
        xTimerConfig?.timeUpSoundId = soundId
        
        if timeisUp {
            if let enabled = xTimerConfig?.timeUpSoundEnabled {
                soundManager.updateSoundById(soundId: soundId, playbackMode: (xTimerConfig?.timeUpSoundPlaybackMode)!)
            }
        }
    }
    
    func subjectChange(subject: String) {
        self.xTimerConfig?.subject = subject
    }
    
    func fullscreenModeControlChange(isFullscreen: Bool) {
        guard let xTimerConfig = xTimerConfig else { return }
        self.xTimerConfig?.isFullscreen.toggle()
        
        if xTimerConfig.isFullscreen {
            xTimerWindowDelegate?.onExitFullscreen()
        } else {
            xTimerWindowDelegate?.onEnterFullscreen()
        }
    }
    
    func backgroundColorChange(color: NSColor) {
        xTimerConfig?.backgroundColor = color
        
    }
    
    func forgroundColorChange(color: NSColor) {
        xTimerConfig?.forgroundColor = color
    }
    
    func themeChange(color: NSColor) {
        xTimerConfig?.selectedTheme = color
    }
    
    func showTitleChange(showTitle: Bool) {
        xTimerConfig?.showTitle = showTitle
    }
    
    func showDurationChange(show: Bool) {
        xTimerConfig?.showDuration = show
    }
    
    func timerModeChange(type: Int) {
        guard let xTimerConfig = xTimerConfig else { return }
        self.xTimerConfig?.isCountdown = type == 0
    }
    
    func durationChange(duration: Int) {
        self.xTimerConfig?.duration = duration
        self.xTimerConfig?.adjustedDuration = duration
    }
    
    func timeisUpTitleChange(title: String) {
        self.xTimerConfig?.timeisUpString = title
    }
    
    func showExceededTimeChange(show: Bool) {
        self.xTimerConfig?.showExceededTime = show
    }
    
    func showFlashChange(show: Bool) {
        self.xTimerConfig?.showFlashInTheLast10Seconds = show
        checkFlashTimer()
    }
    
    func changeDuration(delta: Int) {
        
        self.xTimerConfig?.adjustedDuration += delta
        if (self.xTimerConfig?.adjustedDuration)! < 0 {
            self.xTimerConfig?.adjustedDuration = 0
        }
        updateTimerDisplay()
    }
}
