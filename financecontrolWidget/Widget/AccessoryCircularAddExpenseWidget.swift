//
//  AccessoryCircularAddExpenseWidget.swift
//  financecontrolWidgetExtension
//
//  Created by PinkXaciD on R 6/01/13.
//

import WidgetKit
import SwiftUI

@available(iOS 16.0, *)
struct AccessoryCircularAddExpenseWidget: Widget {
    let kind: String = "AccessoryCircularAddExpense"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AddExpenseWidgetProvider()) { entry in
            AccessoryCircularAddExpenseView(entry: entry)
        }
        .configurationDisplayName("Add expense")
        .description("Quickly add expense from lock screen.")
        .supportedFamilies([.accessoryCircular])
    }
}
