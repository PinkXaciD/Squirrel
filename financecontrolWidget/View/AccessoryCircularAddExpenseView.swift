//
//  AccessoryCircularAddExpenseView.swift
//  financecontrolWidgetExtension
//
//  Created by PinkXaciD on R 6/01/13.
//

import SwiftUI
import WidgetKit

@available(iOS 16.0, *)
struct AccessoryCircularAddExpenseView: View {
    let entry: AddExpenseEntry
    
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
                .opacity(0.25)
            
            entry.image()
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(10)
        }
        .privacySensitive(false)
        .containerBackground(.clear, for: .widget)
        .widgetURL(entry.url)
    }
    
    @available(iOS, introduced: 16, deprecated: 17, message: "On newer platforms use getNewWidget()")
    private func getOldWidget() -> some View {
        ZStack {
            Circle()
                .opacity(0.25)
            
            entry.image()
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(10)
        }
        .privacySensitive(false)
        .widgetURL(entry.url)
    }
}

#if DEBUG
struct AccessoryCircularAddExpenceViewPreviews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 16.0, *){
            AccessoryCircularAddExpenseView(
                entry: .init(
                    date: .init(),
                    image: { Image(.squirrelLogo) },
                    url: URL(string:"financecontrol://addExpense")
                )
            )
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
        }
    }
}
#endif
