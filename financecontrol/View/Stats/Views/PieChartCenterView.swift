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
    @EnvironmentObject
    private var fvm: FiltersViewModel
    @AppStorage(UDKey.defaultCurrency.rawValue)
    var defaultCurrency: String = Locale.current.currencyCode ?? "USD"
    var selectedMonth: Date
    
    let width: CGFloat
    let operationsInMonth: Double
    
    var body: some View {
        VStack(alignment: .center) {
            
            dateText()
                .padding(.top, 5)
                .scaledToFit()
            
            Text(operationsSum(operationsInMonth: operationsInMonth))
                .lineLimit(1)
                .font(.system(size: 30, weight: .semibold, design: .rounded))
                .padding(.horizontal, 6)
                .minimumScaleFactor(0.5)
                .scaledToFit()
            
            Text(defaultCurrency)
                .foregroundColor(Color.secondary)
        }
        .frame(maxWidth: width/1.4)
        .scaledToFit()
        .minimumScaleFactor(0.01)
    }
}

extension CenterChartView {
    internal init(selectedMonth: Date, width: CGFloat, operationsInMonth: Double) {
        self.selectedMonth = selectedMonth
        self.width = width
        self.operationsInMonth = operationsInMonth
    }
    
    @ViewBuilder
    private func dateText() -> some View {
        if fvm.applyFilters {
            Text("Filters applied")
        } else {
            if Calendar.current.isDate(selectedMonth, equalTo: Date(), toGranularity: .year) {
                Text(selectedMonth, format: .dateTime.month(.wide))
            } else {
                Text(selectedMonth, format: .dateTime.month().year())
            }
        }
    }
    
    private func operationsSum(operationsInMonth: Double) -> String {
        return Locale.current.currencyNarrowFormat(operationsInMonth, currency: UserDefaults.defaultCurrency()) ?? "Error"
    }
}
