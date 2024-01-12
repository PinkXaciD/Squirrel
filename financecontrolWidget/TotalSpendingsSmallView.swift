//
//  TotalSpendingsSmallView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 6/01/11.
//

import SwiftUI

#if DEBUG
import WidgetKit
#endif

struct TotalSpendingsSmallView: View {
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
        let lightColors: [Color] = [.white, .init(uiColor: .systemGray5)]
        let darkColors: [Color] = [.init(uiColor: .systemGray4), .init(uiColor: .systemGray6)]
        let colors = colorScheme == .light ? lightColors : darkColors
        
        return LinearGradient(
            colors: colors,
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    @available(iOS, introduced: 17)
    private func getNewWidget() -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text("Today's expenses")
                    .font(.body)
                    .opacity(0.9)
                
                Text(entry.expenses.formatted(.currency(code: entry.currency)))
                    .font(.system(.largeTitle, design: .rounded).bold())
                    .minimumScaleFactor(0.5)
                    .privacySensitive()
                
                Spacer()
            }
            
            Spacer()
        }
        .foregroundColor(.primary)
        .containerBackground(gradient, for: .widget)
    }
    
    @available(iOS, introduced: 14.0, deprecated: 17.0)
    private func getOldWidget() -> some View {
        ZStack {
            gradient
            
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Today's expenses")
                        .font(.body)
                        .opacity(0.9)
                    
                    Text(entry.expenses.formatted(.currency(code: entry.currency)))
                        .font(.system(.largeTitle, design: .rounded).bold())
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
        TotalSpendingsSmallView(entry: .init(date: .now, expenses: 100, currency: "JPY"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
#endif
