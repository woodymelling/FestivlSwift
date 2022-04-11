//
//  AddEditArtistSetView.swift
//
//
//  Created by Woody on 3/30/2022.
//

import SwiftUI
import ComposableArchitecture
import MacOSComponents
import Models
import Components

public struct AddEditArtistSetView: View {
    let store: Store<AddEditArtistSetState, AddEditArtistSetAction>

    public init(store: Store<AddEditArtistSetState, AddEditArtistSetAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Text(viewStore.mode.title)
                    .font(.largeTitle)

                Form {
                    if viewStore.selectedArtists.count > 1 {
                        Section {
                            TextField("Group Set Name", text: viewStore.binding(\.$groupSetName))
                        }
                    }

                    Section {

                        if viewStore.couldShowGroupSetArtistList && viewStore.selectedArtists.count > 0 {
                            Section("Group Artists:") {
                                Spacer()
                                ForEach(viewStore.selectedArtists) { (artist: Artist) in
                                    HStack {
                                        Text(artist.name)

                                        Button(action: {
                                            viewStore.send(.removeArtistWithID(artist.id!) )
                                        }, label: {
                                            Label("Remove Artist", systemImage: "minus.circle")
                                                .labelStyle(.iconOnly)
                                        })

                                    }

                                }
                            }

                        }

                        ArtistSelector(
                            artists: viewStore.artists,
                            selectedArtist: viewStore.binding(\.$selectedArtist)
                        )
                        if viewStore.selectedArtist != nil && viewStore.selectedArtists.count == 1 {
                            Button("Add More Artists") {
                                viewStore.send(.addMoreArtistsButtonPressed)
                            }
                        }
                    }
                    Spacer()

                    Section {
                        StageSelector(
                            stages: viewStore.stages,
                            selectedStage: viewStore.binding(\.$selectedStage)
                        )
                    }

                    Spacer()

                    Section {

                        EventDaySelector(
                            title: "Set Day",
                            selectedDate: viewStore.binding(\.$selectedDate),
                            festivalDates: viewStore.event.festivalDates
                        )

                        DatePicker(
                            "Start Time",
                            selection: viewStore.binding(\.$startTime),
                            displayedComponents: .hourAndMinute
                        )

                        DatePicker(
                            "End Time",
                            selection: viewStore.binding(\.$endTime),
                            displayedComponents: .hourAndMinute
                        )
                    }
                }
                
                VStack {
                    if let errorText = viewStore.errorText {
                        Text(errorText).foregroundColor(.red)
                    }
                    
                    HStack {
                        Button("Save") {
                            viewStore.send(.saveButtonPressed)
                        }
                        
                        Button("Cancel", role: .cancel) {
                            viewStore.send(.cancelButtonPressed)
                        }
                    }
                    .padding()
                }
            }
            .loading(viewStore.loading)
            .padding()
            .frame(minWidth: 500)
        }
    }
}

struct AddEditArtistSetView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            AddEditArtistSetView(
                store: .init(
                    initialState: .init(
                        event: .testData,
                        artists: Artist.testValues.asIdentifedArray,
                        stages: Stage.testValues.asIdentifedArray
                    ),
                    reducer: addEditArtistSetReducer,
                    environment: .init()
                )
            )
            .preferredColorScheme($0)
        }
    }
}
