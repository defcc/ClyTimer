//
//  RateRequestManager.swift
//  FloatBrowser
//
//  Created by 程超 on 2024/7/19.
//

import Foundation
import Defaults
import StoreKit

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    var releaseVersionNumberPretty: String {
        return "v\(releaseVersionNumber ?? "1.0.0")"
    }
}

extension Defaults.Keys {
    static let ratingEventsCount = Key<Int>("ratingEventsCount", default: 0)
    static let sessionCount = Key<Int>("sessionCount", default: 0)
    static let lastVersionPromptedForRate = Key<String>("lastVersionPromptedForRate", default: "")
}

class RateRequestManager {
    static let shared = RateRequestManager()
    
    let eventsCountUntilPrompt = 35
    let sessionCountUntilPrompt = 7
    let daysUntilPrompt = 7
    
    var shouldAskForRating: Bool {
        guard let initTime = DataModel.shared.initTime else { return false }
        let timeSinceFirstLaunch = Date().timeIntervalSince(initTime)
        let timeUntilRate: TimeInterval = 60 * 60  * 24 * TimeInterval(daysUntilPrompt)
        
        return Defaults[.ratingEventsCount] >= eventsCountUntilPrompt
//            && Defaults[.sessionCount] >= sessionCountUntilPrompt
            && timeSinceFirstLaunch >= timeUntilRate
            && Defaults[.lastVersionPromptedForRate] != Bundle.main.releaseVersionNumberPretty
    }
    
    func recordRatingEvent() {
        Defaults[.ratingEventsCount] += 1
    }
    
    func recordSession() {
        Defaults[.sessionCount] += 1
    }
    
    func requestRate() {
        let requestWorkItem = DispatchWorkItem {
            CollectData.shared.sendLog(for: .promptRate)
            SKStoreReviewController.requestReview()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: requestWorkItem)
    }
    
    func askForRatingIfNeeded() {
        guard shouldAskForRating else {
            return
        }
        
        Defaults[.lastVersionPromptedForRate] = Bundle.main.releaseVersionNumberPretty
        requestRate()
    }
}
