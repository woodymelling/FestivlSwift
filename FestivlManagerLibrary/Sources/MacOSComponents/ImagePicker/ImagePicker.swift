//
//  ImageInputView.swift
//  FestivlManagerMacOS
//
//  Created by Woody on 1/1/21.
//

import SwiftUI
import Combine
import Utilities

public struct ImagePicker: View {

    @StateObject private var viewModel = ViewModel()

    @Binding var outputImage: NSImage?
    @Binding var selectedImage: NSImage?

    public init(outputImage: Binding<NSImage?>, selectedImage: Binding<NSImage?>? = nil) {
        self._outputImage = outputImage
        self._selectedImage = selectedImage ?? .constant(nil)
    }

    class ViewModel: ObservableObject {
        @Published fileprivate var image: NSImage? {
            didSet {
                zoom = 1
                dragged = .zero
                accumulated = .zero
            }
        }
        @Published fileprivate var zoom: CGFloat =  1

        @Published fileprivate var dragged = CGSize.zero
        @Published fileprivate var accumulated = CGSize.zero

        @Published var selectedImage: NSImage? = nil

        private var cancellables = Set<AnyCancellable>()

        fileprivate let frameSize: CGSize = .square(300)
        fileprivate let destinationSize: CGSize = .square(500)

        init() {

            $zoom
                .map { zoom in
                    self.accumulated * (zoom - 1)
                }
                .assign(to: \.dragged, on: self)
                .store(in: &cancellables)


            Publishers.CombineLatest3($zoom, $dragged, $image)
                .debounce(for: 1, scheduler: RunLoop.main)
                .map { [weak self] zoom, dragged, image -> NSImage? in

                    guard let self = self else { return nil }

                    guard let image = image else { return nil }
                    let imageSize = image.size

                    // Magic from StackOverflow to crop the image acccording to the zoom and pan that the user had selected
                    var scale: CGFloat = self.frameSize.width / imageSize.width
                    if (imageSize.height * scale < self.frameSize.height) {
                        scale = self.frameSize.height / imageSize.height
                    }

                    let currentPositionWidth = dragged.width / scale
                    let currentPositionHeight = -(dragged.height / scale)
                    let croppedImageSize = CGSize(width: (self.frameSize.width/scale) / zoom, height: (self.frameSize.height/scale) / zoom)
                    let xOffset = ((imageSize.width - croppedImageSize.width ) / 2.0) - (currentPositionWidth / zoom)
                    let yOffset = (( imageSize.height - croppedImageSize.height) / 2.0) - (currentPositionHeight / zoom)
                    let croppedImrect: CGRect = CGRect(x: xOffset, y: yOffset, width: croppedImageSize.width, height: croppedImageSize.height)

                    let trimmedImage = image.trim(rect: croppedImrect)

                    // If any side is smaller than our destination size, resize it to the desitnation size
                    if trimmedImage.size.width > self.destinationSize.width && trimmedImage.size.height > self.destinationSize.height {
                        return trimmedImage
                    } else {
                        return trimmedImage.resized(to: self.destinationSize)
                    }

                }
                .map {
                    if let image = $0 {
                        print(image.size)
                    }
                   return $0
                }
                .assign(to: \.selectedImage, on: self)
                .store(in: &cancellables)
        }
    }

    private var scaledImageSize: CGSize {
        guard let imageSize = viewModel.image?.size else { return .zero }

        let unZoomedImageSize: CGSize

        // This only works if the crop area is a square, it could be expanded to work if the crop area is not a square
        if imageSize.height > imageSize.width {
            let widthScaleRatio =  viewModel.frameSize.width / imageSize.width

            unZoomedImageSize = imageSize * widthScaleRatio
        } else if imageSize.height < imageSize.width {
            let heightScaleRatio =  viewModel.frameSize.height / imageSize.height
            unZoomedImageSize = imageSize * heightScaleRatio
        } else {
            unZoomedImageSize = viewModel.frameSize
        }

        return unZoomedImageSize * viewModel.zoom
    }

    private var scrollBound: CGSize {
        return (scaledImageSize - viewModel.frameSize) / 2
    }

    public var body: some View {
        VStack {
            ZStack {

                if let image = viewModel.image {
                    ZStack {
                        Image(nsImage: image)
                            .resizable()
                            .scaleEffect(.square(viewModel.zoom))
                            .offset(viewModel.dragged)
                            .gesture(
                                DragGesture()
                                    .onChanged { gesture in

                                        viewModel.dragged = (gesture.translation + viewModel.accumulated).bounded(min: .zero - scrollBound, max: scrollBound)
                                    }
                                    .onEnded { gesture in
                                        viewModel.dragged = (gesture.translation + viewModel.accumulated).bounded(min: .zero - scrollBound, max: scrollBound)
                                        viewModel.accumulated = viewModel.dragged
                                    }
                            )
                            .aspectRatio(contentMode: .fill)
                            .frame(width: viewModel.frameSize.width, height: viewModel.frameSize.height, alignment: .center)
                            .clipped()

                        VStack {
                            Button(action: {
                                self.viewModel.image = nil
                            }) {
                                Image(systemName: "trash")
                            }
                            .padding()
                        }
                        .frame(width: viewModel.frameSize.width, height: viewModel.frameSize.height, alignment: .topTrailing)
                    }
                } else {
                    Text("Drag and Drop Image File")
                        .font(.title3)
                }

                RoundedRectangle(cornerRadius: 4)
                    .stroke()
                    .frame(width: viewModel.frameSize.width, height: viewModel.frameSize.height)
            }
            .padding()


            Slider(value: $viewModel.zoom, in: 0.2...4)
                .if(viewModel.image == nil) { $0.hidden() }
                .padding(.horizontal)

            Button(viewModel.image == nil ? "Choose Image" : "Choose a different image", action: selectFile)
                .padding(.bottom)
        }
        .frame(width: 330, alignment: .center)
        .background(Color(.underPageBackgroundColor))
        .onDrop(of: ["public.file-url"], isTargeted: nil, perform: handleOnDrop(providers:))
        .onChange(of: viewModel.selectedImage, perform: { image in
            outputImage = image?.resized(to: viewModel.destinationSize)
        })
        .onChange(of: selectedImage, perform: { image in
            viewModel.image = image?.resized(to: viewModel.destinationSize)
        })

    }

    private func handleOnDrop(providers: [NSItemProvider]) -> Bool {
        if let item = providers.first {
            _ = item.loadObject(ofClass: URL.self) { url, error in
                guard let url = url, let image = NSImage(contentsOf: url) else {
                    return
                }
                self.didReceiveImage(image)
            }

            return true
        }
        return false
    }

    private func selectFile() {
        NSOpenPanel.openImage { result in
            if case let .success(image) = result {
                self.didReceiveImage(image)
            }
        }
    }

    private func didReceiveImage(_ image: NSImage) {
        DispatchQueue.main.async {
            viewModel.image = image
        }
    }
}


