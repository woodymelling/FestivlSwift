//
//  SwiftUIView.swift
//  
//
//  Created by Woody on 3/8/22.
//

import SwiftUI
import Models

struct EventListRow: View {
    var event: Event
    var body: some View {
        HStack {
            AsyncImage(url: event.imageURL) { imagePhase in
                switch imagePhase {
                case let .success(image):
                    image.resizable()
                case .empty, .failure:
                    Image(systemName: "music.note.house")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.primary)
                @unknown default:
                    EmptyView()
                }

            }
            .frame(width: 75, height: 75)

            VStack(alignment: .leading) {
                Text(event.name)
                    .font(.title)
                    .foregroundColor(.primary)

                Text(event.startDate...event.endDate)
            }

            Spacer()
            Image(systemName: "chevron.right")

        }
        .contentShape(Rectangle())
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        EventListRow(event: .testData)
    }
}
