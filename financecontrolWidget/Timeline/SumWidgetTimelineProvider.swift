//
//  SumWidgetTimelineProvider.swift
//  financecontrol
//
//  Created by PinkXaciD on R 6/01/12.
//

import WidgetKit
import OSLog

struct SumWidgetTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> SumEntry {
        SumEntry(date: Date(), expenses: 100, currency: "USD")
    }

    func getSnapshot(in context: Context, completion: @escaping (SumEntry) -> Void) {
        let sharedDefaults: UserDefaults? = UserDefaults(suiteName: "group.financecontrol")
        let localeCurrency: String? = Locale.current.currencySymbol
        
        let entry = SumEntry(
            date: Date(),
            expenses: sharedDefaults?.double(forKey: "amount") ?? 0,
            currency: sharedDefaults?.string(forKey: "defaultCurrency") ?? localeCurrency ?? "USD"
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SumEntry>) -> Void) {
        var entries: [SumEntry] = []
        let defaults: UserDefaults? = .init(suiteName: "group.financecontrol")
        let logger: Logger = .init(subsystem: "com.pinkxacid.financecontrol.financecontrolWidget", category: "Sum widget timelines")

        let currentDate = Calendar.current.startOfDay(for: .now)
        for dayOffset in 0..<2 {
            let amountDate = defaults?.object(forKey: "date") as? Date
            
            let entryDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate)!
            let entryExpenses = Calendar.current.isDate(amountDate ?? .distantPast, inSameDayAs: entryDate) ? (defaults?.double(forKey: "amount") ?? 0) : 0
            let entryCurrency: String = defaults?.string(forKey: "defaultCurrency") ?? Locale.current.currencySymbol ?? "USD"
            
            logger.debug("Generating entry... Date: \(entryDate), expenses: \(entryExpenses), currency: \(entryCurrency)")
            
            let entry = SumEntry(date: entryDate, expenses: entryExpenses, currency: entryCurrency)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SumEntry: TimelineEntry {
    let date: Date
    let expenses: Double
    let currency: String
}
