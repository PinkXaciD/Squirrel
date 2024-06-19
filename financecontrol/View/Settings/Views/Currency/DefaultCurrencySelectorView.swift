//
//  DefaultCurrencySelector.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/19.
//

import SwiftUI

struct DefaultCurrencySelectorView: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var cdm: CoreDataModel
    
    @AppStorage(UDKeys.defaultCurrency.rawValue)
    private var defaultCurrency: String = Locale.current.currencyCode ?? "USD"
    @AppStorage(UDKeys.defaultSelectedCurrency.rawValue)
    private var defaultSelectedCurrency: String = UserDefaults.standard.string(forKey: UDKeys.defaultCurrency.rawValue) ?? Locale.current.currencyCode ?? "USD"
    @AppStorage(UDKeys.separateCurrencies.rawValue) 
    private var separateCurrencies: Bool = false
    
    @State
    private var showNavLink: Bool = false
    
    var body: some View {
        List {
            // Picker replaced with this cause of some iOS bug
            ForEach(UserDefaults.standard.getCurrencies().sorted(), id: \.hashValue) { currency in
                Button {
                    setCurrency(currency.code)
                } label: {
                    CurrencyRow(defaultCurrency: $defaultCurrency, currency: currency, selectedText: separateCurrencies ? "Selected as display" : "Selected as default")
                }
                .buttonStyle(.plain)
                .swipeActions(edge: .trailing) {
                    deleteButton(currency)
                }
                .contextMenu {
                    deleteButton(currency)
                }
            }
            
            separateCurrencySection
            
            addNewSection
        }
        .navigationTitle("Currencies")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            trailingToolbar
        }
    }
    
    private var separateCurrencySection: some View {
        Section {
            Toggle("Separate default and display currencies", isOn: $separateCurrencies)
            
            if showNavLink {
                NavigationLink {
                    SelectedCurrencySelectorView()
                } label: {
                    HStack {
                        Text("Default")
                        
                        Spacer()
                        
                        Text(defaultSelectedCurrency)
                            .foregroundColor(.secondary)
                    }
                }
            }
        } footer: {
            Text("You can choose a currency to be selected by default, different from display currency")
        }
        .onChange(of: separateCurrencies) { newValue in
            if !newValue {
                defaultSelectedCurrency = defaultCurrency
            }
            
            withAnimation {
                showNavLink = newValue
            }
        }
        .onAppear {
            withAnimation {
                showNavLink = separateCurrencies
            }
        }
    }
    
    private var addNewSection: some View {
        Section {
            addNewButton
                .labelStyle(.titleOnly)
        }
    }
    
    private var trailingToolbar: ToolbarItemGroup<some View> {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            addNewButton
        }
    }
    
    private var addNewButton: some View {
        NavigationLink {
            AddCurrencyView()
        } label: {
            Label("Add new", systemImage: "plus")
        }
    }
    
    private func deleteButton(_ currency: Currency) -> some View {
        Button(role: .destructive) {
            withAnimation {
                UserDefaults.standard.deleteCurrency(currency)
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
        
        if !separateCurrencies {
            defaultSelectedCurrency = tag
        }
        
        cdm.updateBarChart()
        
        if let defaults = UserDefaults(suiteName: Vars.groupName) {
            defaults.set(tag, forKey: "defaultCurrency")
            cdm.passSpendingsToSumWidget()
        }
    }
}

struct SelectedCurrencySelectorView: View {
    @AppStorage(UDKeys.defaultSelectedCurrency.rawValue) 
    private var defaultSelectedCurrency: String = UserDefaults.standard.string(forKey: UDKeys.defaultCurrency.rawValue) ?? Locale.current.currencyCode ?? "USD"
    @AppStorage(UDKeys.defaultCurrency.rawValue)
    private var defaultCurrency: String = Locale.current.currencyCode ?? "USD"
    @AppStorage(UDKeys.separateCurrencies.rawValue)
    private var separateCurrencies: Bool = false
    
    var body: some View {
        List {
            ForEach(UserDefaults.standard.getCurrencies().sorted(), id: \.hashValue) { currency in
                Button {
                    setDefaultSelectedCurrency(currency)
                } label: {
                    CurrencyRow(defaultCurrency: $defaultSelectedCurrency, currency: currency, selectedText: "Selected as default")
                        .animation(.default.speed(2), value: defaultSelectedCurrency)
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("Default currency")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func setDefaultSelectedCurrency(_ currency: Currency) {
        defaultSelectedCurrency = currency.code
    }
}

struct DefaultCurrencySelector_Previews: PreviewProvider {
    static var previews: some View {
        DefaultCurrencySelectorView()
            .environmentObject(CoreDataModel())
    }
}
