//
//  DefaultCurrencySelector.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/19.
//

import SwiftUI

struct DefaultCurrencySelectorView: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var cdm: CoreDataModel
    
    @AppStorage(UDKeys.defaultCurrency) var defaultCurrency: String = Locale.current.currencyCode ?? "USD"
    
    var body: some View {
        let currencies = cdm.savedCurrencies.sorted {
            guard
                let firstTag = $0.tag,
                let secondTag = $1.tag,
                let firstName = Locale.current.localizedString(forCurrencyCode: firstTag)?.capitalized,
                let secondName = Locale.current.localizedString(forCurrencyCode: secondTag)?.capitalized
            else {
                return false
            }
            
            return firstName < secondName
        }
        
        List {
            // Picker replaced with this cause of some iOS bug
            ForEach(currencies) { currency in
                if let tag = currency.tag {
                    Button {
                        setCurrency(tag)
                    } label: {
                        CurrencyRow(code: tag, currency: currency)
                            .padding(.vertical, 1)
                    }
                    .buttonStyle(.plain)
                } else {
                    Text("Error")
                }
            }
            
            addNewSection
        }
        .navigationTitle("Currencies")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            trailingToolbar
        }
    }
    
    private var addNewSection: some View {
        Section {
            NavigationLink {
                AddCurrencyView()
            } label: {
                Text("Add new")
            }
        }
    }
    
    private var trailingToolbar: ToolbarItem<Void, some View> {
        ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink {
                AddCurrencyView()
            } label: {
                Label("Add new currency", systemImage: "plus")
            }
        }
    }
    
    private func setCurrency(_ tag: String) {
        withAnimation {
            defaultCurrency = tag
        }
        
        if let defaults = UserDefaults(suiteName: Vars.groupName) {
            defaults.set(tag, forKey: "defaultCurrency")
            cdm.passSpendingsToSumWidget()
        }
    }
}

struct DefaultCurrencySelector_Previews: PreviewProvider {
    static var previews: some View {
        DefaultCurrencySelectorView()
            .environmentObject(CoreDataModel())
    }
}
