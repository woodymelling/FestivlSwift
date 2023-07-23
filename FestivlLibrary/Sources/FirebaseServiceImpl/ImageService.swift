//
//  File.swift
//  
//
//  Created by Woodrow Melling on 3/16/22.
//

import Foundation
import FestivlDependencies

#if os(iOS)
    import UIKit
    public typealias Image = UIImage
#elseif os(OSX)
    import AppKit
    public typealias Image = NSImage
#endif

import FirebaseStorage

public protocol ImageServiceProtocol {
    func uploadImage(_ image: Image, fileName: String) async throws -> URL
}

public class ImageService: ImageServiceProtocol {
    public static var shared = ImageService()
    
    
    public func uploadImage(_ image: Image, fileName: String) async throws -> URL {
        let storageRef = Storage.storage().reference().child("userContent/\(fileName).png")
        guard let data = image.pngData() else { throw FestivlError.default(description: "Failed to convert to png" )}
        
        return try await withCheckedThrowingContinuation { continuation in
            storageRef.putData(data) { result in
                switch result {
                case .success:
                    storageRef.downloadURL { url, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else if let url = url {
                            continuation.resume(returning: url)
                        } else {
                            continuation.resume(throwing: FestivlError.default(description: "No URL or error returned"))
                        }
                    }
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
            
        }
    }
}

public struct MockImageService: ImageServiceProtocol {
    public func uploadImage(_ image: Image, fileName: String) async throws -> URL {
        return URL(string: "userContent/\(fileName).png")!
    }
}

#if os(OSX)
extension NSImage {
    func pngData() -> Data? {
        let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        let jpegData = bitmapRep.representation(using: NSBitmapImageRep.FileType.png, properties: [:])!
        return jpegData
    }

    public static func fromURL(url: URL) async -> NSImage? {
        do {
            let response = try await URLSession.shared.data(for: URLRequest(url: url))

            return NSImage(data: response.0)
        } catch {
            return nil
        }
    }
}
#endif
