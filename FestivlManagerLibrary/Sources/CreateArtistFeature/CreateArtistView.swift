//
//  CreateArtistView.swift
//
//
//  Created by Woody on 3/14/2022.
//

import SwiftUI
import ComposableArchitecture
import MacOSComponents

public struct CreateArtistView: View {
    let store: Store<CreateArtistState, CreateArtistAction>

    public init(store: Store<CreateArtistState, CreateArtistAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                List {
                    Text(viewStore.mode.viewTitle)
                        .font(.largeTitle)

                    VStack(alignment: .leading, spacing: 20) {
                        Form {
                            TextField("Name", text: viewStore.binding(\.$name), prompt: Text("(Required)"))
                        }

                        VStack(alignment: .leading) {
                            Text("Description")
                            TextEditor(text: viewStore.binding(\.$description))
                                .frame(height: 100)
                        }

                        HStack {
                            Toggle("Include in explore", isOn: viewStore.binding(\.$includeInExplore))

                            if(viewStore.includeInExplore) {
                                Stepper("Tier: \(viewStore.tierStepperValue)", value: viewStore.binding(\.$tierStepperValue))
                            }
                        }

                        Form {
                            TextField("Soundcloud URL", text: viewStore.binding(\.$soundcloudURL))
                            TextField("Spotify URL", text: viewStore.binding(\.$spotifyURL))
                            TextField("Website URL", text: viewStore.binding(\.$websiteURL))
                        }

                        HStack {
                            Spacer()
                            ImagePicker(outputImage: viewStore.binding(\.$image), selectedImage: viewStore.binding(\.$selectedImage))
                            Spacer()
                        }


                    }
                }

                Spacer()

                HStack {
                    Button(viewStore.mode.saveButtonName) {
//                        Task {
//                            await viewStore.saveArtist()
//                            if isSheet {
//                                dismiss()
//                            }
//                        }
                    }

//                    if isSheet {
//                        Button("Cancel", role: .cancel) {
//                            dismiss()
//                        }
//                    }
                }
                .padding()
            }
            .padding(.horizontal)
            .frame(minWidth: 500, minHeight: 600)
        }
    }
}

struct CreateArtistView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            CreateArtistView(
                store: .init(
                    initialState: .init(),
                    reducer: createArtistReducer,
                    environment: .init()
                )
            )
            .preferredColorScheme($0)
        }
    }
}
