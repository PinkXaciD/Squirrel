//
//  AddCurrencyView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/04.
//

import SwiftUI

struct AddCurrencyView: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var vm: CoreDataViewModel
    
    @State private var search: String = ""
    
    var currencies = Locale.commonISOCurrencyCodes
    
    var currenciesFull: [Dictionary<String, String>.Element] {
        let currenciesFiltered = excludeAdded()
        var currenciesFull = [String:String]()
        for currency in currenciesFiltered {
            currenciesFull.updateValue(Locale.current.localizedString(forCurrencyCode: currency) ?? "Error", forKey: currency)
        }
        let sorted = currenciesFull.sorted {
            $0.value < $1.value
        }
        return sorted
    }
    
    var body: some View {
        List {
            let searchResult = searchFunc()
            ForEach(0..<searchResult.count, id: \.self) { index in
                HStack {
                    Text(searchResult[index].value.capitalized)
                    Rectangle()
                        .foregroundColor(CustomColor.background)
                }
                .onTapGesture {
                    vm.addCurrency(name: searchResult[index].value, tag: searchResult[index].key)
                    dismiss()
                }
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
        for entity in vm.savedCurrencies {
            removeSet.insert(entity.tag!)
        }
        return currencies.filter { !removeSet.contains($0) }
    }
    
    private func searchFunc() -> [Dictionary<String, String>.Element] {
        if search == "" {
            return currenciesFull
        }
        if !currencies.contains(search.uppercased()) {
            return currenciesFull.filter {
                $0.value.localizedCaseInsensitiveContains(search)
            }
        }
        return currenciesFull.filter {
            $0.key.localizedCaseInsensitiveContains(search)
        }
    }
}

struct AddCurrencyView_Previews {
    static var previews: some View {
        AddCurrencyView()
            .environmentObject(CoreDataViewModel())
    }
}
