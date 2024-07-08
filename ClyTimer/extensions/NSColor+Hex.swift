import AppKit
extension NSColor {
    
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    convenience init?(genericRGB hex: String) {
            var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

            var rgb: UInt64 = 0

            Scanner(string: hexSanitized).scanHexInt64(&rgb)

            let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            let blue = CGFloat(rgb & 0x0000FF) / 255.0

            self.init(colorSpace: NSColorSpace.genericRGB, components: [red, green, blue, 1.0], count: 4)
        }
    
    convenience init?(rgbaString: String) {
        let components = rgbaString
                .replacingOccurrences(of: "rgba(", with: "")
                .replacingOccurrences(of: ")", with: "")
                .split(separator: ",")
                .compactMap { component -> CGFloat? in
                    guard let floatValue = Float(component.trimmingCharacters(in: .whitespacesAndNewlines)) else {
                        return nil
                    }
                    return CGFloat(floatValue)
                }
        guard components.count == 4 else {
            return nil // Invalid format
        }

        let red = components[0] / 255.0
        let green = components[1] / 255.0
        let blue = components[2] / 255.0
        let alpha = components[3]

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func toHex(alpha: Bool = false) -> String? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)
        
        if components.count >= 4 {
            a = Float(components[3])
        }
        
        if alpha {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
    
    func getRGBAString() -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        if let rgbColor = self.usingColorSpace(.sRGB) {
            // Use RGB components if conversion is successful
            rgbColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        } else {
            // Use grayscale components if conversion fails
            self.getWhite(&red, alpha: &alpha)
            green = red
            blue = red
        }

        let redInt = Int(red * 255)
        let greenInt = Int(green * 255)
        let blueInt = Int(blue * 255)

        return "rgba(\(redInt),\(greenInt),\(blueInt),\(alpha))"
    }
    
    static func fromHexString(_ hexString: String) -> NSColor? {
            var formattedHexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
            formattedHexString = formattedHexString.replacingOccurrences(of: "#", with: "")

            var rgbValue: UInt64 = 0
            Scanner(string: formattedHexString).scanHexInt64(&rgbValue)

            let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            let blue = CGFloat(rgbValue & 0x0000FF) / 255.0

            return NSColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    static func rgbComponents(fromHexString hexString: String) -> NSColor? {
        var formattedHexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        formattedHexString = formattedHexString.replacingOccurrences(of: "#", with: "")

        guard let hexValue = UInt64(formattedHexString, radix: 16) else {
            return nil
        }

        let red = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hexValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(hexValue & 0x0000FF) / 255.0

        return NSColor(
            calibratedRed: red,
            green: green,
            blue: blue,
            alpha: 1.0
        )
    }
    
    func contrastingColor() -> NSColor {
        guard let rgbColor = self.usingColorSpace(.deviceRGB) else {
            return .black // Fallback color if conversion fails
        }
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        rgbColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Calculate the brightness of the color
        let brightness = (red * 299 + green * 587 + blue * 114) / 1000
        
        // Determine whether to lighten or darken the color for contrast
        let adjustmentFactor: CGFloat
        if brightness > 0.5 {
            adjustmentFactor = 0.3 // Make the color darker for light backgrounds
        } else {
            adjustmentFactor = 1.7 // Make the color lighter for dark backgrounds
        }
        
        // Calculate the new color components
        let newRed = brightness > 0.5 ? max(red * adjustmentFactor, 0) : min(red * adjustmentFactor, 1)
        let newGreen = brightness > 0.5 ? max(green * adjustmentFactor, 0) : min(green * adjustmentFactor, 1)
        let newBlue = brightness > 0.5 ? max(blue * adjustmentFactor, 0) : min(blue * adjustmentFactor, 1)
        
        return NSColor(red: newRed, green: newGreen, blue: newBlue, alpha: alpha)
    }
}
