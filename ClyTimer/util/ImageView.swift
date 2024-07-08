import Cocoa
import AppKit

public class NetworkImageView: NSImageView {
    private static let cacheDirectory: URL = {
        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return cachesDirectory.appendingPathComponent("NetworkImageViewCache")
    }()

    private var imageCache: NSCache<NSURL, NSImage> = NSCache()

    public var imageURL: URL?

    public var imageContentMode: NSImageScaling = .scaleProportionallyUpOrDown {
        didSet {
            self.needsDisplay = true
        }
    }

    public func loadImage(from url: URL, completion: @escaping (NSImage?) -> Void) {
        imageURL = url

        // Check if the image is already in memory cache
        if let cachedImage = imageCache.object(forKey: url as NSURL) {
            completion(cachedImage)
            return
        }

        // Check if the image is in disk cache
        if let cachedImage = loadFromDiskCache(for: url) {
            // Cache the image in memory
            imageCache.setObject(cachedImage, forKey: url as NSURL)
            completion(cachedImage)
            return
        }

        // Load the image from either local file or remote URL
        if url.isFileURL {
            loadLocalImage(url: url, completion: completion)
        } else {
            loadRemoteImage(url: url, completion: completion)
        }
    }

    private func loadLocalImage(url: URL, completion: @escaping (NSImage?) -> Void) {
        do {
            let data = try Data(contentsOf: url)
            if let image = NSImage(data: data) {
                // Cache the image in memory
                self.imageCache.setObject(image, forKey: url as NSURL)

                // Cache the image on disk
                self.saveToDiskCache(data: data, for: url)

                completion(image)
            } else {
                completion(nil)
            }
        } catch {
            print("Failed to load local image: \(error)")
            completion(nil)
        }
    }

    private func loadRemoteImage(url: URL, completion: @escaping (NSImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let imageData = data, let downloadedImage = NSImage(data: imageData) {
                // Cache the image in memory
                self.imageCache.setObject(downloadedImage, forKey: url as NSURL)

                // Cache the image on disk
                self.saveToDiskCache(data: imageData, for: url)

                completion(downloadedImage)
            } else {
                completion(nil)
            }
        }.resume()
    }

    private func saveToDiskCache(data: Data, for url: URL) {
        let cacheFileURL = NetworkImageView.cacheDirectory.appendingPathComponent(url.lastPathComponent)

        // Ensure the directory exists
        do {
            let directory = NetworkImageView.cacheDirectory
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Failed to create cache directory: \(error)")
            return
        }

        // Save the image to disk
        do {
            try data.write(to: cacheFileURL)
        } catch {
            print("Failed to save image to disk cache: \(error)")
        }
    }

    private func loadFromDiskCache(for url: URL) -> NSImage? {
        let cacheFileURL = NetworkImageView.cacheDirectory.appendingPathComponent(url.lastPathComponent)

        if let data = try? Data(contentsOf: cacheFileURL), let image = NSImage(data: data) {
            return image
        }

        return nil
    }

    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        if let image = image {
            // Set the image scaling based on the content mode
            self.imageScaling = imageContentMode

            // Draw the image in the view
            image.draw(in: bounds)
        }
    }
}

