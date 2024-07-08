//
//  ProLoadingView.swift
//  XTimer
//
//  Created by 程超 on 2024/3/28.
//

import Foundation
import AppKit

class ProLoadingView: NSView {
    var count = 0
    var countdownTimer: Timer?
    var onEnd: ()-> Void = {}
    
    lazy var textView: NSTextView = {
        let textView = NSTextView(frame: bounds)
        textView.isEditable = false
        textView.isSelectable = false
        textView.string = ""
        textView.alignment = .center
        textView.font = .systemFont(ofSize: 24)
        textView.drawsBackground = false
        textView.isHidden = true
        addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.centerXAnchor.constraint(equalTo: centerXAnchor),
            textView.centerYAnchor.constraint(equalTo: centerYAnchor),
            textView.widthAnchor.constraint(equalToConstant: 100),
            textView.heightAnchor.constraint(equalToConstant: 40)
        ])
        return textView
    }()
    
    lazy var buyButton: NSButton = {
        let button = NSButton()
        button.title = NSLocalizedString("Upgrade to Pro", comment: "")
        button.action = #selector(showPaywall)
        button.target = self
        addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -60),
            button.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        return button
    }()
    
    lazy var logoImage: NSImageView = {
        let logo = NSImage(named: "icon")
        let logoImageView = NSImageView(image: logo!)
        
        addSubview(logoImageView)
        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalToConstant: 80),
            logoImageView.heightAnchor.constraint(equalToConstant: 68),
            logoImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 80)
        ])
        
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        return logoImageView
    }()
    
    lazy var logoText: NSTextView = {
        let textView = NSTextView(frame: bounds)
        textView.isEditable = false
        textView.isSelectable = false
        textView.string = "ClyTimer Free Version"
        textView.alignment = .center
        textView.font = .systemFont(ofSize: 16)
        textView.drawsBackground = false
        textView.isHidden = true
        addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: logoImage.bottomAnchor, constant: 10),
            textView.centerXAnchor.constraint(equalTo: centerXAnchor),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            textView.heightAnchor.constraint(equalToConstant: 40)
        ])
        return textView
    }()
    
    lazy var autoStartText: NSTextView = {
        let autoStartText = NSTextView(frame: bounds)
        autoStartText.isEditable = false
        autoStartText.isSelectable = false
        autoStartText.string = "The timer will auto-start in"
        autoStartText.alignment = .center
        autoStartText.font = .systemFont(ofSize: 16)
        autoStartText.textColor = .lightGray
        autoStartText.drawsBackground = false
        autoStartText.isHidden = true
        addSubview(autoStartText)
        
        autoStartText.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            autoStartText.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 10),
            autoStartText.centerXAnchor.constraint(equalTo: centerXAnchor),
            autoStartText.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            autoStartText.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            autoStartText.heightAnchor.constraint(equalToConstant: 40)
        ])
        return autoStartText
    }()
    
    lazy var freeIntroText: NSTextView = {
        let autoStartText = NSTextView(frame: bounds)
        autoStartText.isEditable = false
        autoStartText.isSelectable = false
        autoStartText.string = "There will be 10 seconds delay for non-pro user to active the timer"
        autoStartText.alignment = .center
        autoStartText.font = .systemFont(ofSize: 12)
        autoStartText.textColor = .lightGray
        autoStartText.drawsBackground = false
        autoStartText.isHidden = true
        addSubview(autoStartText)
        
        autoStartText.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            autoStartText.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            autoStartText.centerXAnchor.constraint(equalTo: centerXAnchor),
            autoStartText.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            autoStartText.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            autoStartText.heightAnchor.constraint(equalToConstant: 40)
        ])
        return autoStartText
    }()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        addSubview(textView)
        addSubview(buyButton)
        logoImage.isHidden = false
        logoText.isHidden = false
        autoStartText.isHidden = false
        freeIntroText.isHidden = false
        isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCountView() {
        if self.count >= 0 {
            isHidden = false
            textView.string = "\(self.count)"
            textView.isHidden = false
        }
    }
    
    func invalidTimer() {
        countdownTimer?.invalidate()
        isHidden = true
    }
    
    func start(count: Int, onEnd: @escaping () -> Void) {
        self.count = count
        self.onEnd = onEnd
        countdownTimer?.invalidate()
        startTimer()
    }
    
    func startTimer() {
        self.updateCountView()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {[weak self] _ in
            self!.count = self!.count - 1
            self!.updateCountView()
            if self!.count < 0 {
                self!.countdownTimer?.invalidate()
                self!.onEnd()
            }
        }
    }
    
    @objc func showPaywall() {
        NotificationCenter.default.post(
            name: .showPaywall,
            object: nil,
            userInfo: nil
        )
    }
}
