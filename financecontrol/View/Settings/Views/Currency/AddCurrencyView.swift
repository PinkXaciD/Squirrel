//
//  AddCurrencyView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/04.
//

import SwiftUI

struct AddCurrencyView: View {
    @EnvironmentObject private var cdm: CoreDataModel
    
    @State private var search: String = ""
    let currencyCodes = Dictionary(grouping: Locale.customCommonISOCurrencyCodes) { code in
        (Locale.current.localizedString(forCurrencyCode: code) ?? code).prefix(1).capitalized
    }
    
    var body: some View {
        Group {
            let searchResult = searchFunc()
            
            List {
                ForEach(Array(searchResult.keys).sorted(), id: \.self) { key in
                    Section {
                        if let currencies = searchResult[key] {
                            let mappedCurrencies = currencies.map { (code: $0, name: Locale.current.localizedString(forCurrencyCode: $0) ?? $0) }
                            
                            ForEach(mappedCurrencies.sorted { $0.name < $1.name }, id: \.code) { currency in
                                NewCurrencyRow(name: currency.name, code: currency.code)
                            }
                        }
                    } header: {
                        Text(key)
                    }
                }
            }
            .overlay {
                if searchResult.isEmpty {
                    if search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        CustomContentUnavailableView("No currencies", imageName: "questionmark", description: "No currencies found. Maybe you added all of them?")
                    } else {
                        CustomContentUnavailableView.search(search.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                }
            }
        }
        .searchable(
            text: $search,
            placement: .navigationBarDrawer(displayMode: .always),
//            placement: .automatic, iOS 26
            prompt: "Currency name or ISO Code"
        )
        .navigationTitle("Add Currency")
    }
    
    private func excludeAdded(_ data: [String]) -> [String] {
        let removeSet: Set<String> = Set(UserDefaults.standard.getRawCurrencies())
        return data.filter { !removeSet.contains($0) }
    }
    
    private func searchFunc() -> [String : [String]] {
        let trimmedSearch = search.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedSearch.isEmpty {
            return currencyCodes
                .mapValues { excludeAdded($0) }
                .filter { !$0.value.isEmpty }
        } else {
            return currencyCodes.mapValues { values in
                excludeAdded(values).filter { value in
                    value.localizedCaseInsensitiveContains(trimmedSearch) || (Locale.current.localizedString(forCurrencyCode: value) ?? "").localizedCaseInsensitiveContains(trimmedSearch)
                }
            }
            .filter { !$0.value.isEmpty }
        }
    }
}

struct AddCurrencyView_Previews {
    static var previews: some View {
        AddCurrencyView()
            .environmentObject(CoreDataModel())
    }
}
