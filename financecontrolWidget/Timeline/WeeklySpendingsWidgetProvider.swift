//
//  WeeklySpendingsWidgetProvider.swift
//  SquirrelWidgetExtension
//
//  Created by PinkXaciD on R 6/07/26.
//

import WidgetKit

fileprivate let templateData: [Date:Double] = [
    Calendar.current.startOfDay(for: Date()):1100,
    Calendar.current.startOfDay(for: Date().addingTimeInterval(-60*60*24)):600,
    Calendar.current.startOfDay(for: Date().addingTimeInterval(-(60*60*24)*2)):200,
    Calendar.current.startOfDay(for: Date().addingTimeInterval(-(60*60*24)*3)):900,
    Calendar.current.startOfDay(for: Date().addingTimeInterval(-(60*60*24)*4)):1200,
    Calendar.current.startOfDay(for: Date().addingTimeInterval(-(60*60*24)*5)):300,
    Calendar.current.startOfDay(for: Date().addingTimeInterval(-(60*60*24)*6)):800
]

struct WeeklySpendingsWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeeklySpendingsWidgetEntry {
        .init(date: Date(), data: templateData, currency: Locale.current.currencyCode ?? "USD")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WeeklySpendingsWidgetEntry) -> Void) {
        let defaults: UserDefaults? = .init(suiteName: Vars.groupName)
        let data = defaults?.dictionary(forKey: "WeeklySpendingsWidgetData") as? [String:Double] ?? .init()
        let defaultCurrency = defaults?.string(forKey: "defaultCurrency") ?? Locale.current.currencyCode ?? "USD"
        
        let trueData = {
            let calendar = Calendar.current
//            calendar.locale = Locale.current
//            
//            if #available(iOS 16.0, *) {
//                calendar.timeZone = .gmt
//            } else {
//                calendar.timeZone = .init(secondsFromGMT: 0)! // Should never fail
//            }
            
            var result = [Date:Double]()
            for offset in 0..<7 {
                let day = calendar.date(byAdding: .day, value: -offset, to: calendar.startOfDay(for: Date())) ?? Date()
                let value = data[day.formatted(.iso8601)] ?? 0
                result.updateValue(value, forKey: day)
            }
            return result
        }()
        
        completion(Entry(date: Date(), data: trueData, currency: defaultCurrency))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WeeklySpendingsWidgetEntry>) -> Void) {
        let defaults: UserDefaults? = .init(suiteName: Vars.groupName)
        let data = defaults?.dictionary(forKey: "WeeklySpendingsWidgetData") as? [String:Double] ?? .init()
        let defaultCurrency = defaults?.string(forKey: "defaultCurrency") ?? Locale.current.currencyCode ?? "USD"
        
        print(defaultCurrency, data)
        
        let trueData = {
            let calendar = Calendar.current
//            calendar.locale = Locale.current
//            
//            if #available(iOS 16.0, *) {
//                calendar.timeZone = .gmt
//            } else {
//                calendar.timeZone = .init(secondsFromGMT: 0)! // Should never fail
//            }
            
            var result = [Date:Double]()
            for offset in 0..<7 {
                let day = calendar.date(byAdding: .day, value: -offset, to: calendar.startOfDay(for: Date())) ?? Date()
                let value = data[day.formatted(.iso8601)] ?? 0
                result.updateValue(value, forKey: day)
            }
            return result
        }()
        
//        print(data)
//        print(trueData)
        
        let timeline = Timeline(entries: [WeeklySpendingsWidgetEntry(date: Date(), data: trueData, currency: defaultCurrency)], policy: .atEnd)
        
        completion(timeline)
    }
    
    typealias Entry = WeeklySpendingsWidgetEntry
}

struct WeeklySpendingsWidgetEntry: TimelineEntry {
    var date: Date
    
    let data: [Date:Double]
    let currency: String
    
    var todaySum: Double {
        data[Calendar.current.startOfDay(for: Date())] ?? 0
    }
    
//    var average: Double {
//        return 0
//    }
}
