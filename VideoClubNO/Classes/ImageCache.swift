//
//  ImageCache.swift
//  VideoClubNO
//
//  Created by Boris Chirino on 15/9/22.
//

import Foundation

final class ImageCache {
    static let shared = ImageCache()
    private var cache: NSCache = NSCache<NSString, NSData>()
    subscript(key: String) -> NSData? {
        get {
            cache.object(forKey: key as NSString) }
        set(image) {
            guard let img = image else {
                self.cache.removeObject(forKey: (key as NSString))
                return
            }
            self.cache.setObject(img, forKey: (key as NSString))
        }
    }
}
