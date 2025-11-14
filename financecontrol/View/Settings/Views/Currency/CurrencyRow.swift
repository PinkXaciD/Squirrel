//
//  CurrencySelectorRow.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/10/15.
//

import SwiftUI

struct CurrencyRow: View {
    @EnvironmentObject private var cdm: CoreDataModel
    @EnvironmentObject private var rvm: RatesViewModel
    @Binding var defaultCurrency: String
    
    let currency: Currency
    let selectedText: LocalizedStringKey
    
    var body: some View {
        ZStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(currency.name ?? "Error")
                    
                    getRateRepresentation()
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if defaultCurrency == currency.code {
                    Image(systemName: "checkmark")
                        .font(.body.bold())
                        .foregroundColor(.accentColor)
                }
            }
        }
        .background {
            Rectangle()
                .foregroundColor(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.001))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.vertical, 1) /// Strange behavior without padding
        .normalizePadding()
    }
    
    private func getRateRepresentation() -> Text {
        guard currency.code != defaultCurrency else {
            return Text(selectedText)
        }
        
        guard
            let rate = rvm.rates[currency.code],
            let defaultRate = rvm.rates[defaultCurrency]
        else {
            return Text("No up to date exchange rate found")
        }
        
        func format1(_ code: String) -> String {
            return 1.formatted(.currency(code: code).precision(.fractionLength(0)).presentation(.isoCode))
        }
        
        if ((1 / rate) * defaultRate) > 1 {
            return Text("\(format1(currency.code)) = \(((1 / rate) * defaultRate).formatted(.currency(code: defaultCurrency).presentation(.isoCode)))")
        } else {
            return Text("\(format1(defaultCurrency)) = \(((1 / defaultRate) * rate).formatted(.currency(code: currency.code).presentation(.isoCode)))")
        }
    }
}

//#Preview {
//    CurrencyRow()
//}
