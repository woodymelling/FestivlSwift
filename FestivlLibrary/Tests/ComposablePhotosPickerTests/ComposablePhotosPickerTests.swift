//
//  ComposablePhotosPickerTests.swift
//  
//
//  Created by Woodrow Melling on 8/12/23.
//

import XCTest
import ComposableArchitecture
@testable import ComposablePhotosPicker
import SwiftUI
import PhotosUI

@MainActor
final class ComposablePhotosPickerTests: XCTestCase {
    struct ParentReducer: Reducer {
        struct State: Equatable {
            @BindingState var image = PhotosPickerState()
        }

        enum Action: BindableAction, Equatable {
            case binding(BindingAction<State>)
            case photosPicker(PhotosPickerAction)
        }

        var body: some ReducerOf<Self> {
            BindingReducer()
                .photosPicker(state: \.image, action: /Action.photosPicker)
        }
    }


    func testComposablePhotosPicker() async {
        let store = TestStore(initialState: ParentReducer.State()) {
            ParentReducer()
        } withDependencies: {
            $0.photosPickerClient.loadTransferable = { _ in
                Image(systemName: "star")
            }
        }

        let pickerItem = PhotosPickerItem(itemIdentifier: "blob")
        let image = Image(systemName: "star")

        await store.send(.binding(.set(\.$image, .init(pickerItem: pickerItem)))) {
            $0.image.pickerItem = pickerItem
        }

        await store.receive(.photosPicker(.didLoadImage(image))) {
            $0.image.image = image
        }
    }

}
