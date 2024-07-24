//
//  ClickLog.swift
//  FloatBrowser
//
//  Created by 程超 on 2024/7/19.
//

import Foundation

struct ClickLogItem {
    let clickId: String
    let clickName: String
}


struct ClickLog {
    struct Types {
        let data: ClickLogItem
    }
}

extension ClickLog.Types {
    static let clickNewTimerInMenubar = ClickLog.Types(data: .init(clickId: "menubar-click-new", clickName: "[menubar] click to create new timer"))
    static let rateClickOnMenubar = ClickLog.Types(data: .init(clickId: "menubar-click-rate", clickName: "[menubar] click to rate"))
    
    static let promptRate = ClickLog.Types(data: .init(clickId: "rate-prompt", clickName: "[rate] show rate prompt by activity"))
    
    static let showPaywall = ClickLog.Types(data: ClickLogItem(clickId: "show-paywall", clickName: "[paywall] show"))
    static let tryToBuy = ClickLog.Types(data: ClickLogItem(clickId: "try-buy", clickName: "[paywall] try to buy"))
    static let upgradeProSuccess = ClickLog.Types(data: .init(clickId: "upgrade-success", clickName: "[paywall] buy success"))
    static let upgradeProFailed = ClickLog.Types(data: .init(clickId: "upgrade-fail", clickName: "[paywall] buy failed"))
    
    static let onboardingWindowFirstShow = ClickLog.Types(data: .init(clickId: "onboarding-init", clickName: "[onboarding] init"))
    static let onboardingWindowShow = ClickLog.Types(data: .init(clickId: "onboarding-show", clickName: "[onboarding] show"))
    
    static let appStartup = ClickLog.Types(data: .init(clickId: "app-start", clickName: "[app] start"))
    static let appQuit = ClickLog.Types(data: .init(clickId: "app-quit", clickName: "[app] quit"))
    
    static let createTimer = ClickLog.Types(data: .init(clickId: "timer-create", clickName: "[timer] create new"))
    static let createStopwatch = ClickLog.Types(data: .init(clickId: "timer-create-stopwatch", clickName: "[timer] create new stopwatch"))
}
