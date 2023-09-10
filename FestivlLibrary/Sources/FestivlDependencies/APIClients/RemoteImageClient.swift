//
//  RemoteImageClient.swift
//  
//
//  Created by Woodrow Melling on 8/13/23.
//

import Foundation
import SwiftUI
import PhotosUI
import Dependencies


public struct RemoteImageClient {
    public init(uploadImage: @escaping (_: PhotosPickerItem, _: String) async throws -> URL) {
        self.uploadImage = uploadImage
    }
    
    public var uploadImage: (_ image: PhotosPickerItem, _ path: String) async throws -> URL
}

public enum ImageUploadError: Error {
    case loadingError(Error)
}

extension RemoteImageClient: TestDependencyKey {
    public static var testValue: RemoteImageClient = .init(uploadImage: unimplemented("RemoteImageClient.uploadImage"))
    public static var previewValue: RemoteImageClient = .init(uploadImage: { _, path in URL(string: "userContent/\(path).png")!})
}

public extension DependencyValues {
    var remoteImageClient: RemoteImageClient {
        get { self[RemoteImageClient.self] }
        set { self[RemoteImageClient.self] = newValue }
    }
}
