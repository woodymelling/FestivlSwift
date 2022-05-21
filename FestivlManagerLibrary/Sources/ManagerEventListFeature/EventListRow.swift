//
//  SwiftUIView.swift
//  
//
//  Created by Woody on 3/8/22.
//

import SwiftUI
import Models
import Utilities

struct EventListRow: View {
    var event: Event
    var body: some View {
        HStack {
            CachedAsyncImage(url: event.imageURL, placeholder: {
                Image(systemName: "music.note.house")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.primary)
            })
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
