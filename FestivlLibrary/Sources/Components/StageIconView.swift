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

    var stage: Stage

    public init(stage: Stage) {
        self.stage = stage
    }

    public var body: some View {
        GeometryReader { geo in
            AsyncImage(url: stage.iconImageURL, content: { image in
                image
                    .resizable()
                
            }, placeholder: {
                Text(stage.symbol)
                    .font(.system(size: 500, weight: .bold))
                    .minimumScaleFactor(0.001)
                    .padding(2)
                    .frame(square: geo.size.minSideLength)
                    .background(LinearGradient(colors: [stage.color, Color.secondary], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .clipShape(Circle())

            })


        }


    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        StageIconView(stage: .testData)
    }
}
