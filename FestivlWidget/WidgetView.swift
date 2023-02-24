////
////  FestivlWidget.swift
////  FestivlWidget
////
////  Created by Woodrow Melling on 7/15/22.
////
//
//import WidgetKit
//import SwiftUI
//import Intents
//
//@main
//struct FestivlWidget: Widget {
//    let kind: String = "FestivlWidget"
//
//    var body: some WidgetConfiguration {
//        StaticConfiguration(kind: kind, provider: ScheduleProvider()) { entry in
//            FestivlWidgetEntryView(entry: entry)
//        }
//        .configurationDisplayName("My Widget")
//        .description("This is an example widget.")
//    }
//}
//
//struct FestivlWidgetEntryView: View {
//    var entry: ScheduleEntry
//    
//    var body: some View {
//        VStack {
//            Text(entry.festivalName)
//                .onAppear {
//                    print("Widget Hit")
//                }
//        }
//    }
//}
//
////struct FestivlWidget_Previews: PreviewProvider {
////    static var previews: some View {
////        FestivlWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
////            .previewContext(WidgetPreviewContext(family: .systemSmall))
////    }
////}
