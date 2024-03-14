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
                    Section(header: Text("Tap to add")) {
                        ForEach(0..<searchResult.count, id: \.self) { index in
                            
                            let currency = searchResult[index]
                            
                            NewCurrencyRow(name: currency.value, code: currency.key)
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
    
    private func searchFunc() -> [Dictionary<String, String>.Element] {
        if search.isEmpty {
            return currenciesFull
        } else {
            return currenciesFull.filter {
                $0.value.localizedCaseInsensitiveContains(search) || $0.key.localizedCaseInsensitiveContains(search)
            }
        }
    }
}

struct AddCurrencyView_Previews {
    static var previews: some View {
        AddCurrencyView()
            .environmentObject(CoreDataModel())
    }
}
