//
//  ImageCriteriaView.swift
//  
//
//  Created by Woodrow Melling on 8/13/23.
//

import Foundation
import SwiftUI
import SharedResources
import Utilities
import CriteriaUI

struct IconImageCriteriaView: View {
    var image: Image?

    @State var imageCriteria: Loader<ImageCriteria>? = nil

    var body: some View {
        CriteriaView(for: imageCriteria) {
            #Predicate { $0.square }.labeled("square")
            #Predicate { $0.centered }.labeled("centered")
            #Predicate { $0.singleColor }.labeled("single color")
            #Predicate { $0.transparentBackground }.labeled("transparent background")
        }
        .onChange(of: image) { _, image in
            if let image {
                self.imageCriteria = .loading

                Task(priority: .userInitiated) {
                    self.imageCriteria = await .loaded(getImageCriteria(for: image))
                }
            } else {
                self.imageCriteria = nil
            }
        }
    }
}

private struct IconImageCriteriaView_Preview: View {
    @State var image: Image?

    var body: some View {
        VStack {
            if let image {
                image
                    .resizable()
                    .frame(square: 200)
            }

            IconImageCriteriaView(image: image)

            Button("Select Partial Failure") {
                image = Image(systemName: "star")
            }

            Button("Select Correct") {
                image = FestivlAssets.logo
            }
        }
        .buttonStyle(.bordered)
    }
}

#Preview("Icon Image Preview") {
    IconImageCriteriaView_Preview()
}


struct ImageCriteria: Equatable {
    let square: Bool
    let centered: Bool
    let singleColor: Bool
    let transparentBackground: Bool

    init(square: Bool, centered: Bool, singleColor: Bool, transparentBackground: Bool) {
        self.square = square
        self.centered = centered
        self.singleColor = singleColor
        self.transparentBackground = transparentBackground
    }

    static var `false` = ImageCriteria(square: false, centered: false, singleColor: false, transparentBackground: false)
}

func getImageCriteria(for view: some View) async -> ImageCriteria {
    guard let uiImage = await view.uiImage
    else { return .false }

    let square = uiImage.size.width == uiImage.size.height
    let centered = square

    var baseColor: PixelData?

    let (hasAlpha, singleColor) = await view.frame(square: 500).reducePixels(
        (hasAlpha: false, singleColor: true)
    ) { result, pixel in
        if baseColor == nil && !pixel.isFullyTransparent {
            baseColor = pixel
        }

        return (
            hasAlpha: result.hasAlpha || pixel.hasTransparency,
            singleColor: result.singleColor && (baseColor.map(pixel.equalsIgnoringAlpha) ?? true || pixel.isGrayscale)
        )
    }

    return ImageCriteria(
        square: square,
        centered: centered,
        singleColor: singleColor,
        transparentBackground: hasAlpha
    )
}
