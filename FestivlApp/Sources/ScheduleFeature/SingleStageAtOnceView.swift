//
//  Schedule.swift
//
//
//  Created by Woody on 2/17/2022.
//

import SwiftUI
import ComposableArchitecture
import Utilities
import Models
import SimultaneouslyScrollView

public struct SingleStageAtOnceView: View {
    let store: StoreOf<ScheduleFeature>
    
    @StateObject var scrollViewModel: ViewModel = .init()
    
    @State private var headerHeight: CGFloat = 0
    
    public init(store: StoreOf<ScheduleFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            
            ZStack(alignment: .top) {
                
                VStack {
                    Spacer()
                        .frame(height: headerHeight)
                    
                    TabView(selection: viewStore.binding(\.$selectedStage)) {
                        if viewStore.showComingSoonScreen {
                            ScheduleComingSoonView(imageURL: viewStore.event.imageURL)
                        } else {
                            ForEach(viewStore.stages) { stage in
                                ScheduleScrollView(store: store, style: .singleStage(stage), scrollViewHandler: scrollViewModel)
                                    .tag(stage)
                            }
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                
                ScheduleHeaderView(stages: viewStore.stages, selectedStage: viewStore.binding(\.$selectedStage).animation(.easeInOut(duration: 0.1)))
                    .background(GeometryReader { geometry in
                        Color.clear.preference(
                            key: HeaderHeightPreferenceKey.self,
                            value: geometry.size.height
                        )
                    })
                
            }
            .onPreferenceChange(HeaderHeightPreferenceKey.self, perform: {
                headerHeight = $0
            })
        }
        
    }
    
    class ViewModel: ObservableObject {
        var scrollViewHandler = SimultaneouslyScrollViewHandlerFactory.create()
        
        init() {}
    }
    
    private struct HeaderHeightPreferenceKey: PreferenceKey {
        
        static var defaultValue: CGFloat = 0
        
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
}



//struct SingleStageAtOnceView_Previews: PreviewProvider {
//    static var previews: some View {
//        SingleStageAtOnceView(
//            store: .testStore
//        )
//        .previewAllColorModes()
////        .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
//    }
//
//}
