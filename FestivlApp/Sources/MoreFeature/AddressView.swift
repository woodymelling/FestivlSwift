//
//  SwiftUIView.swift
//  
//
//  Created by Woodrow Melling on 5/21/22.
//

import SwiftUI

struct AddressView: View {
    var address: String
    var latitude: String
    var longitude: String
    
    var body: some View {
        List {
            Text(address)
                .font(.headline)
                .textSelection(.enabled)

            Button(action: {
                if let url = URL(string: "http://maps.apple.com/?daddr=\(latitude),\(longitude)") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }, label: {
                Label(title: { Text("Open in Apple Maps") }, icon: {
                    Image("apple-maps", bundle: .module)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                })
            })

            
            Button(action: {
                if let url = URL(string: "https://www.google.com/maps/?q=\(latitude),\(longitude)") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }, label: {
                Label(title: { Text("Open in Google Maps") }, icon: {
                    Image("google-maps", bundle: .module)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                })
            })
        }
        .navigationTitle("Address")

    }
}

struct AddressView_Previews: PreviewProvider {
    static var previews: some View {
        AddressView(
            address: "3901 Kootenay Hwy, Fairmont Hot Springs, BC V0B 1L1, Canada",
            latitude: "",
            longitude: ""
        )
    }
}
