//
//  AlwaysPopoverModifier.swift
//  Popovers
//
//  Copyright © 2021 PSPDFKit GmbH. All rights reserved.
//

import SwiftUI

public struct AlwaysPopoverModifier<PopoverContent>: ViewModifier where PopoverContent: View {
    public init(isPresented: Binding<Bool>, contentBlock: @escaping () -> PopoverContent, duration: CGFloat?) {
        self._isPresented = isPresented
        self.contentBlock = contentBlock
        self.duration = duration
    }


    @Binding var isPresented: Bool
    let contentBlock: () -> PopoverContent

    let duration: CGFloat?

    // Workaround for missing @StateObject in iOS 13.
    private struct Store {
        var anchorView = UIView()
    }

    @State private var store = Store()

    public func body(content: Content) -> some View {
        if isPresented {
            presentPopover()
        } else {
            
        }

        return content
            .background(InternalAnchorView(uiView: store.anchorView))
            .task {
                if let duration = duration {
                    try? await Task.sleep(nanoseconds: UInt64(CGFloat(1_000_000_000) * duration))
                    isPresented = false
                }
            }
            .onTapGesture {
                isPresented = false
            }
    }

    private func presentPopover() {
        let contentController = ContentViewController(rootView: contentBlock(), isPresented: _isPresented)
        contentController.modalPresentationStyle = .popover

        let view = store.anchorView
        guard let popover = contentController.popoverPresentationController else { return }
        popover.sourceView = view
        popover.sourceRect = view.bounds
        popover.delegate = contentController

        guard let sourceVC = view.closestVC() else { return }
        if let presentedVC = sourceVC.presentedViewController {
            presentedVC.dismiss(animated: true) {
                sourceVC.present(contentController, animated: true)
            }
        } else {
            sourceVC.present(contentController, animated: true)
        }
    }

    private struct InternalAnchorView: UIViewRepresentable {
        typealias UIViewType = UIView
        let uiView: UIView

        func makeUIView(context: Self.Context) -> Self.UIViewType {
            uiView
        }

        func updateUIView(_ uiView: Self.UIViewType, context: Self.Context) { }
    }
}


extension View {
    public func alwaysPopover<Content>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content,
        duration: CGFloat?
    ) -> some View where Content : View {
        self.modifier(AlwaysPopoverModifier(isPresented: isPresented, contentBlock: content, duration: duration))
    }
}


extension UIView {
    func closestVC() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            if let vc = responder as? UIViewController {
                return vc
            }
            responder = responder?.next
        }
        return nil
    }
}

class ContentViewController<V>: UIHostingController<V>, UIPopoverPresentationControllerDelegate where V:View {
    var isPresented: Binding<Bool>

    init(rootView: V, isPresented: Binding<Bool>) {
        self.isPresented = isPresented
        super.init(rootView: rootView)
    }

    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let size = sizeThatFits(in: UIView.layoutFittingExpandedSize)
        preferredContentSize = size
    }

    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.isPresented.wrappedValue = false
    }
}
