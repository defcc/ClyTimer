import Foundation
import AppKit

func calculateMaxFontSize(for displayString: String, fontName: String,  in bounds: NSRect) -> CGFloat {
    let testLabel = NSTextField()
    testLabel.isEditable = false
    testLabel.isSelectable = false
    testLabel.isBezeled = false
    testLabel.isBordered = false
    testLabel.drawsBackground = false
    
    var maxFontSize: CGFloat = 1.0
    let minFontSize: CGFloat = 1.0
    let maxBoundsWidth = bounds.size.width - 40
    let maxBoundsHeight = bounds.size.height
    
    while maxFontSize < 1000 {
        let stringAttributes: [NSAttributedString.Key: Any] = [
//            .font: getFont(maxFontSize, fontName, weight: .regular)
            .font: NSFont.monospacedDigitSystemFont(ofSize: maxFontSize, weight: .regular)
        ]
        
        let attributedString = NSAttributedString(string: displayString, attributes: stringAttributes)
        testLabel.attributedStringValue = attributedString
        testLabel.sizeToFit()

        if testLabel.frame.size.width > maxBoundsWidth || testLabel.frame.size.height > maxBoundsHeight {
            break
        }
        maxFontSize += 1
    }
    
    return maxFontSize - 1
}
