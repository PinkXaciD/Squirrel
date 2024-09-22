//
//  NewCurrencyRow.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/10/16.
//

import SwiftUI

struct NewCurrencyRow: View {
    @EnvironmentObject private var cdm: CoreDataModel
    @EnvironmentObject private var rvm: RatesViewModel
    @Environment(\.dismiss) private var dismiss
    @AppStorage(UDKeys.defaultCurrency.rawValue) private var defaultCurrency: String = Locale.current.currencyCode ?? "USD"
    
    let name: String
    let code: String
    
    var currencyFormatter: NumberFormatter {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.maximumFractionDigits = 2
        currencyFormatter.minimumFractionDigits = 2
        return currencyFormatter
    }
    
    var body: some View {
        Button(action: addCurrency) {
            buttonLabel
        }
        .normalizePadding()
    }
    
    private var buttonLabel: some View {
        VStack(alignment: .leading) {
            Text(name.capitalized)
                .foregroundStyle(.primary)
            
            if rvm.rates[code] != nil, rvm.rates[defaultCurrency] != nil {
                getRateRepresentation()
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                Text("No up to date exchange rate found for \(code)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 1) /// Strange behavior without padding
        .foregroundStyle(Color.primary, Color.secondary)
    }
    
    private func addCurrency() {
        UserDefaults.standard.addCurrency(code)
        dismiss()
    }
    
    private func getRateRepresentation() -> Text {
        guard
            let rate = rvm.rates[code],
            let defaultRate = rvm.rates[defaultCurrency]
        else { return Text("Error") }
        
        func format1(_ code: String) -> String {
            return 1.formatted(.currency(code: code).precision(.fractionLength(0)).presentation(.isoCode))
        }
        
        if ((1 / rate) * defaultRate) > 1 {
            return Text("\(format1(code)) = \(((1 / rate) * defaultRate).formatted(.currency(code: defaultCurrency).presentation(.isoCode)))")
        } else {
            return Text("\(format1(defaultCurrency)) = \(((1 / defaultRate) * rate).formatted(.currency(code: code).presentation(.isoCode)))")
        }
    }
}

//#Preview {
//    NewCurrencyRow()
//}
