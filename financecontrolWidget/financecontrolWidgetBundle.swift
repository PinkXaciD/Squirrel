//
//  financecontrolWidgetBundle.swift
//  financecontrolWidget
//
//  Created by PinkXaciD on R 6/01/05.
//

import WidgetKit
import SwiftUI

@main
struct financecontrolWidgetBundle: WidgetBundle {
    
    @WidgetBundleBuilder
    var body: some Widget {
        getWidgets()
    }
    
    private func getWidgets() -> some Widget {
        if #available(iOS 16.0, *) {
            return WidgetBundleBuilder.buildBlock(
//                SmallSumWidget(),
                WeeklySpendingsAccessoryWidget(),
                AccessorySumWidget(),
                AccessoryCircularAddExpenseWidget(),
                WeeklySpendingsWidget()
            )
        } else {
            return WidgetBundleBuilder.buildBlock(
//                SmallSumWidget(),
                WeeklySpendingsWidget()
            )
        }
    }
}
