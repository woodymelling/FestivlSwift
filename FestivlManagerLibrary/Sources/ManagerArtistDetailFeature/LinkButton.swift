//
//  SwiftUIView.swift
//  
//
//  Created by Woodrow Melling on 3/20/22.
//

import SwiftUI

struct LinkButton: View {

    var url: URL
    var icon: Image?
    var action: (URL) -> Void

    var body: some View {
        Button(action: {
            action(url)
        }, label: {
            Label(title: {
                Text(url.absoluteString)
            }, icon: {
                icon?
                    .resizable()
                    .scaledToFit()
            })
            .labelStyle(LinkLabelStyle())
        })
        .buttonStyle(.link)
    }
}

struct LinkLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon
                .frame(width: 25)

            configuration.title
        }
    }
}
//
//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        LinkButton(url: <#URL#>, action: <#(URL) -> Void#>)
//    }
//}
