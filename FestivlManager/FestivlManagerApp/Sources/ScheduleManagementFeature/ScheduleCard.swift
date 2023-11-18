//
//  File.swift
//
//
//  Created by Woodrow Melling on 7/5/23.
//

import Foundation
import ComposableArchitecture
import Models
import Tagged

@Reducer
public struct ScheduleCardDomain {
    
    public struct State: Equatable, Identifiable {
        var scheduleItem: ScheduleItem
        var isSelected: Bool
        
        public var id: ScheduleItem.ID { scheduleItem.id }
    }
    
    public enum Action: Equatable {
        case didTapCard
        
        case draggedResizeHandle(handle: ScheduleCardDragHandle, translation: CGFloat, containerHeight: CGFloat)
    }
    
    @Dependency(\.calendar) var calendar
    @Dependency(\.userSettings.scheduleSettings) var settings
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .didTapCard:
                state.isSelected.toggle()
                return .none
            case let .draggedResizeHandle(handle, location, containerHeight):
                var proposed = state.scheduleItem
                
                switch handle {
                case .top:
                    applyDrag(to: &proposed.startTime, location: location, in: containerHeight)
                    
                    proposed.startTime.rounded(to: settings.roundingTime)
                    
                case .bottom:
                    applyDrag(to: &proposed.endTime, location: location, in: containerHeight)
                    
                    proposed.endTime.rounded(to: settings.roundingTime)
                }
                //
                // Validate end state
                guard proposed.startTime.distance(to: proposed.endTime) > settings.minimumSetTime else { return .none }
                
                state.scheduleItem = proposed
                
                return .none
            }
        }
    }
    
    func applyDrag(to date: inout Date, location: CGFloat, in containerHeight: CGFloat) {
        
        let seconds = (location / containerHeight) * 86400
        
        date = calendar.startOfDay(for: date).addingTimeInterval(TimeInterval(seconds))
    }
}

extension Date {
    func distance(to date: Date) -> Duration {
        .seconds(self.distance(to: date))
    }
    
    mutating func rounded(to precision: Duration, rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) {
        self = self.round(precision: TimeInterval(precision.components.seconds), rule: rule)
    }
}


import SwiftUI
import Components
import ScheduleComponents

public enum ScheduleCardDragHandle: Equatable {
    case top, bottom
}

extension Duration {
    static func minutes(_ minutes: some BinaryInteger) -> Duration {
        self.seconds(minutes * 60)
    }
}

struct ScheduleCardView: View {
    let store: StoreOf<ScheduleCardDomain>
    
    @Environment(\.stages) var stages
    @Environment(\.dayStartsAtNoon) var dayStartsAtNoon
    
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GeometryReader { geo in
                
                let color = stages[id: viewStore.scheduleItem.stageID]?.color ?? .clear
                
                ScheduleCardBackground(color: color, isSelected: viewStore.isSelected) {
                    cardContent(title: viewStore.scheduleItem.title, timeInterval: viewStore.scheduleItem.dateInterval)
                        
                        .padding(.top, 4)
                }                
                .placement(viewStore.scheduleItem.frame(
                    in: geo.frame(in: .named("Timeline")).size,
                    groupMapping: [0:0],
                    dayStartsAtNoon: self.dayStartsAtNoon
                ))
                // Gestures
                .overlay { DragHandles(send: { viewStore.send($0) } , containerSize: geo.size) }
                .onTapGesture { viewStore.send(.didTapCard) }
                
            }
        }
    }
    
    @ViewBuilder
    func cardContent(title: String, timeInterval: DateInterval) -> some View {
        ViewThatFits {
            VStack(alignment: .leading) {
                Text(FestivlFormatting.timeIntervalFormat(timeInterval))
                
                Text(title)
                    .fontWeight(.heavy)
            }
            
            Text(title)
                .bold()
            
            EmptyView()
        }
    }
    
    
    struct DragHandles: View {
        
        var send: (ScheduleCardDomain.Action) -> Void
        var containerSize: CGSize
        
        func handle(_ handle: ScheduleCardDragHandle) -> some View {
            Rectangle()
                .fill(.clear)
                .contentShape(Rectangle())
                .highPriorityGesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .named("Timeline"))
                    
                        .onChanged { gesture in
                            _ = send(
                                .draggedResizeHandle(handle: handle, translation: gesture.location.y, containerHeight: containerSize.height)
                            )
                        }
                        .simultaneously(
                            // Can't seem to make the drag handle not eat tap events,
                            // This just manually adds them to the drag handle also
                            with: TapGesture().onEnded {
                                _ = send(.didTapCard)
                            }
                        )
                )
                .frame(height: 10)
                #if(os(macOS))
                .onHover { inside in
                    if inside {
                        NSCursor.resizeUpDown.push()
                    } else {
                        NSCursor.pop()
                    }
                }
                #endif
        }
        
        var body: some View {
            VStack {
                handle(.top)
                Spacer()
                handle(.bottom)
            }
        }
        
    }
}

struct ScheduleItem_Preview: PreviewProvider {
    
    struct CardPreview: View {
        @State var scheduleItem = ScheduleItem.previewData.first!
        
        var body: some View {
            ScheduleGrid {
                
                ScheduleCardView(store: Store(initialState: .init(scheduleItem: scheduleItem, isSelected: false), reducer: {
                    ScheduleCardDomain()
                }))
                
            }
        }
    }
    static var previews: some View {
        CardPreview()
            .environment(\.stages, .previewData)
    }
}


struct StageColorsEnvironmentKey: EnvironmentKey {
    static var defaultValue: [Stage.ID : Color] = [:]
}


extension ScheduleItem: TimelineCard {
    public var groupWidth: Range<Int> {
        0..<0
    }
}



struct Settings {
    var scheduleSettings: ScheduleSettings = ScheduleSettings()
    
    struct ScheduleSettings {
        /// The minimum amount of time a set can be
        var minimumSetTime: Duration = .minutes(5)
        
        /// The time thats rounded to when dragging around an item on the schedule
        /// For example, always have sets dragging to 15 minute intervals
        var roundingTime: Duration = .minutes(15)
        
    }
}

extension Settings: DependencyKey {
    static var liveValue: Settings = Settings() // TODO: store in userDefaults
    static var previewValue: Settings = Settings()
}

extension DependencyValues {
    var userSettings: Settings {
        get { self[Settings.self] }
        set { self[Settings.self] = newValue }
    }
}
