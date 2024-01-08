//
//  financecontrolWidget.swift
//  financecontrolWidget
//
//  Created by PinkXaciD on R 6/01/05.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), expenses: 100)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), expenses: 100)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for dayOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, expenses: 100)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let expenses: Double
}

struct financecontrolWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Time:")
            Text(entry.date, style: .time)
        }
    }
}

struct financecontrolWidget: Widget {
    let kind: String = "financecontrolWidget"
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

struct TotalSpendingsSmallView: View {
    let entry: SimpleEntry
    let currency: String = UserDefaults(suiteName: "group.financecontrol")?.string(forKey: "defaultCurrency") ?? "USD"
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text("Today's expenses")
                    .font(.body)
                    .opacity(0.9)
                
                Text(entry.expenses.formatted(.currency(code: currency)))
                    .font(.system(.largeTitle, design: .rounded).bold())
                    .minimumScaleFactor(0.5)
                
                Spacer()
            }
            
            Spacer()
        }
        .foregroundColor(.orange)
        .containerBackground(gradient, for: .widget)
    }
    
    private var gradient: LinearGradient {
        let upperColor: Color = .init(uiColor: .tertiarySystemBackground)
        let bottomColor: Color = .init(uiColor: .systemBackground)
        
        return LinearGradient(
            colors: [upperColor, bottomColor],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

#Preview(as: .systemSmall) {
    financecontrolWidget()
} timeline: {
    SimpleEntry(date: .now, expenses: 1000)
}
