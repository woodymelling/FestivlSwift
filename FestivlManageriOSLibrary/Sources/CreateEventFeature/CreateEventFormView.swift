//
//  SwiftUIView.swift
//  
//
//  Created by Woodrow Melling on 2/24/23.
//

import SwiftUI
import ComposableArchitecture
import ComposableArchitectureForms
import PhotosUI

struct CreateEventFormView: View {
    let store: StoreOf<CreateEventDomain>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section("Name") {
                    TextField("Name", text: viewStore.binding(\.$name))
                        .validation(store, field: .name)
                }
                
                Section("Date") {
                    DatePicker(
                        "Start Date",
                        selection: viewStore.binding(\.$startDate),
                        displayedComponents: [.date]
                    )
                    
                    DatePicker(
                        "End Date",
                        selection: viewStore.binding(\.$endDate),
                        displayedComponents: [.date]
                    )
                }
                
              
                Section {
                    Toggle("Day Starts at Noon", isOn: viewStore.binding(\.$dayStartsAtNoon))
                } footer: {
                    Text("If enabled, the schedule for Saturday goes from noon Saturday to noon Sunday")
                }
                
//                Section("Event Image") {
//                    PhotosPicker(
//                        "Select an Image",
//                        selection: viewStore.binding(\.$eventPhoto),
//                        matching: .any(of: [.images, .not(.screenshots)])
//                    )
//                    
////                    if let selectedImage = viewStore.eventImage {
////                        
////                    }
//                }
                
                
            }
            .navigationTitle("Create Event")
        }
    }
}


struct CreateEventFormView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            
            CreateEventFormView(store: .init(initialState: .init(), reducer: CreateEventDomain()))
        }
    }
}
