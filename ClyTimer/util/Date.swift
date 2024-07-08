import Foundation

func daysBetweenDates(_ startDate: Date, _ endDate: Date) -> Int {
    let calendar = Calendar.current

    // Use the start and end dates to calculate the difference in days
    let components = calendar.dateComponents([.day], from: startDate, to: endDate)

    // Access the day component from the result
    if let days = components.day {
        return days  // Use abs to ensure a positive value
    } else {
        return 0
    }
}

func stringToSeconds(_ duration: String) -> Int {
    // Define time units in seconds
    let timeUnits: [String: Int] = [
        "s": 1,          // second
        "m": 60,         // minute
        "h": 3600,       // hour
        "d": 86400,      // day
        "y": 31536000    // year (assuming 365 days)
    ]
    
    // Regular expression to match time units
    let regex = try! NSRegularExpression(pattern: "(\\d+)([smhdy])")
    let nsString = duration as NSString
    let matches = regex.matches(in: duration, range: NSRange(location: 0, length: nsString.length))
    
    var totalSeconds = 0
    
    // Parse each match and calculate the total seconds
    for match in matches {
        let valueRange = match.range(at: 1)
        let unitRange = match.range(at: 2)
        
        let valueString = nsString.substring(with: valueRange)
        let unitString = nsString.substring(with: unitRange)
        
        if let value = Int(valueString), let unit = timeUnits[unitString] {
            totalSeconds += value * unit
        }
    }
    
    return totalSeconds
}
