//
//  ImageCache.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 12/05/2024.
//

import Foundation

/// A singleton class for caching images
class ImageCache {
    /// Typealias for NSCache with key as NSString and value as NSData
    typealias CacheType = NSCache<NSString, NSData>

    /// Shared instance of ImageCache
    static let shared = ImageCache()

    private init() { }

    /// Lazy initialization of NSCache with count and cost limits
    private lazy var cache: CacheType = {
        let cache = CacheType()
        cache.countLimit = 100
        cache.totalCostLimit = 100 * 1024 * 1024 // roughly a bit more than 100 mb
        return cache
    }()

    /// Retrieves the cached object for a given key.
    ///
    /// - Parameter key: The key for the cached object.
    /// - Returns: The cached data for the given key, if available.
    func object(forKey key: NSString) -> Data? {
        cache.object(forKey: key) as? Data
    }

    /// Sets the object in the cache for a given key.
    ///
    /// - Parameters:
    ///   - object: The object to be cached.
    ///   - key: The key for the cached object.
    func set(object: NSData, forKey key: NSString) {
        cache.setObject(object, forKey: key)
    }
}
