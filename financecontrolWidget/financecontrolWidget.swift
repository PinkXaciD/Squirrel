//
//  financecontrolWidget.swift
//  financecontrolWidget
//
//  Created by PinkXaciD on R 6/01/05.
//

import WidgetKit
import SwiftUI
import OSLog

struct Provider: TimelineProvider {
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

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        var entries: [SumEntry] = []
        let defaults: UserDefaults? = .init(suiteName: "group.financecontrol")
        let logger: Logger = .init(subsystem: "com.pinkxacid.financecontrol.financecontrolWidget", category: "getTimeline")

        let currentDate = Calendar.current.startOfDay(for: .now)
        for dayOffset in 0 ..< 5 {
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

struct financecontrolSmallSumWidget: Widget {
    let kind: String = "financecontrolSumWidget"
    let currency: String = UserDefaults.standard.string(forKey: "defaultCurrency") ?? "JPY"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TotalSpendingsSmallView(entry: entry)
        }
        .configurationDisplayName("Today's expenses")
        .description("Your expenses for today.")
        .supportedFamilies([.systemSmall])
    }
}
