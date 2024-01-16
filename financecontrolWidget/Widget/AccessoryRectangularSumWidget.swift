//
//  AccessoryRectangularSumWidget.swift
//  financecontrolWidgetExtension
//
//  Created by PinkXaciD on R 6/01/12.
//

import WidgetKit
import SwiftUI

@available(iOS 16.0, *)
struct AccessoryRectangularSumWidget: Widget {
    let kind: String = "AccessoryRectangularSumWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SumWidgetTimelineProvider()) { entry in
            AccessoryRectangularSumWidgetView(entry: entry)
        }
        .configurationDisplayName("Today's expenses")
        .description("Your expenses for today.")
        .supportedFamilies([.accessoryRectangular])
    }
}
