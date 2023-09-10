//
//  File.swift
//  
//
//  Created by Woodrow Melling on 8/22/23.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct FormSheetModifier<SheetContent: View>: ViewModifier {

    @ViewBuilder var sheetContent: () -> SheetContent


    func body(content: Content) -> some View {
        ZStack {
            content

            sheetContent()
                .frame(width: 540, height: 640)
                .background(.thickMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 25.0))
        }
    }
}


#Preview {
    NavigationStack {
        ScheduleManagementView(
            store: Store(
                initialState: .init()
            ) {
                ScheduleManagementDomain()
            }

        )
        .sheet(isPresented: .constant(true), content: {
            Text("Blah")
        })
        .environment(\.stages, .previewData)
    }
}
