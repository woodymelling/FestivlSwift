//
//  SwiftUIView.swift
//  
//
//  Created by Woody on 2/10/22.
//

import SwiftUI
import Utilities
import Models
import Components

struct EventRowView: View {
    var event: Event

    var eventDateString: String {
        return " \(event.startDate.date.formatted(.dateTime.month().day().year())) - \(event.endDate.date.formatted(.dateTime.month().day().year()))"
    }

    var body: some View {
        ZStack {
            NavigationLink(destination: { EmptyView() }, label: { EmptyView() })
            HStack(spacing: 10) {
                CachedAsyncImage(
                    url: event.imageURL,
                    renderingMode: .template,
                    placeholder: {
                        Image(systemName: "calendar.circle.fill")
                            .resizable()
                    }
                )
                .frame(width: 60, height: 60)
                .foregroundColor(.label)
//                .invertForLightMode()

                VStack(alignment: .leading) {
                    Text(event.name)
                    Text(eventDateString)
                        .lineLimit(1)
                        .font(.caption2)
                }
                .foregroundColor(event.endDate.date < Date.now ? .secondaryLabel : .label )

                Spacer()
            }
        }
    }
}

struct EventRowView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            
            EventRowView(event: Event.previewData)

        }
        .listStyle(.plain)
    }
}
