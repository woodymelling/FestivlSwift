//
//  ContentView.swift
//  FestivlManager
//
//  Created by Woodrow Melling on 6/25/23.
//

import SwiftUI

struct ContentView: View {
    @State var navSplitViewVisibility = NavigationSplitViewVisibility.detailOnly
    var body: some View {
        NavigationSplitView(columnVisibility: $navSplitViewVisibility) {
            Sidebar()
        } detail: {
            ScheduleView()
        }
    }
}


struct ScheduleView: View {
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
                    
                    
                    Schedule()
                }
                .padding(.leading)
                .inspector(isPresented: $showingInspectorContent) {
                    InspectorView()
                }
                .navigationTitle("Friday")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Artists", systemImage: "person.3") {
                            showingListContent.toggle()
                        }
                        .symbolVariant(showingListContent ? .fill : .none)
                    }
                    
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


struct Schedule: View {
    var body: some View {
        ScrollView {
            SchedulePageView(getCards(count: 4)) {
                CardView(card: $0)
            }
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

extension Button where Label == SwiftUI.Label<Text, Image> {
    init(_ title: LocalizedStringKey, systemImage: String, action: @escaping () -> Void) {
        self.init(action: action, label: { SwiftUI.Label("Blah", systemImage: systemImage)} )
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

struct Sidebar: View {
    var body: some View {
        List {
            Label("Schedule", systemImage: "calendar")
        }
        .listStyle(.sidebar)
    }
}


#Preview("Main Schedule") {
    ContentView()
}

struct HelloWorld: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
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



struct SearchTextField: View {
    @Binding var text: String
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search", text: $text)
        }
        .padding(5)
        .background {
            RoundedRectangle(cornerRadius: 5)
                .stroke()
                .foregroundStyle(.placeholder)
        }
    }
}

#Preview("Search Text Field") {
    SearchTextField(text: .constant(""))
}



struct CardView: View {
    var card: Card
    
    @State var isSelected: Bool = false

    var body: some View {
        ScheduleCardBackground(color: card.color) {
            ViewThatFits {
                VStack(alignment: .leading) {

                    Text(card.dateRange.lowerBound.formatted(.dateTime.hour(.conversationalDefaultDigits(amPM: .abbreviated)).minute()))
                        
                    
                    Text(card.name)
                        .fontWeight(.heavy)
                }
                
                Text(card.name)
            }
            .foregroundStyle(isSelected ? .white : card.color)
            
            .padding(.top, 4)
        }
        .background(isSelected ? card.color : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onTapGesture {
            isSelected.toggle()
        }
    }
}

struct Card: TimelineCard {
    var name: String
    var dateRange: Range<Date>
    var color: Color
    
    var groupWidth: Range<Int>
    
    var id = UUID()
}


import SystemColors


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
        let card = Card(name: name, dateRange: startDate..<endDate, color: colors[wrapped: index], groupWidth: group..<group)
        cards.append(card)
    }
    
    return cards
}

public extension Array {
    subscript(wrapped index: Int) -> Element {
        get {
            self[index % count]
        }
        set {
            self[index % count] = newValue
        }
    }
}



#Preview("Card") {
    CardView(card: getCards(count: 1).first!)
        .frame(width: 200, height: 100)
}
