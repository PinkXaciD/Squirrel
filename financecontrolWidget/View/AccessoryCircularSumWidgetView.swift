//
//  AccessoryCircularSumWidgetView.swift
//  financecontrolWidgetExtension
//
//  Created by PinkXaciD on R 6/01/25.
//

import SwiftUI
import WidgetKit

@available(iOS 16.0, *)
struct AccessoryCircularSumWidgetView: View {
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
        ZStack(alignment: .center) {
            Circle()
                .fill(Material.regular)
            
            VStack(spacing: 0) {
                Text(entry.currency)
                    .font(.footnote)
                
                Text(entry.expenses.formatted(.number.notation(.compactName)))
                    .font(.system(.title, design: .rounded).bold())
                    .minimumScaleFactor(0.5)
                    .scaledToFit()
                    .padding(.horizontal, 10)
            }
            .privacySensitive()
        }
        .containerBackground(.clear, for: .widget)
    }
    
    @available(iOS, introduced: 16, deprecated: 17, message: "On newer platforms use getNewWidget()")
    private func getOldWidget() -> some View {
        ZStack(alignment: .center) {
            Circle()
                .fill(Material.regular)
            
            VStack(spacing: 0.5) {
                Text(entry.currency)
                    .font(.footnote)
                
                Text(entry.expenses.formatted(.number.notation(.compactName)))
                    .font(.system(.title, design: .rounded).bold())
                    .minimumScaleFactor(0.5)
                    .scaledToFit()
                    .padding(.horizontal, 6)
            }
            .privacySensitive()
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
struct AccessoryCircularSumWidgetViewPreviews: PreviewProvider {
    static var previews: some View {
        AccessoryCircularSumWidgetView(
            entry: .init(
                date: .init(),
                expenses: 122,
                currency: "JPY"
            )
        )
        .previewContext(WidgetPreviewContext(family: .accessoryCircular))
        .previewDisplayName("Accessory Circular Sum Widget")
    }
}
#endif
