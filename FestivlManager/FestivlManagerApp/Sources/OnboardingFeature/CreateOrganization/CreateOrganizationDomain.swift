//
//  CreateOrganization.swift
//  
//
//  Created by Woodrow Melling on 8/7/23.
//

import Foundation
import ComposableArchitecture

public struct CreateOrganizationDomain: Reducer {
    public struct State: Equatable {
        public init() {}
        
        @BindingState var name: String = ""
        @BindingState var focusedField: Field? = .name

        public enum Field {
            case name
        }
    }
    
    public enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case didTapCreateButton

        case didSubmitField(State.Field)

        case delegate(Delegate)

        public enum Delegate: Equatable {
            case didSubmitForm
        }
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding, .delegate:
                return .none

            case .didTapCreateButton, .didSubmitField(.name):

                return .send(.delegate(.didSubmitForm))
            }
        }
    }
}
