//
//  SwiftUIView.swift
//  
//
//  Created by Woody on 2/10/22.
//

import SwiftUI
import Utilities
import Models

struct EventRowView: View {
    var event: Event

    var defaultImage: Image {
        Image(systemName: "calendar.circle.fill")
            .resizable()
    }

    var eventDateString: String {
        return " \(event.startDate.formatted(.dateTime.month().day().year())) - \(event.endDate.formatted(.dateTime.month().day().year()))"
    }

    var body: some View {
        HStack(spacing: 10) {
            CachedAsyncImage(url: event.imageURL, placeholder: {
                defaultImage
            })
            .frame(width: 60, height: 60)

            VStack(alignment: .leading) {
                Text(event.name)
                Text(eventDateString)
                    .lineLimit(1)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct EventRowView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            EventRowView(event: Event.testData)

        }
        .listStyle(.plain)
        .previewAllColorModes()
    }
}
