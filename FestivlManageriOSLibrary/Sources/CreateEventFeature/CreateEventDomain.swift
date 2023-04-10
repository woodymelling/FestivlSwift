//
//  File.swift
//  
//
//  Created by Woodrow Melling on 2/24/23.
//

import Foundation
import ComposableArchitecture
import ComposableArchitectureForms
import PhotosUI
import SwiftUI

struct CreateEventDomain: FormReducer {
    struct State: FormState {
        struct ValidationErrors: ValidationErrorCollection {
            var dateError: String?
        }
        
        var errors: ValidationErrors = .init()
        var isValid: Bool = false
        @BindingState var focusedField: Field?
        
        @BindingState var name: String = ""
        
        @BindingState var startDate: Date = .now
        @BindingState var endDate: Date = .now
        
        
        @BindingState var dayStartsAtNoon: Bool = true
        
        @BindingState var eventPhoto: PhotosPickerItem?
        
    }
    
    enum Action: FormAction {
        case binding(_ action: BindingAction<State>)
        case validation(_ action: ValidationAction<CreateEventDomain.Field>)
        case focus(_ action: FocusAction<Field>)
    }
    
    enum Field: FormField {
        case name
        case startDate
        case endDate
        
        var fieldDataLocation: FieldDataLocation<State> {
            switch self {
            case .name: return (\.name, nil)
            case .startDate: return (\.startDate, nil)
            case .endDate: return (\.endDate, \.dateError)
            }
        }
    }
    
    var formBody: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .binding, .validation, .focus:
                return .none
            }
        }
    }
    
    static func validate(field: Field, state: State, errors: inout State.ValidationErrors) {
        switch field {
        case .name:
            break
            
        case .startDate, .endDate:
            if state.startDate < .now {
                errors.dateError = "The event must be in the future"
            } else if state.endDate < state.startDate {
                errors.dateError = "The start of the event must be before the end of the event"
            } else {
                errors.dateError = nil
            }
        }
    }
}
