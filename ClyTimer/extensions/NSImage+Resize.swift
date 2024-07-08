import AppKit
extension NSImage {
    func resizeAspectFill(toFill size: NSSize) -> NSImage {
        let newSize: NSSize
        let aspectRatio = self.size.width / self.size.height

        if size.width / aspectRatio >= size.height {
            newSize = NSSize(width: size.width, height: size.width / aspectRatio)
        } else {
            newSize = NSSize(width: size.height * aspectRatio, height: size.height)
        }

        let newImage = NSImage(size: size)
        newImage.lockFocus()

        let rect = NSRect(x: (size.width - newSize.width) / 2.0,
                          y: (size.height - newSize.height) / 2.0,
                          width: newSize.width,
                          height: newSize.height)

        self.draw(in: rect,
                  from: NSRect(origin: NSPoint.zero, size: self.size),
                  operation: .sourceOver,
                  fraction: 1.0)

        newImage.unlockFocus()
        return newImage
    }
}


extension NSImage {
    func resizeAspectFit(toFit size: NSSize) -> NSImage {
        let newSize: NSSize
        let aspectRatio = self.size.width / self.size.height

        if size.width / aspectRatio <= size.height {
            newSize = NSSize(width: size.width, height: size.width / aspectRatio)
        } else {
            newSize = NSSize(width: size.height * aspectRatio, height: size.height)
        }

        let newImage = NSImage(size: size)
        newImage.lockFocus()

        let rect = NSRect(x: (size.width - newSize.width) / 2.0,
                          y: (size.height - newSize.height) / 2.0,
                          width: newSize.width,
                          height: newSize.height)

        self.draw(in: rect,
                  from: NSRect(origin: NSPoint.zero, size: self.size),
                  operation: .sourceOver,
                  fraction: 1.0)
        
        newImage.unlockFocus()
        return newImage
    }
}
