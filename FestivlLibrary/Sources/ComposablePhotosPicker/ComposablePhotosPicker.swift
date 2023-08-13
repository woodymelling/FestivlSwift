//
//  ComposablePhotosPicker.swift
//  
//
//  Created by Woodrow Melling on 8/12/23.
//

import Foundation
import ComposableArchitecture
import PhotosUI
import SwiftUI


public typealias PhotosPickerState = PhotosPickerDomain.State
public typealias PhotosPickerAction = PhotosPickerDomain.Action

/**
 A Reducer for choosing photos using a PhotosPicker in SwiftUI

 # Usage:

 ```swift
 struct Feature: Reducer {
     struct State {
         @BindingState var image = PhotosPickerState()
     }

     public enum Action: BindableAction {
         case binding(BindingAction<State>)
         case photosPicker(PhotosPickerDomain.Action)
     }

     public var body: some ReducerOf<Self> {

         BindingReducer()
            // Must be on BindingReducer(), because that's the reducer that actually changes the photosPicker
             .photosPicker(state: \.image, action: /Action.photosPicker)

         Reduce { state, action in
             switch action {
             case .binding, .photosPicker:
                 return .none
             }
         }

     }
 }

 ```

 And the View:

 ``` swift
 PhotosPicker("Select an image", selection: viewStore.$image.pickerItem)
 ```
 */
public struct PhotosPickerDomain: Reducer {
    public struct State: Equatable {
        public init() {}

        public var pickerItem: PhotosPickerItem?
        public var image: Image?
    }

    public enum Action: Equatable {
        case didLoadImage(Image?)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .didLoadImage(image):
                state.image = image
                return .none
            }
        }
    }
}

// Has to be on a BindingReducer, because we take advantage of OnChange.
public extension BindingReducer {
    func photosPicker(
        state: WritableKeyPath<State, PhotosPickerState>,
        action: CasePath<Action, PhotosPickerAction>
    ) -> some Reducer<State, Action> {

        CombineReducers {

            self.onChange(of: { $0[keyPath: state].pickerItem }) { oldValue, newValue in
                Reduce { _, _ in
                    guard let photosPickerItem = newValue else { return .none }

                    @Dependency(\.photosPickerClient) var photosPickerClient
                    return .run { [photosPickerItem] send in
                        try await send(action.embed(.didLoadImage(photosPickerClient.loadTransferable(photosPickerItem))))
                    }
                }
            }

            Scope(state: state, action: action) {
                PhotosPickerDomain()
            }
        }
    }
}
