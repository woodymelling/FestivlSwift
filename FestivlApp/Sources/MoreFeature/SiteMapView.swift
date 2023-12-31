//
//  SwiftUIView.swift
//
//
//  Created by Woodrow Melling on 4/22/22.
//

import SwiftUI
import PDFKit
//import Kingfisher
import ComposableArchitecture
import ImageViewer
import Utilities
import Components

public struct SiteMapFeature: Reducer {

    public struct State: Equatable {
        var url: URL
    }

    public enum Action: Equatable {}

    public var body: some ReducerOf<Self> {
        return EmptyReducer()
    }
}

struct SiteMapView: View {

    let store: StoreOf<SiteMapFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZoomableScrollView {
                FestivlCachedAsyncImage(url: viewStore.url) {
                    ProgressView()
                }
                .aspectRatio(contentMode: .fit)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Site Map")
    }
}

struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    private var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    func makeUIView(context: Context) -> UIScrollView {
        // set up the UIScrollView
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator  // for viewForZooming(in:)
        scrollView.maximumZoomScale = 20
        scrollView.minimumZoomScale = 1
        scrollView.bouncesZoom = true

        // create a UIHostingController to hold our SwiftUI content
        let hostedView = context.coordinator.hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = true
        hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostedView.frame = scrollView.bounds
        scrollView.addSubview(hostedView)

        return scrollView
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(hostingController: UIHostingController(rootView: self.content))
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        // update the hosting controller's SwiftUI content
        context.coordinator.hostingController.rootView = self.content
        assert(context.coordinator.hostingController.view.superview == uiView)
    }

    static func dismantleUIView(_ uiView: UIScrollView, coordinator: Coordinator) {
        uiView.delegate = nil
        coordinator.hostingController.view = nil
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>

        init(hostingController: UIHostingController<Content>) {
            self.hostingController = hostingController
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController.view
        }
    }
}
