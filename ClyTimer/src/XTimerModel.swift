import Foundation

class XTimerModel {
    typealias timerCallback = (XTimerModel) -> Void
    
    private var callbacks: [timerCallback] = []
    var xTimerConfig: XTimerConfig
    var timer: Timer?
    
    init(xTimerConfig: XTimerConfig) {
        self.xTimerConfig = xTimerConfig
    }
    
    func start() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        timer?.tolerance = 0.1
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    func registerCallback(_ callback: @escaping timerCallback) {
        callbacks.append(callback)
    }
}


extension XTimerModel {
    @objc func updateTimer() {
        if xTimerConfig.isCountdown {
            if xTimerConfig.runtimeTimeIsUp {
                xTimerConfig.runtimeTimerCountInSeconds += 1
            } else {
                xTimerConfig.runtimeTimerCountInSeconds -= 1
                
                if xTimerConfig.runtimeTimerCountInSeconds <= 0 {
                    xTimerConfig.runtimeTimeIsUp = true
                }
            }
        } else {
            xTimerConfig.runtimeTimerCountInSeconds += 1
        }
        
        notifyUpdate()        
    }
    
    func notifyUpdate() {
        for callback in self.callbacks {
            callback(self)
        }
    }
}
