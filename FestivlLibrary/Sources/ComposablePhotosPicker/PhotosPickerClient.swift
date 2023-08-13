//
//  PhotosPickerClient.swift
//  
//
//  Created by Woodrow Melling on 8/12/23.
//

import Foundation
import SwiftUI
import PhotosUI
import Dependencies


public struct PhotosPickerClient: DependencyKey {
    var loadTransferable: (PhotosPickerItem) async throws -> Image?

    public static var liveValue = PhotosPickerClient(
        loadTransferable: { imageSelection in
            try await imageSelection.loadTransferable(type: Image.self)
        }
    )

    public static var testValue = PhotosPickerClient(
        loadTransferable: unimplemented("photosPickerClient.loadTransferable")
    )
}

extension DependencyValues {
    var photosPickerClient: PhotosPickerClient {
        get { self[PhotosPickerClient.self] }
        set { self[PhotosPickerClient.self] = newValue }
    }
}
