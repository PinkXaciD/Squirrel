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
            Picker("", selection: $currency) {
                ForEach(UserDefaults.standard.getCurrencies().sorted(), id:\.code) { currency in
                    Button {} label: {
                        Text(currency.name ?? currency.code)
                        
                        Text(currency.code)
                    }
                }
            }
            
            Divider()
            
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

struct OtherCurrencySelector: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCurrency: String
    @State private var search: String = ""
    
    let currencyCodes = Dictionary(grouping: Currency.getAll()) {
        ($0.name ?? $0.code).prefix(1).capitalized
    }
    
    var body: some View {
        Group {
            let searchResult = searchFunc()
            
            if !searchResult.isEmpty {
                List {
                    ForEach(Array(searchResult.keys).sorted(), id: \.self) { key in
                        if let content = searchResult[key] {
                            section(key, content)
                        }
                    }
                }
            } else {
                CustomContentUnavailableView.search(search)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background {
                        Color(uiColor: .systemGroupedBackground)
                            .ignoresSafeArea()
                    }
            }
        }
        .navigationTitle("Select currency")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $search, placement: getSearchBarPlacement(), prompt: "Search by name or ISO code")
    }
    
    private func section(_ key: String, _ content: [Currency]) -> some View {
        Section {
            ForEach(content, id: \.id) { currency in
                pickerButton(currency)
            }
        } header: {
            Text(key.capitalized)
        }
    }
    
    private func pickerButton(_ currency: Currency) -> some View {
        Button {
            selectedCurrency = currency.code
            dismiss()
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(currency.name ?? currency.code)
                        .foregroundStyle(.primary)
                    
                    Text(currency.code)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "checkmark")
                    .font(.body.bold())
                    .foregroundColor(.accentColor)
                    .opacity(selectedCurrency == currency.code ? 1 : 0)
            }
            .background {
                Rectangle()
                    .fill(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.001))
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getSearchBarPlacement() -> SearchFieldPlacement {
        if #available(iOS 26.0, *) {
            return .automatic
        }
        
        return .navigationBarDrawer(displayMode: .always)
    }
    
    private func searchFunc() -> [String : [Currency]] {
        let trimmedSearch = search.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedSearch.isEmpty {
            return currencyCodes
        } else {
            let allCurrencies = Currency.getAll().filter { currency in
                currency.code.localizedCaseInsensitiveContains(trimmedSearch) || (currency.name ?? currency.code).localizedCaseInsensitiveContains(trimmedSearch)
            }
            
            return Dictionary(grouping: allCurrencies) { currency in
                (currency.name ?? currency.code).prefix(1).capitalized
            }
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
