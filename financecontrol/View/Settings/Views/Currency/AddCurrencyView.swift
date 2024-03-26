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
    
    var currencies = Locale.customCommonISOCurrencyCodes
    
    var currenciesFull: [(key: String, value: String)] {
        let currenciesFiltered = excludeAdded()
        var currenciesFull: [String:String] {
            var currenciesFull = [String:String]()
            for currency in currenciesFiltered {
                currenciesFull.updateValue(Locale.current.localizedString(forCurrencyCode: currency) ?? "Error", forKey: currency)
            }
            return currenciesFull
        }
        
        let sorted = currenciesFull.sorted {
            $0.value < $1.value
        }
        
        return sorted
    }
    
    var body: some View {
        Group {
            let searchResult = searchFunc()
            
            if !searchResult.isEmpty {
                List {
//                    Section(header: Text("Tap to add")) {
//                        ForEach(0..<searchResult.count, id: \.self) { index in
//                            
//                            let currency = searchResult[index]
//                            
//                            NewCurrencyRow(name: currency.value, code: currency.key)
//                        }
//                    }
                    ForEach(Array(searchResult.keys).sorted(), id: \.self) { key in
                        Section {
                            if let currencies = searchResult[key] {
                                ForEach(currencies.sorted { (Locale.current.localizedString(forCurrencyCode: $0) ?? "") < (Locale.current.localizedString(forCurrencyCode: $1) ?? "") }, id: \.self) { currency in
                                    NewCurrencyRow(name: Locale.current.localizedString(forCurrencyCode: currency) ?? "Error", code: currency)
                                }
                            }
                        } header: {
                            Text(key)
                        }
                    }
                }
            } else {
                CustomContentUnavailableView("No results for \"\(search)\"", imageName: "magnifyingglass", description: "Try another search.")
            }
        }
        .searchable(
            text: $search,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Currency name or ISO Code"
        )
        .navigationTitle("Add Currency")
    }
    
    private func excludeAdded() -> [String] {
        var removeSet: Set<String> = Set()
        for entity in cdm.savedCurrencies {
            if let tag = entity.tag {
                removeSet.insert(tag)
            }
        }
        return currencies.filter { !removeSet.contains($0) }
    }
    
    private func searchFunc() -> [String : [String]] {
        let dict = Dictionary(
            grouping: Locale.customCommonISOCurrencyCodes.filter { !cdm.savedCurrencies.compactMap { $0.tag }.contains($0) },
            by: { (Locale.current.localizedString(forCurrencyCode: $0) ?? "Error").prefix(1).capitalized }
        )
        
        if search.isEmpty {
            return dict
        } else {
            let trimmedSearch = search.trimmingCharacters(in: .whitespacesAndNewlines)
            
            return dict.mapValues { values in
                values.filter { value in
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
