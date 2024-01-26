//
//  AccessoryRectangularSumWidgetView.swift
//  financecontrolWidgetExtension
//
//  Created by PinkXaciD on R 6/01/25.
//

import SwiftUI
import WidgetKit

@available(iOS 16.0, *)
struct AccessoryRectangularSumWidgetView: View {
    let entry: SumEntry
    
    var body: some View {
        if #available(iOS 17.0, *) {
            getNewWidget()
        } else {
            getOldWidget()
        }
    }
    
    @available(iOS 17.0, *)
    private func getNewWidget() -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Today's expenses")
                    .privacySensitive(false)
                
                Text(entry.expenses.formatted(.currency(code: entry.currency)))
                    .font(.system(size: 30, design: .rounded).bold())
                    .minimumScaleFactor(0.5)
                    .privacySensitive()
            }
            
            Spacer()
        }
        .containerBackground(.clear, for: .widget)
    }
    
    @available(iOS, introduced: 16, deprecated: 17, message: "On newer platforms use getNewWidget()")
    private func getOldWidget() -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Today's expenses")
                
                Text(entry.expenses.formatted(.currency(code: entry.currency)))
                    .font(.system(size: 30, design: .rounded).bold())
                    .minimumScaleFactor(0.5)
                    .privacySensitive()
            }
            
            Spacer()
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
struct AccessoryRectangularSumWidgetViewPreviews: PreviewProvider {
    static var previews: some View {
        AccessoryRectangularSumWidgetView(
            entry: .init(
                date: .now,
                expenses: 1200,
                currency: "JPY"
            )
        )
        .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
        .previewDisplayName("Accessory Rectangular Sum Widget")
    }
}
#endif
