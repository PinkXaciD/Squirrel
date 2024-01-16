//
//  RatesView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/09/18.
//

import SwiftUI

struct RatesView: View {
    @EnvironmentObject private var rvm: RatesViewModel
    
    var body: some View {
        List {
            Section {
                ForEach(filteredRates) {
                    $0
                }
            } header: {
                ratesHeader
            }
        }
        .navigationTitle("Rates")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var filteredRates: [RatesRowView] {
        let rates = rvm.rates
        
        return rates
            .filter { Locale.customCommonISOCurrencyCodes.contains($0.key.uppercased()) }
            .map { RatesRowView(code: $0.key.uppercased(), rate: $0.value) }
            .sorted { $0.name < $1.name }
    }
    
    private var ratesHeader: some View {
        HStack {
            Text("Name")
            
            Spacer()
            
            Text("1 USD")
        }
    }
}

struct RatesRowView: View, Identifiable {
    internal init(code: String, rate: Double) {
        self.name = Locale.current.localizedString(forCurrencyCode: code)?.capitalized ?? "Error with: \(code)"
        self.code = code
        self.rate = rate
    }
    
    let name: String
    let code: String
    let rate: Double
    var id: String {
        name
    }
    
    var body: some View {
        HStack {
            Text(name)
            
            Spacer()
            
            Text(rate.formatted(.currency(code: code)))
        }
    }
}

struct RatesView_Previews: PreviewProvider {
    static var previews: some View {
        RatesView()
    }
}
