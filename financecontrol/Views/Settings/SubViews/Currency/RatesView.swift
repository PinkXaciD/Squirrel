//
//  RatesView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/09/18.
//

import SwiftUI

struct RatesView: View {
    @StateObject private var rvm: RatesViewModel = .init()
    
    private var filteredRates: [(String, Double)] {
        let rates = rvm.rates
        
        return rates
            .filter { Locale.customCommonISOCurrencyCodes.contains($0.key.uppercased()) }
            .sorted { $0.key < $1.key }
            .map { ($0.key.uppercased(), $0.value) }
    }
    
    var body: some View {
        List {
            Section {
                ForEach(filteredRates, id: \.0) { key, value in
                    RatesRowView(code: key, rate: value)
                }
            } header: {
                RatesHeaderView()
            }
        }
        .navigationTitle("Rates")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RatesRowView: View {
    let code: String
    let rate: Double
    
    var body: some View {
        HStack {
            Text(Locale.current.localizedString(forCurrencyCode: code) ?? "Error")
            
            Spacer()
            
            Text(String(rate).currencyFormat)
        }
    }
}

struct RatesHeaderView: View {
    var body: some View {
        HStack {
            Text("Name")
            
            Spacer()
            
            Text("1 USD")
        }
    }
}

struct RatesView_Previews: PreviewProvider {
    static var previews: some View {
        RatesView()
    }
}
