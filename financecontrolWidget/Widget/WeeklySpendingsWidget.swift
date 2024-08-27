//
//  WeeklySpendingsWidget.swift
//  SquirrelWidgetExtension
//
//  Created by PinkXaciD on R 6/07/26.
//

import WidgetKit
import SwiftUI

struct WeeklySpendingsWidget: Widget {
    let kind = "WeeklySpendingsWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeeklySpendingsWidgetProvider()) { entry in
            WeeklySpendingsWidgetView(entry: entry)
        }
        .configurationDisplayName("Weekly expenses")
        .description("Your expenses for this week.")
        .supportedFamilies([.systemMedium, .systemSmall])
    }
}

@available(iOS 16.0, *)
struct WeeklySpendingsAccessoryWidget: Widget {
    let kind = "WeeklySpendingsAccessoryWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeeklySpendingsWidgetProvider()) { entry in
            WeeklySpendingsAccessoryWidgetView(entry: entry)
        }
        .configurationDisplayName("Weekly expenses")
        .description("Your expenses for this week.")
        .supportedFamilies([.accessoryRectangular])
    }
}
