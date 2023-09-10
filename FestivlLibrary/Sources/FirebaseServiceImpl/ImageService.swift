//
//  File.swift
//  
//
//  Created by Woodrow Melling on 3/16/22.
//

import Foundation
import FestivlDependencies


import SwiftUI
import FirebaseStorage
import PhotosUI

extension RemoteImageClient: DependencyKey {
    public static var liveValue: RemoteImageClient {
        RemoteImageClient { image, path in

            do {
                guard let data = try await image.loadTransferable(type: Data.self) else {
                    throw ImageUploadError.loadingError(FestivlError.default(description: "Failed to load image"))
                }

                let storageRef = Storage.storage().reference().child("userContent/\(path).png")

                return try await withCheckedThrowingContinuation { [data] continuation in
                    storageRef.putData(data) { result in
                        switch result {
                        case .success:
                            storageRef.downloadURL { url, error in
                                if let error = error {
                                    continuation.resume(throwing: ImageUploadError.loadingError(error))
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
            } catch {
                throw ImageUploadError.loadingError(error)
            }
        }
    }
}
