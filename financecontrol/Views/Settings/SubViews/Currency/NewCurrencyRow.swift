//
//  NewCurrencyRow.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/10/16.
//

import SwiftUI

struct NewCurrencyRow: View {
    @EnvironmentObject private var vm: CoreDataViewModel
    @EnvironmentObject private var rvm: RatesViewModel
    @Environment(\.dismiss) private var dismiss
    @AppStorage("defaultCurrency") private var defaultCurrency: String = "USD"
    
    let name: String
    let code: String
    
    var body: some View {
        Button(action: addCurrency) {
            buttonLabel
        }
    }
    
    private var buttonLabel: some View {
        VStack(alignment: .leading) {
            Text(name)
                .foregroundStyle(.primary)
            
            if let rate = rvm.rates[code], let defaultRate = rvm.rates[defaultCurrency] {
                Text("1 \(code) = \(String((1 / rate) * defaultRate).currencyFormat) \(defaultCurrency)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                Text("No up to date exchange rate for \(code) found")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .foregroundStyle(Color.primary, Color.secondary)
    }
    
    private func addCurrency() {
        vm.addCurrency(name: name, tag: code)
        dismiss()
    }
}

//#Preview {
//    NewCurrencyRow()
//}
