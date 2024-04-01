//
//  CurrencySelector.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/06/27.
//

import SwiftUI

struct CurrencySelector: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var cdm: CoreDataModel
    @State private var showAllCurrencies: Bool = false
    
    @Binding var currency: String
    var spacer: Bool = true
    
    var body: some View {
        Menu {
            CurrencyPicker(selectedCurrency: $currency)
            
            Section {
                otherButton
            }
        } label: {
            if spacer {
                Spacer()
            }
            
            Text(currency)
        }
        .background {
            NavigationLink(isActive: $showAllCurrencies) {
                OtherCurrencySelector(selectedCurrency: $currency)
            } label: {
                EmptyView()
            }
            .disabled(true)
            .opacity(0)
        }
    }
    
    private var otherButton: some View {
        Button {
            showAllCurrencies.toggle()
        } label: {
            HStack {
                Text("Other")
                Spacer()
                Image(systemName: "chevron.forward")
            }
        }
    }
}

struct CurrencyPicker: View {
    
    @EnvironmentObject private var cdm: CoreDataModel
    
    @Binding var selectedCurrency: String
    
    var body: some View {
        let currencies = UserDefaults.standard.getCurrencies()
        
        Picker("Select currency", selection: $selectedCurrency) {
            ForEach(currencies.sorted(), id: \.hashValue) { currency in
                Text(currency.name ?? currency.code)
                    .tag(currency.code)
            }
        }
        .pickerStyle(.inline)
        .labelsHidden()
    }
}

struct OtherCurrencySelector: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCurrency: String
    @State private var search: String = ""
    
    let currencyCodes = Dictionary(grouping: Locale.customCommonISOCurrencyCodes) {
        (Locale.current.localizedString(forCurrencyCode: $0) ?? $0).prefix(1).capitalized
    }
    
    var body: some View {
        Group {
            let searchResult = searchFunc()
            
            if !searchResult.isEmpty {
                List {
                    ForEach(Array(searchResult.keys).sorted(), id: \.self) { key in
                        Section {
                            if let currencies = searchResult[key] {
                                let mappedCurrencies = currencies.map { (code: $0, name: Locale.current.localizedString(forCurrencyCode: $0) ?? $0) }
                                ForEach(mappedCurrencies.sorted { $0.name < $1.name }, id: \.code) { currency in
                                    Button {
                                        selectedCurrency = currency.code
                                        dismiss()
                                    } label: {
                                        HStack {
                                            Text(currency.name)
                                            
                                            Spacer()
                                            
                                            Image(systemName: "checkmark")
                                                .font(.body.bold())
                                                .foregroundColor(.accentColor)
                                                .opacity(selectedCurrency == currency.code ? 1 : 0)
                                        }
                                        .background {
                                            Rectangle()
                                                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                                                .frame(maxWidth: .infinity)
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        } header: {
                            Text(key.capitalized)
                        }
                    }
                }
            } else {
                CustomContentUnavailableView.search(search)
            }
        }
        .navigationTitle("Select currency")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $search, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search by name or ISO code")
    }
    
    private func searchFunc() -> [String : [String]] {
        if search.isEmpty {
            return currencyCodes
        } else {
            let trimmedSearch = search.trimmingCharacters(in: .whitespacesAndNewlines)
            
            return currencyCodes.mapValues { values in
                values.filter { value in
                    value.localizedCaseInsensitiveContains(trimmedSearch) || (Locale.current.localizedString(forCurrencyCode: value) ?? "").localizedCaseInsensitiveContains(trimmedSearch)
                }
            }
            .filter { !$0.value.isEmpty }
        }
    }
}

fileprivate struct Preview: View {
    @State var currency: String = "USD"
    
    var body: some View {
        NavigationView {
            CurrencySelector(currency: $currency, spacer: false)
                .environmentObject(CoreDataModel())
        }
    }
}

struct CurrencySelector_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
    }
}
