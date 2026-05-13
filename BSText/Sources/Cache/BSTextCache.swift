//
//  BSTextCache.swift
//  BSText
//
//  Unified cache system for fragments, images, and decoded data.
//

import UIKit

/// A unified cache for text fragments, images, and decoded data.
@objcMembers
open class BSTextCache {

    /// Shared default cache instance.
    public static let shared = BSTextCache()

    /// Maximum number of fragments to keep in memory.
    public var maxFragmentCount: Int = 100 {
        didSet {
            fragmentCache.countLimit = maxFragmentCount
        }
    }

    /// Maximum memory cost for image cache in bytes.
    public var maxImageCacheCost: Int = 100 * 1024 * 1024 { // 100MB
        didSet {
            imageCache.totalCostLimit = maxImageCacheCost
        }
    }

    /// The underlying fragment cache.
    private let fragmentCache: NSCache<NSString, BSTextFragment> = {
        let cache = NSCache<NSString, BSTextFragment>()
        cache.countLimit = 100
        return cache
    }()

    /// The underlying image cache.
    private let imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.totalCostLimit = 100 * 1024 * 1024 // 100MB
        return cache
    }()

    private init() {}

    // MARK: - Fragment Cache

    /// Caches a text fragment.
    ///
    /// - Parameters:
    ///   - fragment: The fragment to cache.
    ///   - key: The cache key.
    public func cacheFragment(_ fragment: BSTextFragment, forKey key: String) {
        fragmentCache.setObject(fragment, forKey: key as NSString)
    }

    /// Retrieves a cached fragment.
    ///
    /// - Parameter key: The cache key.
    /// - Returns: The cached fragment, or nil if not found.
    public func fragment(forKey key: String) -> BSTextFragment? {
        return fragmentCache.object(forKey: key as NSString)
    }

    /// Removes a cached fragment.
    ///
    /// - Parameter key: The cache key.
    public func removeFragment(forKey key: String) {
        fragmentCache.removeObject(forKey: key as NSString)
    }

    // MARK: - Image Cache

    /// Caches a decoded image.
    ///
    /// - Parameters:
    ///   - image: The decoded image.
    ///   - key: The cache key.
    ///   - cost: The memory cost in bytes.
    public func cacheImage(_ image: UIImage, forKey key: String, cost: Int) {
        imageCache.setObject(image, forKey: key as NSString, cost: cost)
    }

    /// Retrieves a cached image.
    ///
    /// - Parameter key: The cache key.
    /// - Returns: The cached image, or nil if not found.
    public func image(forKey key: String) -> UIImage? {
        return imageCache.object(forKey: key as NSString)
    }

    /// Removes all cached items.
    public func removeAll() {
        fragmentCache.removeAllObjects()
        imageCache.removeAllObjects()
    }
}

