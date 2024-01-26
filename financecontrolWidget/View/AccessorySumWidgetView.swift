//
//  AccessoryRectangularSumWidgetView.swift
//  financecontrolWidgetExtension
//
//  Created by PinkXaciD on R 6/01/12.
//

import WidgetKit
import SwiftUI

@available(iOS 16.0, *)
struct AccessorySumWidgetView: View {
    @Environment(\.widgetFamily) private var widgetFamily
    
    let entry: SumEntry
    
    var currencyFormatter: NumberFormatter {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.maximumFractionDigits = 2
        currencyFormatter.minimumFractionDigits = 0
        return currencyFormatter
    }
    
    var body: some View {
        if widgetFamily == .accessoryCircular {
            AccessoryCircularSumWidgetView(entry: entry)
            } else {
            AccessoryRectangularSumWidgetView(entry: entry)
        }
    }
}


#if DEBUG
struct AccessoryRectangularSumWidgetPreview: PreviewProvider {
    static var previews: some View {
        if #available(iOS 16.0, *) {
            AccessorySumWidgetView(entry: .init(date: .now, expenses: 1200, currency: "JPY"))
                .previewContext(WidgetPreviewContext(family: .accessoryCircular))
        }
    }
}
#endif
