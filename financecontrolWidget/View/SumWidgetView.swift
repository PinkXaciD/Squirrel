//
//  TotalSpendingsSmallView.swift
//  financecontrolWidget
//
//  Created by PinkXaciD on R 6/01/11.
//

import SwiftUI

#if DEBUG
import WidgetKit
#endif

struct SmallSumWidgetView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let entry: SumEntry
    
    var body: some View {
        if #available(iOS 17, *) {
            getNewWidget()
        } else {
            getOldWidget()
        }
    }
    
    private var gradient: LinearGradient {
        LinearGradient(
            colors: [.upperWidget, .bottomWidget],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private let upperTextOpacity: CGFloat = 0.7
    
    private let bottomTextFont: Font = .system(.largeTitle, design: .rounded).bold()
    
    @available(iOS, introduced: 17, message: "On older systems use getOldWidget()")
    private func getNewWidget() -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text("Today's expenses")
                    .font(.body)
                    .opacity(upperTextOpacity)
                
                Text(entry.expenses.formatted(.currency(code: entry.currency)))
                    .font(bottomTextFont)
                    .minimumScaleFactor(0.5)
                    .privacySensitive()
                
                Spacer()
            }
            
            Spacer()
        }
        .foregroundColor(.primary)
        .containerBackground(gradient, for: .widget)
    }
    
    @available(iOS, introduced: 14.0, deprecated: 17.0, message: "On newer systems use getNewWidget()")
    private func getOldWidget() -> some View {
        ZStack {
            gradient
            
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Today's expenses")
                        .font(.subheadline)
                        .opacity(upperTextOpacity)
                    
                    Text(entry.expenses.formatted(.currency(code: entry.currency)))
                        .font(bottomTextFont)
                        .minimumScaleFactor(0.5)
                        .privacySensitive()
                    
                    Spacer()
                }
                
                Spacer()
            }
            .padding()
        }
        .foregroundColor(.primary)
    }
}

#if DEBUG
struct WidgetPreview: PreviewProvider {
    static var previews: some View {
        SmallSumWidgetView(entry: .init(date: .now, expenses: 1200, currency: "JPY"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
#endif
