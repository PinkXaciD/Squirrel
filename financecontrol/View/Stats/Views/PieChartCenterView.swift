//
//  CenterChartView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/11/21.
//

import SwiftUI

struct CenterChartView: View {
    @EnvironmentObject
    private var cdm: CoreDataModel
    @EnvironmentObject
    private var rvm: RatesViewModel
    @AppStorage("defaultCurrency")
    var defaultCurrency: String = Locale.current.currencyCode ?? "USD"
    var selectedMonth: Date
    
    let width: CGFloat
    let operationsInMonth: [TSCategoryEntity]
    
    var body: some View {
        VStack(alignment: .center) {
            
            dateText()
                .padding(.top, 5)
            
            Text(operationsSum(operationsInMonth: operationsInMonth))
                .lineLimit(1)
                .font(.system(size: 30, weight: .semibold, design: .rounded))
            
            Text(defaultCurrency)
                .foregroundColor(Color.secondary)
        }
        .frame(maxWidth: width/1.4)
        .scaledToFit()
        .minimumScaleFactor(0.01)
    }
}

extension CenterChartView {
    internal init(selectedMonth: Date, width: CGFloat, operationsInMonth: [TSCategoryEntity]) {
        self.selectedMonth = selectedMonth
        self.width = width
        self.operationsInMonth = operationsInMonth
    }
    
    private func dateText() -> Text {
        if Calendar.current.isDate(selectedMonth, equalTo: Date(), toGranularity: .year) {
            return Text(selectedMonth, format: .dateTime.month(.wide))
        } else {
            return Text(selectedMonth, format: .dateTime.month().year())
        }
    }
    
    private func operationsSum(operationsInMonth: [TSCategoryEntity]) -> String {
        let values = operationsInMonth.map { $0.spendingsArray }
        var result: Double = 0
        for value in values {
            for spending in value {
                if spending.currency == defaultCurrency {
                    result += spending.amountWithReturns
                } else {
                    result += spending.amountUSDWithReturns * (rvm.rates[defaultCurrency] ?? 1)
                }
            }
        }
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.maximumFractionDigits = 2
        currencyFormatter.minimumFractionDigits = 2
        
        return currencyFormatter.string(from: result as NSNumber) ?? "Error"
    }
}
