//
//  CollectData.swift
//  FloatBrowser
//
//  Created by 程超 on 2024/7/18.
//

import Foundation
import Supabase

func generateUUID() -> String {
    return UUID().uuidString
}

func getCurrentUUID() -> String {
    let userDefaults = UserDefaults.standard
    if let uuid = SharedUserDefaultManager.shared.sharedUUID {
        return uuid
    } else {
        let uuid = generateUUID()
        SharedUserDefaultManager.shared.sharedUUID = uuid
        return uuid
    }
}

class SharedUserDefaultManager {
    static let shared = SharedUserDefaultManager()
    
    var sharedUserDefault: UserDefaults
    
    init() {
        sharedUserDefault = UserDefaults(suiteName: "LCR49HJMTK.com.sanci.clyapp")!
    }
    
    var sharedUUID: String? {
        get {
            return sharedUserDefault.string(forKey: "clyAppUUID")
        }
        set {
            sharedUserDefault.setValue(newValue, forKey: "clyAppUUID")
        }
    }
}

class CollectData {
    static var shared = CollectData()
    
    var client: SupabaseClient
    var bundleId = Bundle.main.bundleIdentifier
    var uuid = getCurrentUUID()
    var userAdded = UserDefaults.standard.string(forKey: "clyAppUserAdded")
    
    init() {
        client = SupabaseClient(supabaseURL: URL(string: ConfigConstant.supabaseUrl)!, supabaseKey: ConfigConstant.supabaseKey)
    }
    
    func initUser() {
        Task {
            await self.addUser()
        }
    }
    
    func addUser() async {
        if let userAdded = userAdded, userAdded == "1" {
            return
        }
        struct User: Encodable {
            let uuid: String
            let appBundleId: String
            let inited_at: Date
        }
        
        let user = User(
            uuid: uuid,
            appBundleId: bundleId!,
            inited_at: DataModel.shared.initTime!
        )
        
        #if DEBUG
            return
        #endif
        
        do {
            try await client.from("Users").insert(user).execute()
            
            if DataModel.shared.isLTD {
                self.upgradePro(proTime: DataModel.shared.vipStartAt!)
            }
            
            UserDefaults.standard.setValue("1", forKey: "clyAppUserAdded")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func upgradePro(proTime: Date = Date()) {
        #if DEBUG
                return
        #endif
        Task {
            struct ProLog: Encodable {
                let uuid: String
                let appBundleId: String
                let pro_at: Date
            }
            
            let proLog = ProLog(
                uuid: uuid,
                appBundleId: bundleId!,
                pro_at: proTime
            )
            
            do {
                try await client.from("ProLog").insert(proLog).execute()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func clickLog(for logItem: ClickLog.Types) async {
        #if DEBUG
            return
        #endif
        struct ClickLog: Encodable {
            let user_id: String
            let log_id: String
            let log_name: String
            let appBundleId: String
        }
        
        let clickLog = ClickLog(user_id: uuid, log_id: logItem.data.clickId, log_name: logItem.data.clickName, appBundleId: bundleId!)
        
        do {
            try await client.from("ClickLog").insert(clickLog).execute()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func sendLog(for logItem: ClickLog.Types) {
        Task {
            await self.clickLog(for: logItem)
        }
    }
}
