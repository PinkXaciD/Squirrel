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
    var favorites: Bool
    var spacer: Bool = true
    
    var body: some View {
        let savedCurrencies = vm.savedCurrencies
        
        if favorites {
            Menu {
                Picker("Currency selection", selection: $currency) {
                    ForEach(savedCurrencies) { currency in
                        if currency.isFavorite {
                            Text(currency.name!).tag(currency.tag!)
                        }
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
                
                Menu {
                    Picker("Currency selection", selection: $currency) {
                        ForEach(savedCurrencies) { currency in
                            Text(currency.name!).tag(currency.tag!)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } label: {
                    Text("Other")
                }
            } label: {
                Spacer()
                Text(currency)
            }
        } else {
            Menu {
                Picker("Currency selection", selection: $currency) {
                    ForEach(savedCurrencies) { currency in
                        Text(currency.name!).tag(currency.tag!)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            } label: {
                if spacer {
                    Spacer()
                }
                Text(currency)
            }
        }
    }
}

struct CurrencySelector_Previews: PreviewProvider {
    static var previews: some View {
        @State var currency: String = "USD"
        Menu {
            CurrencySelector(currency: $currency, favorites: false)
        } label: {
            Text(currency)
        }
    }
}
