//
//  DefaultCurrencySelector.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/19.
//

import SwiftUI

struct DefaultCurrencySelector: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var cdm: CoreDataModel
    
    @AppStorage("defaultCurrency") var defaultCurrency: String = "USD"
    
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
//            Picker("Currency selection", selection: $defaultCurrency) {
//                ForEach(currencies) { currency in
//                    if let tag = currency.tag {
//                        CurrencyRow(tag: tag, currency: currency)
//                            .tag(tag)
//                            .padding(.vertical, 1)
//                    } else {
//                        Text("Error")
//                    }
//                }
//            }
//            .pickerStyle(.inline)
//            .labelsHidden()
            
            ForEach(currencies) { currency in
                if let tag = currency.tag {
                    CurrencyRow(tag: tag, currency: currency)
                        .padding(.vertical, 1)
                        .onTapGesture {
                            withAnimation {
                                defaultCurrency = tag
                            }
                            
                            if let defaults = UserDefaults(suiteName: "group.financecontrol") {
                                defaults.set(tag, forKey: "defaultCurrency")
                            }
                        }
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
                Label("Add New currency", systemImage: "plus")
            }
        }
    }
}

struct DefaultCurrencySelector_Previews: PreviewProvider {
    static var previews: some View {
        DefaultCurrencySelector()
            .environmentObject(CoreDataModel())
    }
}
