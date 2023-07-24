//
//  File.swift
//  
//
//  Created by Woodrow Melling on 7/3/23.
//

import Foundation
import Utilities
import SwiftUI
import ScheduleComponents

//
//  ContentView.swift
//  FestivlManager
//
//  Created by Woodrow Melling on 6/25/23.
//

import SwiftUI


struct ScratchBoard: View {
    @State var showingListContent: Bool = false
    @State var showingInspectorContent: Bool = false
    @State var scheduleType: ScheduleType = .music
    
    enum ScheduleType {
        case music, workshops
    }
    
    var body: some View {
        NavigationStack {
            SplitView(showingListContent: $showingListContent) {
                VStack(spacing: 0) {
//
                    SearchTextField(text: .constant(""))
                        .padding([.horizontal, .bottom])
                        
                    
                    List(artistNames, id: \.self) { name in
                        Text(name)
                    }
                    .listStyle(.plain)
                }
//                .border(.green)
                
            } trailingContent: {
                _Schedule(selectedCard: .constant(nil))
                .padding(.leading)
                .inspector(isPresented: .constant(false)) {
                    InspectorView()
                }
                .navigationTitle("Friday")
                .toolbar {
                    
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Picker("Schedule Type", selection: $scheduleType) {
                            Text("Music")
                                .tag(ScheduleType.music)
                            
                            Text("Workshops")
                                .tag(ScheduleType.workshops)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Showing Details", systemImage: "sidebar.trailing") {
                            showingInspectorContent.toggle()
                        }
                    }
                    
                    ToolbarItem(placement: .topBarLeading) {
                        Menu {
                            Button("Add User") {}
                            Button("Add Set") {}
                        } label: {
                            Label("Add", systemImage: "plus")
                        }
                    }
                    
                    
                    
                    ToolbarTitleMenu {
                        ForEach(["Thursday", "Friday", "Saturday"], id: \.self) { date in
                            Button {
                                
                            } label: {
                                Text(date)
                            }
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}


struct _Schedule: View {
    @Binding var selectedCard: Card?
    
    var body: some View {
        VStack {
            HStack {
                
                ForEach(stageNames, id: \.self) {
                    Text($0)
                        .frame(maxWidth: .infinity)
                        .font(.title2)
                        .fontWeight(.light)
                }
            }
            .padding(.leading, 50)
            
            
            ScrollView {
                ScheduleGrid {
                    Spacer()
                        .frame(height: 2000)
                }
//                SchedulePageView(getCards(count: 4)) { cardContent in
//                    CardView(card: cardContent, isSelected: selectedCard == cardContent)
//                        .onTapGesture {
//                            if selectedCard == cardContent {
//                                selectedCard = nil
//                            } else {
//                                selectedCard = cardContent
//                            }
//                        }
//                }
            }
            .overlay {
                HStack {
                    ForEach(Array(0..<4), id: \.self) {
                        if $0 > 0 {
                            
                            Divider()
                        }
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.leading, 50)
            }
        }
    }
}

extension Button where Label == SwiftUI.Label<Text, Image> {
    init(_ title: LocalizedStringKey, systemImage: String, action: @escaping () -> Void) {
        self.init(action: action, label: { SwiftUI.Label("Blah", systemImage: systemImage)} )
    }
}

extension View {
    @ViewBuilder
    func leadingSidebar<SidebarContent: View>(isPresented: Bool, sidebarContent: @escaping () -> SidebarContent) -> some View {
        SplitView(showingListContent: .constant(isPresented)) {
            sidebarContent()
        } trailingContent: {
            self
        }

    }
}

struct SplitView<LeadingContent: View, TrailingContent: View>: View {
    @Binding var showingListContent: Bool
    
    @ViewBuilder
    let leadingContent: () -> LeadingContent
    
    @ViewBuilder
    let trailingContent: () -> TrailingContent

    
    var body: some View {
        GeometryReader { geo in
            
            HStack(spacing: 0) {
                
                if showingListContent {
                    HStack(spacing: 0) {
                        VStack {
                            leadingContent()
                        }
                        .frame(maxWidth: geo.size.width / 4)
                        
                        Divider()
                    }
                    .transition(.move(edge: .leading))
                }
                
                VStack {
                    trailingContent()
                }
                .frame(maxWidth: .infinity)
            }
            .animation(.easeIn, value: showingListContent)
        }
    }
}

struct InspectorView: View {
    var body: some View {
        Form {
            TextField("Name", text: .constant(""))
        }
    }
}



#Preview("Main Schedule") {
    ScratchBoard()
}

let artistNames = [
    "Orion Moon",
    "Lyrsense",
    "Electra",
    "Max Rhythm",
    "Stella Synth",
    "Echo Nova",
    "Luna Blaze",
    "Harmonix",
    "Astrid",
    "Soundwaves",
    "Soleil Beats",
    "Sapphira",
    "Luminous Vox",
    "Aurelia Pulse",
    "DJ Pulsewave",
    "Cosmic Groove",
    "DiscoBot",
    "Synthex",
    "Rhythmix",
    "Muse Whisperer",
    "Dreamweaver Jazz",
    "Tranquil Mist",
    "Glimmer Sound",
    "Rhapsody Dawn",
    "Stellar Pulse",
    "Neon Sky",
    "Enchanted Echo",
    "Satori Melody",
    "Zen Rhapsody",
    "Vesper",
]
.sorted()

let stageNames = [
    "Main Stage",
    "Dance Tent",
    "Indie Stage",
    "Acoustic Lounge"
]









struct CardView: View {
    var card: Card
    
    var isSelected: Bool

    var body: some View {
        ScheduleCardBackground(color: card.color, isSelected: isSelected) {
            ViewThatFits {
                VStack(alignment: .leading) {

                    Text(card.dateInterval.start.formatted(.dateTime.hour(.conversationalDefaultDigits(amPM: .abbreviated)).minute()))
                        
                    
                    Text(card.name)
                        .fontWeight(.heavy)
                }
                
                Text(card.name)
            }
           
            
            .padding(.top, 4)
        }
    }
}

struct Card: TimelineCard {
    var name: String
    var dateInterval: DateInterval
    var color: Color
    
    var groupWidth: Range<Int>
    
    var id = UUID()
}


func getCards(count: Int) -> [Card] {
    var cards: [Card] = []

    // We'll use the current date as the start date for all cards, and add 1 day to each for the end date.
    
    let startDate = try! Date("02/07/2023, 3:00 AM", strategy: .dateTime)

    
    let colors: [Color] = [
        .systemOrange, .systemYellow, .systemIndigo, .systemPink, .systemRed
    ]
    

    for (index, name) in artistNames.prefix(count).enumerated() {
        let startDate = Calendar.current.date(byAdding: .hour, value: index, to: startDate)!
        let endDate = Calendar.current.date(byAdding: .hour, value: 1, to: startDate)!
        
        let group = index % 4
        let card = Card(name: name, dateInterval: DateInterval(start: startDate, end: endDate), color: colors[wrapped: index], groupWidth: group..<group)
        cards.append(card)
    }
    
    return cards
}




#Preview("Card") {
    CardView(card: getCards(count: 1).first!, isSelected: false)
        .frame(width: 200, height: 100)
}




private struct HorizontalAlignmentGallery: View {
    var body: some View {
        HStack(spacing: 30) {
            column(alignment: .leading, text: "Leading")
            column(alignment: .center, text: "Center")
            column(alignment: .trailing, text: "Trailing")
        }
        .frame(height: 150)
    }


    private func column(alignment: HorizontalAlignment, text: String) -> some View {
        VStack(alignment: alignment, spacing: 0) {
            Color.red.frame(width: 1)
            Text(text).font(.title).border(.gray)
            Color.red.frame(width: 1)
        }
        .border(.green)
    }
}

#Preview("HorizontalAlignment") {
    HorizontalAlignmentGallery()
}

private struct OneQuarterAlignment: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        print(context.width)
        return context.width / 4
    }
}


extension HorizontalAlignment {
    static let oneQuarter = HorizontalAlignment(OneQuarterAlignment.self)
}



extension HorizontalAlignment {
    static let scheduleGrid = HorizontalAlignment(GridAlignment.self)
    
    struct GridAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            return context[.leading]
        }
    }
}

extension VerticalAlignment {
    static let scheduleGridTop = VerticalAlignment(GridAlignment.self)
    
    struct GridAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            return context[.top]
        }
    }
}


struct GridDemo: View {
    var body: some View {
        ScrollView {
            
            GeometryReader { _ in
                
                ZStack(alignment: Alignment(horizontal: .scheduleGrid, vertical: .scheduleGridTop)) {
                    schedule()
                        
                    grid()
                        
                    
                }
            }
            .frame(width: 500, height: 400)
        }
    }
    
    private func schedule() -> some View {
        
        VStack {
            
            Text("Top Bar")
            
            Rectangle()
                .fill(.yellow.opacity(0.5))
                .alignmentGuide(.scheduleGrid, computeValue: { $0[.leading] })
                .alignmentGuide(.scheduleGridTop) { $0[.top] }
                .border(.red)
        }
        .border(.yellow)
    }
    
    private func grid() -> some View {
        HStack {
            ScheduleHourLabelsView()
                            
            ScheduleHourLines()
                .alignmentGuide(.scheduleGrid, computeValue: { $0[.leading] })
        }
        .border(.green)
        .alignmentGuide(.scheduleGridTop) { $0[.top] }
        
    }
  
    @ViewBuilder
    private func stages() -> some View {
        
    }
}

#Preview("GridDemo") {
    GridDemo()
}

struct GridTopPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}


#Preview("Pinned Headers") {
    PinnedHeadersView()
}

struct PinnedHeadersView: View {
    
    @State var headerHeight: CGFloat = 0
    var body: some View {
        ScrollView {
            ZStack {
                
                VStack {
                    Spacer()
                        .frame(height: headerHeight)
                    ScheduleGrid()
                }
                
                
                HStack(spacing: 0) {
                    ForEach(0...5, id: \.self) { column in
                        LazyVStack(pinnedViews: .sectionHeaders) {
                            
                            Section {
                                Spacer()
                                    .frame(height: 1000)
                                
                                
                            } header: {
                                if column != 0 {
                                    
                                    Text("\(column)")
                                        .frame(maxWidth: .infinity)
                                        .background(.black)
                                        .heightReader(updating: GridTopPreferenceKey.self)
                                }
                            }
                            
                            
                        }
                        
                        Divider()
                            .padding(.top, self.headerHeight)
                    }
                    
                }
                
                
            }
            
        }
        .onPreferenceChange(GridTopPreferenceKey.self) { self.headerHeight = $0 }
    }
}


extension View {
    func heightReader<T: PreferenceKey>(updating key: T.Type) -> some View where T.Value == CGFloat {
        self.background {
            
            GeometryReader { geometry in
                Color.clear
                    .preference(key: T.self, value: geometry.size.height)
            }
        }
    }
    
    func widthReader<T: PreferenceKey>(updating key: T.Type) -> some View where T.Value == CGFloat {
        self.background {
            
            GeometryReader { geometry in
                Color.clear
                    .preference(key: T.self, value: geometry.size.width)
            }
        }
    }
    
    func widthReader<T: PreferenceKey>(updating key: T.Type) -> some View where T.Value == CGSize {
        self.background {
            
            GeometryReader { geometry in
                Color.clear
                    .preference(key: T.self, value: geometry.size)
            }
        }
    }

}
