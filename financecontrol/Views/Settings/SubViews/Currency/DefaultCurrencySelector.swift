//
//  DefaultCurrencySelector.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/19.
//

import SwiftUI

struct DefaultCurrencySelector: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var vm: CoreDataViewModel
    
    @AppStorage("defaultCurrency") var defaultCurrency: String = "USD"
    
    var body: some View {
        let currencies = vm.savedCurrencies
        
        List {
            Picker("Currency selection", selection: $defaultCurrency) {
                ForEach(currencies) { currency in
                    if let name = currency.name?.capitalized, let tag = currency.tag {
                        CurrencyRow(name: name, tag: tag, currency: currency).tag(tag)
                            .padding(.vertical, 1)
                    } else {
                        Text("Error")
                    }
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
            
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
                Text("Add New")
            }
        }
    }
    
    private var trailingToolbar: ToolbarItem<Void, some View> {
        ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink {
                AddCurrencyView()
            } label: {
                Label("Add New currency", systemImage: "plus")
            }
        }
    }
}

struct DefaultCurrencySelector_Previews: PreviewProvider {
    static var previews: some View {
        DefaultCurrencySelector()
            .environmentObject(CoreDataViewModel())
    }
}
