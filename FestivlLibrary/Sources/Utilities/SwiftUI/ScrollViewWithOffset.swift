import SwiftUI
import UIKit

public struct ScrollableView<Content: View>: UIViewControllerRepresentable {

    @Binding var offset: CGPoint
    var content: () -> Content

    public init(_ offset: Binding<CGPoint>, @ViewBuilder content: @escaping () -> Content) {
        self._offset = offset
        self.content = content
    }

    public func makeUIViewController(context: Context) -> UIScrollViewViewController<Content> {
        let vc = UIScrollViewViewController(hostingController: UIHostingController(rootView: content()))
        vc.hostingController.view.invalidateIntrinsicContentSize()
        vc.scrollView.setContentOffset(offset, animated: false)
        vc.delegate = context.coordinator
        return vc
    }

    public func updateUIViewController(_ viewController: UIScrollViewViewController<Content>, context: Context) {
        viewController.hostingController.rootView = self.content()
        viewController.hostingController.view.invalidateIntrinsicContentSize()

        // Allow for deaceleration to be done by the scrollView
        if !viewController.scrollView.isDecelerating {
            viewController.scrollView.setContentOffset(offset, animated: false)
        }
    }


    public func makeCoordinator() -> Coordinator {
        Coordinator(contentOffset: _offset)
    }

    public class Coordinator: NSObject, UIScrollViewDelegate {
        let contentOffset: Binding<CGPoint>

        init(contentOffset: Binding<CGPoint>) {
            self.contentOffset = contentOffset
        }

        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            contentOffset.wrappedValue = scrollView.contentOffset
        }
    }
}


public class UIScrollViewViewController<Content: View>: UIViewController {

    lazy var scrollView: UIScrollView = UIScrollView()

    var hostingController: UIHostingController<Content>
    weak var delegate: UIScrollViewDelegate?

    init(hostingController: UIHostingController<Content>) {
        self.hostingController = hostingController

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.delegate = delegate
        self.view.addSubview(self.scrollView)
        self.pinEdges(of: self.scrollView, to: self.view)

        self.hostingController.willMove(toParent: self)
        self.scrollView.addSubview(self.hostingController.view)
        self.pinEdges(of: self.hostingController.view, to: self.scrollView)
        self.hostingController.didMove(toParent: self)
        self.hostingController.view.invalidateIntrinsicContentSize()

    }

    func pinEdges(of viewA: UIView, to viewB: UIView) {
        viewA.translatesAutoresizingMaskIntoConstraints = false
        viewB.addConstraints([
            viewA.leadingAnchor.constraint(equalTo: viewB.leadingAnchor),
            viewA.trailingAnchor.constraint(equalTo: viewB.trailingAnchor),
            viewA.topAnchor.constraint(equalTo: viewB.topAnchor),
            viewA.bottomAnchor.constraint(equalTo: viewB.bottomAnchor),
        ])
    }

}

struct ScrollableView_Previews: PreviewProvider {
    static var previews: some View {
        Wrapper()
    }

    struct Wrapper: View {
        @State var offset: CGPoint = .init(x: 0, y: 50)
        var body: some View {
            HStack {
                ScrollableView($offset, content: {
                    ForEach(0...100, id: \.self) { id in
                        Text("\(id)")
                    }
                })

                ScrollableView($offset, content: {
                    ForEach(0...100, id: \.self) { id in
                        Text("\(id)")
                    }
                })



                VStack {
                    Text("x: \(offset.x) y: \(offset.y)")
                    Button("Top", action: {
                        offset = .zero
                    })
                    .buttonStyle(.borderedProminent)
                }
                .frame(width: 200)
                .padding()

            }

        }
    }
}

