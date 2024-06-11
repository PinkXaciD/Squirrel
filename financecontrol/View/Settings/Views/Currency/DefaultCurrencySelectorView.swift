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
    
    @AppStorage(UDKeys.defaultCurrency.rawValue) var defaultCurrency: String = Locale.current.currencyCode ?? "USD"
    
    @State private var currencies: [Currency] = UserDefaults.standard.getCurrencies().sorted()
    
    var body: some View {
        List {
            // Picker replaced with this cause of some iOS bug
            ForEach(currencies, id: \.hashValue) { currency in
                Button {
                    setCurrency(currency.code)
                } label: {
                    CurrencyRow(currency: currency)
                }
                .buttonStyle(.plain)
                .swipeActions(edge: .trailing) {
                    deleteButton(currency)
                }
                .contextMenu {
                    deleteButton(currency)
                }
            }
            
            addNewSection
        }
        // TODO: Remove
        .refreshable {
            withAnimation {
                currencies = UserDefaults.standard.getCurrencies().sorted()
            }
        }
        .navigationTitle("Currencies")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            trailingToolbar
        }
    }
    
    private var addNewSection: some View {
        Section {
            addNewButton
                .labelStyle(.titleOnly)
        }
    }
    
    private var trailingToolbar: ToolbarItem<Void, some View> {
        ToolbarItem(placement: .navigationBarTrailing) {
            addNewButton
        }
    }
    
    private var addNewButton: some View {
        NavigationLink {
            AddCurrencyView(currencies: $currencies)
        } label: {
            Label("Add new", systemImage: "plus")
        }
    }
    
    private func deleteButton(_ currency: Currency) -> some View {
        Button(role: .destructive) {
            withAnimation {
                UserDefaults.standard.deleteCurrency(currency)
                currencies.removeAll { $0 == currency }
                
                if currencies.isEmpty, let localeCurrency = Currency.localeCurrency {
                    currencies.append(localeCurrency)
                }
            }
        } label: {
            Label("Delete", systemImage: "trash.fill")
        }
        .tint(Color.red)
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
