//
//  SwiftUIView.swift
//  
//
//  Created by Woody on 2/16/22.
//

import SwiftUI
import Models
import Utilities

public struct StageIconView: View {
    public init(stageID: Stage.ID) {
        self.stageID = stageID
    }

    var stageID: Stage.ID

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.stages) var stages

    public var body: some View {
        if let stage = stages[id: stageID] {
            GeometryReader { geo in
                CachedAsyncIcon(
                    url: stage.iconImageURL,
                    placeholder: {
                    Text(stage.symbol)
                        .font(.system(size: 500, weight: .bold))
                        .minimumScaleFactor(0.001)
                        .padding(2)
                        .background(LinearGradient(colors: [stage.color, .primary], startPoint: .topLeading, endPoint: .bottomTrailing))
                })
                .frame(square: geo.size.minSideLength)
                .if(stage.iconImageURL == nil, transform: {
                    $0.background(LinearGradient(colors: [stage.color, .primary], startPoint: .topLeading, endPoint: .bottomTrailing))
                })
//                .if(colorScheme == .light, transform: {
//                    $0.foregroundColor(stage.color)
//                })
//                    .clipShape(Circle())
            }
        }


    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        StageIconView(stageID: Stage.testData.id)
    }
}
