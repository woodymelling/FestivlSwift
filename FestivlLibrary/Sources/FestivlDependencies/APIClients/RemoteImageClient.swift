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
import DependenciesMacros

@DependencyClient
public struct RemoteImageClient {
    public var uploadImage: (_ image: PhotosPickerItem, _ path: String) async throws -> URL
}

public enum ImageUploadError: Error {
    case loadingError(Error)
}

extension RemoteImageClient: TestDependencyKey {
    public static var testValue: RemoteImageClient = Self()
    
    public static var previewValue: RemoteImageClient = .init(uploadImage: { _, path in URL(string: "userContent/\(path).png")!})
}

public extension DependencyValues {
    var remoteImageClient: RemoteImageClient {
        get { self[RemoteImageClient.self] }
        set { self[RemoteImageClient.self] = newValue }
    }
}
