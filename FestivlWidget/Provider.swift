//
//  Provider.swift
//  Festivl
//
//  Created by Woodrow Melling on 7/15/22.
//

import Foundation
import WidgetKit


struct ScheduleEntry: TimelineEntry {
    var date: Date
    var festivalName: String
    var currentSets: [ScheduleItem]
    var upcomingSets: [ScheduleItem]
}


struct ScheduleProvider: TimelineProvider {
    
    
    
    func getSnapshot(in context: Context, completion: @escaping (ScheduleEntry) -> Void) {
        let date = Date()
        
        if let activeFestivalName = UserDefaults.standard.string(forKey: "activeFestivalName"),
           let schedule = UserDefaults(suiteName: "group.Festivl")?.data(forKey: "activeFestivalSchedule") {
            
            let schedule = try! JSONDecoder().decode([ScheduleItem], from: schedule)
            completion(.init(date: date, festivalName: activeFestivalName))
        }
    
        
    }
    
    func placeholder(in context: Context) -> ScheduleEntry {
        .init(date: Date(), festivalName: "Placeholder")
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ScheduleEntry>) -> Void) {
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 5, to: .now)!
        
        var entries: [ScheduleEntry] = [.init(date: .now, festivalName: "Test")]
        
        if let festivalName = UserDefaults(suiteName: "group.Festivl")?.string(forKey: "activeFestivalName") {
            entries.append(.init(date: .now, festivalName: festivalName))
        }
        
        let timeline = Timeline(entries: entries, policy: .after(nextUpdateDate))
        
        completion(timeline)
    }
    
    
}

struct ScheduleItem: Codable {
    public var stageID: SimpleStage.ID
    public var startTime: Date
    public var endTime: Date
    public var title: String
    public var subtext: String?
    public var id: String?
}

struct SimpleStage: Codable, Identifiable {
    var id: String
    var iconImageURL: URL?
    var colorString: String
}
