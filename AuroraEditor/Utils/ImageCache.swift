//
//  ImageCache.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/11/21.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import AppKit

/// Image cache
class ImageCache {
    /// Shared instance
    static let shared = ImageCache()

    /// Initialize
    private init() {
        resetCacheIfNeeded()
    }

    /// Cache
    private let cache = URLCache(
        memoryCapacity: 100 * 1024 * 1024, // 100 MB memory cache
        diskCapacity: 500 * 1024 * 1024, // 500 MB disk cache
        diskPath: nil
    )

    /// UserDefaults key for storing the last reset date
    private let lastResetDateKey = "ImageCacheLastResetDate"

    /// Cache reset interval in seconds (30 days)
    private let cacheResetInterval: TimeInterval = 30 * 24 * 60 * 60

    /// Get cached image
    /// 
    /// - Parameter url: URL
    /// 
    /// - Returns: Image
    func getCachedImage(url: URL) -> NSImage? {
        resetCacheIfNeeded()
        if let data = cache.cachedResponse(for: URLRequest(url: url))?.data {
            return NSImage(data: data)
        }
        return nil
    }

    /// Cache image
    /// 
    /// - Parameter data: Data
    /// - Parameter response: URLResponse
    func cacheImage(data: Data, response: URLResponse) {
        resetCacheIfNeeded()
        guard let url = response.url else { return }
        let cachedData = CachedURLResponse(response: response, data: data)
        cache.storeCachedResponse(cachedData, for: URLRequest(url: url))
    }

    /// Reset cache if needed
    private func resetCacheIfNeeded() {
        let now = Date()
        let lastResetDate = UserDefaults.standard.object(
            forKey: lastResetDateKey
        ) as? Date ?? Date.distantPast
        if now.timeIntervalSince(
            lastResetDate
        ) > cacheResetInterval {
            cache.removeAllCachedResponses()
            UserDefaults.standard.set(
                now,
                forKey: lastResetDateKey
            )
        }
    }
}
