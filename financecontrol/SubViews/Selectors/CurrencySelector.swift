//
//  CurrencySelector.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/06/27.
//

import SwiftUI

struct CurrencySelector: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var vm: CoreDataViewModel
    
    @Binding var currency: String
    var showFavorites: Bool
    var spacer: Bool = true
    
    var body: some View {
        if showFavorites {
            Menu {
                CurrencyPicker(selectedCurrency: $currency, onlyFavorites: true)
                
                Menu {
                    CurrencyPicker(selectedCurrency: $currency, onlyFavorites: false)
                } label: {
                    Text("Other")
                }
            } label: {
                Spacer()
                Text(currency)
            }
        } else {
            Menu {
                CurrencyPicker(selectedCurrency: $currency, onlyFavorites: false)
            } label: {
                if spacer {
                    Spacer()
                }
                Text(currency)
            }
        }
    }
}

struct CurrencyPicker: View {
    
    @EnvironmentObject private var vm: CoreDataViewModel
    
    @Binding var selectedCurrency: String
    let onlyFavorites: Bool
    
    var body: some View {
        let currencies = onlyFavorites ? vm.savedCurrencies.filter({ $0.isFavorite }) : vm.savedCurrencies
        
        Picker("Select currency", selection: $selectedCurrency) {
            ForEach(currencies) { currency in
                if let name = currency.name, let tag = currency.tag {
                    Text(name).tag(tag)
                }
            }
        }
        .pickerStyle(.inline)
        .labelsHidden()
    }
}

struct CurrencySelector_Previews: PreviewProvider {
    static var previews: some View {
        @State var currency: String = "USD"
        Menu {
            CurrencySelector(currency: $currency, showFavorites: false)
        } label: {
            Text(currency)
        }
    }
}
