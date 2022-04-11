//
//  File.swift
//  
//
//  Created by Woodrow Melling on 4/9/22.
//

import Foundation

enum FileStorage: CacheDestination {
    private static let baseURL = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

    static subscript(key: String) -> Data? {
        get {
            let url = baseURL.appendingPathComponent(documentKey(for: key))
            return try? Data(contentsOf: url)
        }

        set {
            let url = baseURL.appendingPathComponent(documentKey(for: key))
            _ = try! newValue?.write(to: url)
        }
    }

    private static func documentKey(for key: String) -> String {
        let hashedKey = Hashing.md5(for: key)

        return "\(hashedKey).festivl"
    }

    static func clearCache() throws {
        let fileURLs = try FileManager.default.contentsOfDirectory(at: baseURL,
                                                                   includingPropertiesForKeys: nil,
                                                                   options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
        for fileURL in fileURLs {
            if fileURL.absoluteURL.absoluteString.contains("festivl") {
                try FileManager.default.removeItem(at: fileURL)
            }
        }
    }
}
