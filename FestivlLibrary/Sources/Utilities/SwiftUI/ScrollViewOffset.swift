//
//  File.swift
//  
//
//  Created by Woodrow Melling on 4/12/22.
//

import Foundation
import Introspect
import SwiftUI
import Combine

public struct ScrollViewOffset<Content: View>: View {



    @StateObject var viewModel: OffsetScrollHandler = .init()
    @Binding var contentOffset: CGPoint
    var content: () -> Content


    public init(contentOffset: Binding<CGPoint>, content: @escaping () -> Content) {

        self.content = content
        self._contentOffset = contentOffset
    }


    public var body: some View {
        ScrollView {
            content()
        }
        .introspectScrollView { scrollView in
            viewModel.register(scrollView: scrollView, initialContentOffset: contentOffset)
        }
        .onAppear {

            viewModel.contentOffset = contentOffset
        }
        .onChange(of: viewModel.contentOffset) {
            print("OnAppear:", viewModel.contentOffset, contentOffset)
            contentOffset = $0
        }
        .onChange(of: contentOffset) {

                viewModel.contentOffset = $0


        }
    }
}

class OffsetScrollHandler: NSObject, ObservableObject {

    weak var scrollView: UIScrollView?
    @Published var contentOffset: CGPoint = .zero

    var cancellables = Set<AnyCancellable>()

    override init() { }

    func register(scrollView: UIScrollView, initialContentOffset: CGPoint) {
        guard self.scrollView == nil else { return }

        self.scrollView = scrollView

        self.contentOffset = contentOffset

        scrollView.delegate = self

        scrollView.setContentOffset(self.contentOffset, animated: false)
        print("registering")

        $contentOffset
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .sink {
                scrollView.setContentOffset($0, animated: false)
            }
            .store(in: &cancellables)
    }

}

extension OffsetScrollHandler: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if contentOffset != scrollView.contentOffset {
            self.contentOffset = scrollView.contentOffset
        }

    }
}
