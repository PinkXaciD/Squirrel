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
    
    private func format(_ number: Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumFractionDigits = 0
        
        if number >= 1000000000 {
            let preResult = numberFormatter.string(from: round(number / 10000000)/100 as NSNumber) ?? "Error"
            return "\(preResult)B"
        } else if number >= 1000000 {
            let preResult = numberFormatter.string(from: round(number / 10000)/100 as NSNumber) ?? "Error"
            return "\(preResult)M"
        } else if number >= 1000 {
            let preResult = numberFormatter.string(from: round(number / 10)/100 as NSNumber) ?? "Error"
            return "\(preResult)K"
        }
        
        return numberFormatter.string(from: number as NSNumber) ?? "Error"
    }
    
    @available(iOS 17.0, *)
    private func getNewWidget() -> some View {
        ZStack(alignment: .center) {
            Circle()
                .fill(Material.regular)
            
            VStack(spacing: 0) {
                Text(entry.currency)
                    .font(.footnote)
                
                Text(format(entry.expenses))
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
                
                Text(format(entry.expenses))
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
                expenses: 100,
                currency: "JPY"
            )
        )
        .previewContext(WidgetPreviewContext(family: .accessoryCircular))
        .previewDisplayName("Accessory Circular Sum Widget")
    }
}
#endif
