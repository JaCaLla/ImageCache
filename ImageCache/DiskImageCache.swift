//
//  DiskImageCache.swift
//  ImageCache
//
//  Created by JAVIER CALATRAVA LLAVERIA on 21/4/25.
//

import UIKit

actor DiskImageCache {
    static let shared = DiskImageCache()
    
    private let memoryCache = NSCache<NSURL, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let expiration: TimeInterval = 12 * 60 * 60 // 12 hours
    
    init() {
        let directory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = directory.appendingPathComponent("ImageCache", isDirectory: true)

        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }
    
    func image(for url: URL) -> UIImage? {
        // 1. Check memory cache
        if let memoryImage = memoryCache.object(forKey: url as NSURL) {
            return memoryImage
        }
        
        // 2. Check disk cache
        let path = cachePath(for: url)
        guard fileManager.fileExists(atPath: path.path) else { return nil }

        // Check expiration
        if let attributes = try? fileManager.attributesOfItem(atPath: path.path),
           let modifiedDate = attributes[.modificationDate] as? Date {
            if Date().timeIntervalSince(modifiedDate) > expiration {
                try? fileManager.removeItem(at: path)
                return nil
            }
        }
        
        // Load from disk
        guard let data = try? Data(contentsOf: path),
              let image = UIImage(data: data) else {
            return nil
        }

        memoryCache.setObject(image, forKey: url as NSURL)
        return image
    }
    
    func store(_ image: UIImage, for url: URL) async {
        memoryCache.setObject(image, forKey: url as NSURL)
        
        let path = cachePath(for: url)
        if let data = image.pngData() {
            try? data.write(to: path)
        }
    }

    private func cachePath(for url: URL) -> URL {
        let fileName = url.absoluteString.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? UUID().uuidString
        return cacheDirectory.appendingPathComponent(fileName)
    }
}

