//
//  CenterChartView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/11/21.
//

import SwiftUI

struct CenterChartView: View {
    @EnvironmentObject
    private var vm: CoreDataViewModel
    @EnvironmentObject
    private var rvm: RatesViewModel
    @AppStorage("defaultCurrency")
    var defaultCurrency: String = "USD"
    var selectedMonth: Date
    
    let width: CGFloat
    let operationsInMonth: [CategoryEntityLocal]
    
    var body: some View {
        VStack(alignment: .center) {
            
            Text(dateText())
                .padding(.top, 10)
            
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
    internal init(selectedMonth: Date, width: CGFloat, operationsInMonth: [CategoryEntityLocal]) {
        self.selectedMonth = selectedMonth
        self.width = width
        self.operationsInMonth = operationsInMonth
    }
    
    private func dateText() -> String {
        var formatter: DateFormatter {
            let formatter = DateFormatter()
            switch Calendar.current.identifier {
            case .japanese, .buddhist:
                formatter.dateFormat = "MMMM, GGGG y"
            default:
                formatter.dateFormat = "MMMM, y"
            }
            return formatter
        }
        
        return formatter.string(from: selectedMonth)
    }
    
    private func operationsSum(operationsInMonth: [CategoryEntityLocal]) -> String {
        let values = operationsInMonth.map { $0.spendings }
        var result: Double = 0
        for value in values {
            for spending in value {
                if spending.currency == defaultCurrency {
                    result += spending.amount
                } else {
                    result += spending.amountUSD * (rvm.rates[defaultCurrency] ?? 1)
                }
            }
        }
        return result.description.currencyFormat
    }
}
