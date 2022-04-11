//
//  File.swift
//  
//
//  Created by Woodrow Melling on 4/9/22.
//

import Foundation


public protocol CacheDestination {
    static subscript(key: String) -> Data? { get set }
    static func clearCache() throws
}

struct CacheResource<T: Codable>: Codable {
    let data: T
    let expirationDate: Date
}

/// An API for interacting with a cache.
/// The actual storage backing for the cache is provided by a CacheDestination
final class Cache<Destination: CacheDestination> {

    static var defaultCacheTime: TimeInterval {
        return 24 * 60 * 60 * 7 // 7 Day cache time
    }

    func insert<T: Codable>(data: T, key: String, lifetime: TimeInterval = Cache.defaultCacheTime) {
        let resource = CacheResource(data: data, expirationDate: Date().addingTimeInterval(lifetime))

        let encodedData = try! JSONEncoder().encode(resource)

        Destination[key] = encodedData
    }

    func fetch<T: Codable>(key: String, type: T.Type) -> T? {

        guard let data = Destination[key] else { return nil }

        guard let resource = try? JSONDecoder().decode(CacheResource<T>.self, from: data) else { return nil }

        guard resource.expirationDate > Date() else { return nil }

        return resource.data
    }

    func delete(key: String) {
        Destination[key] = nil
    }

    public static func clear() throws {
        try Destination.clearCache()
    }
}
