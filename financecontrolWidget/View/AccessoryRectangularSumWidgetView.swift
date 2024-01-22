//
//  AccessoryRectangularSumWidgetView.swift
//  financecontrolWidgetExtension
//
//  Created by PinkXaciD on R 6/01/12.
//

import WidgetKit
import SwiftUI

@available(iOS 16.0, *)
struct AccessoryRectangularSumWidgetView: View {
    let entry: SumEntry
    
    var body: some View {
        if #available(iOS 17, *) {
            getNewWidget()
        } else {
            getOldWidget()
        }
    }
    
    @available(iOS, introduced: 17)
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
    
    @available(iOS, introduced: 16, deprecated: 17)
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
struct AccessoryRectangularSumWidgetPreview: PreviewProvider {
    static var previews: some View {
        if #available(iOS 16.0, *) {
            AccessoryRectangularSumWidgetView(entry: .init(date: .now, expenses: 1200, currency: "JPY"))
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
        }
    }
}
#endif
