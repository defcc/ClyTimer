import CoreData
import LaunchAtLogin
import CoreGraphics
import AppKit


func parseStringToJSON(jsonString: String) -> [String: Any] {
    let data: Data? = jsonString.data(using: .utf8)
    let json = (try? JSONSerialization.jsonObject(with: data!, options: [])) as? [String:AnyObject]
    return json ?? [:]
}

func jsonEncode(directionary: [String: Any]) -> String {
    let jsonData = try! JSONSerialization.data(withJSONObject: directionary, options: JSONSerialization.WritingOptions.prettyPrinted)
    let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
    return jsonString
}

struct TimerConfigItem {
    let id: UUID
    let name: String
    var duration: Int
    var startSoundId: String
    var runningSoundId: String
    var timeUpSoundId: String
}

class DataModel {
    private let persistentContainer: NSPersistentContainer
    
    var hasShowWelcome: Bool = false
    var helpUrl: String = "https://beauty-of-pixel.tech/clytimer-fullscreen-countdown?fr=app"
    var email: String = "defcc@icloud.com"
    var featureUrl: String = ""
    var launchAtLogin: Bool = false
    var initTime: Date?
    var isLTD: Bool = false
    var isVip: Bool = false
    var isInTrial: Bool = false
    var vipStartAt: Date?
    var vipExpiredAt: Date?
    var trialStart: Date?
    var trialEnd: Date?
    var notchApp: Bool = false
    
    var timerList: [XTimerConfig] = []
    
    var defaultTimerConfig: TimerConfigItem?
    
    static var shared = DataModel()
        
    init() {
        persistentContainer = NSPersistentContainer(name: "XTimer")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                print("Failed to load persistent stores: \(error)")
            }
        }
        setup()
        checkSetting()
        loadTemplateData()
    }
    
    func cleanUp() {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest = Setting.fetchRequest()
        do {
            let result = try context.fetch(fetchRequest)
            if result.count > 0 {
                result.forEach {
                    context.delete($0)
                }
            }
            save()
        }catch {
            print(error)
        }
        
        let templateFetchRequest: NSFetchRequest = TimerTemplate.fetchRequest()
        do {
            let result = try context.fetch(fetchRequest)
            if result.count > 0 {
                result.forEach {
                    context.delete($0)
                }
            }
            save()
        }catch {
            print(error)
        }
    }
    
    func setup() {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest = Setting.fetchRequest()
        do {
            let result = try context.fetch(fetchRequest)
            if result.count > 0 {
                hasShowWelcome = true
                return
            }
            try context.save()
            let settingData = Setting(context: context)
            settingData.launchAtLogin = false
            settingData.notchApp = false
            settingData.initTime = Date.init()
            settingData.isLTD = false
            settingData.isVip = false
            let startAt = Date()
            let endAt = Calendar.current.date(byAdding: .day, value: 3, to: startAt)
            settingData.trialStartAt = startAt
            settingData.trialEndAt = endAt
            save()
            
            initDefaultTimerConfig()
        }catch {
            print(error)
        }
    }
    
    func initDefaultTimerConfig() {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest = TimerTemplate.fetchRequest()
        do {
            let result = try context.fetch(fetchRequest)
            if result.count > 0 {
                return
            }
            let templateData = TimerTemplate(context: context)
            templateData.id = UUID()
            templateData.name = "default"
            templateData.duration = 10 * 60
            templateData.startSoundId = "Bell"
            templateData.runningSoundId = "Clock Tick"
            templateData.timeUpSoundId = "Digital"
            save()
        }catch {
            print(error)
        }
    }
    
    func isVipUser() -> Bool {
        checkSetting()
        return isVip || isLTD
    }
    
    func getUserStatus() -> (
        isVip: Bool, 
        isLTD: Bool,
        isInTrial: Bool,
        vipStartAt: Date?,
        vipEndedAt: Date?,
        trialStartAt: Date,
        trialEndAt: Date
    ) {
        checkSetting()
        return (
            isVip: isVip,
            isLTD: isLTD,
            isInTrial: isInTrial,
            vipStartAt: vipStartAt,
            vipEndedAt: vipExpiredAt,
            trialStartAt: trialStart!,
            trialEndAt: trialEnd!
        )
    }
    
    func isNeedToProVersion() -> Bool {
        checkSetting()
        return isInTrial || !isVip
    }
    
    func checkSetting() {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest = Setting.fetchRequest()
        do {
            let result = try context.fetch(fetchRequest)
            result.forEach {
                launchAtLogin = $0.launchAtLogin
                isLTD = $0.isLTD
                isVip = $0.isVip
                trialStart = $0.trialStartAt
                trialEnd = $0.trialEndAt
                vipStartAt = $0.vipStartAt
                vipExpiredAt = $0.vipExpireAt
                notchApp = $0.notchApp
                initTime = $0.initTime
                
                if !isLTD && !isVip {
                    if let trialStart = trialStart, let trialEnd = trialEnd {
                        let currentDate = Date()
                        if currentDate >= trialStart && currentDate <= trialEnd {
                            isInTrial = true
                            isVip = true
                        }
                    }
                } else {
                    isInTrial = false
                }
            }
        }catch {
            print(error)
        }
        
        print("isVIP \(isVip)")
        print("isLTD \(isLTD)")
        print("isInTrial \(isInTrial)")
    }
    
    func loadTemplateData() {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest = TimerTemplate.fetchRequest()
        do {
            let result = try context.fetch(fetchRequest)
            result.forEach {
                let timerConfigItem = TimerConfigItem(
                    id: $0.id!,
                    name: $0.name!,
                    duration: Int($0.duration),
                    startSoundId: $0.startSoundId!,
                    runningSoundId: $0.runningSoundId!,
                    timeUpSoundId: $0.timeUpSoundId!
                )
                
                defaultTimerConfig = timerConfigItem
            }
        }catch {
            print(error)
        }
        
        print("isVIP \(isVip)")
        print("isLTD \(isLTD)")
        print("isInTrial \(isInTrial)")
    }
    
    func save() {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
    
    func getSetting() -> Setting? {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest = Setting.fetchRequest()
        do {
            let result = try context.fetch(fetchRequest)
            for settingItem in result {
                return settingItem
            }
        }catch {
            print(error)
        }
        return nil
    }
    
    func updateLaunchAtLogin(_ enabled: Bool) {
        LaunchAtLogin.isEnabled = enabled
        DataModel.shared.launchAtLogin = enabled
        updateSetting(key: "launchAtLogin", value: enabled)
    }
    
    func updateDefaultTimerTemplate(updateBatch: [String: Any]) {
        for (key, value) in updateBatch {
            switch key {
            case "duration":
                defaultTimerConfig?.duration = value as! Int
            case "startSoundId":
                defaultTimerConfig?.startSoundId = value as! String
            case "runningSoundId":
                defaultTimerConfig?.runningSoundId = value as! String
            case "timeUpSoundId":
                defaultTimerConfig?.timeUpSoundId = value as! String
            default:
                print("")
            }
        }
        
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest = TimerTemplate.fetchRequest()
        do {
            let result = try context.fetch(fetchRequest)
            result.forEach {
                for (key, value) in updateBatch {
                    $0.setValue(value, forKey: key)
                }
            }
            save()
        }catch {
            print(error)
        }
    }
    
    func updateNotchEntry(_ enabled: Bool) {
        DataModel.shared.notchApp = enabled
        updateSetting(key: "notchApp", value: enabled)
    }
    
    func updateSetting(key: String, value: Any) {
        let context = persistentContainer.viewContext
        guard let settingInfo = getSetting() else {
            return
        }
        settingInfo.setValue(value, forKey: key)
        save()
    }
    
    func updateSettingBatch(updateDictionary: [String: Any]) {
        let context = persistentContainer.viewContext
        guard let settingInfo = getSetting() else {
            return
        }
        for (key, value) in updateDictionary {
            settingInfo.setValue(value, forKey: key)
        }
        save()
    }
}
