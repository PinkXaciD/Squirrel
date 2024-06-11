//
//  financecontrolSmallSumWidget.swift
//  financecontrolWidget
//
//  Created by PinkXaciD on R 6/01/05.
//

import WidgetKit
import SwiftUI

struct SmallSumWidget: Widget {
    let kind: String = "SmallSumWidget"
    let currency: String = UserDefaults.standard.string(forKey: UDKeys.defaultCurrency.rawValue) ?? "JPY"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SumWidgetTimelineProvider()) { entry in
            SmallSumWidgetView(entry: entry)
        }
        .configurationDisplayName("Today's expenses")
        .description("Your expenses for today.")
        .supportedFamilies([.systemSmall])
    }
}
