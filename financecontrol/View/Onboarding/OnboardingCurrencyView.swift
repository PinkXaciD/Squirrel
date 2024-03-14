//
//  OnboardingCurrencyView.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/03/13.
//

import SwiftUI

struct OnboardingCurrencyView: View {
    @Binding var selectedCurrency: String
    @Binding var showOverlay: Bool
    @State private var search: String = ""
    @FocusState private var searchIsFocused: Bool
    
    var currencies: [String] {
        var result = Locale.customCommonISOCurrencyCodes
        result.remove(at: Locale.customCommonISOCurrencyCodes.firstIndex(of: Locale.current.currencyCode ?? "") ?? 0)
        result.sort { first, second in
            let name1 = Locale.current.localizedString(forCurrencyCode: first) ?? first
            let name2 = Locale.current.localizedString(forCurrencyCode: second) ?? second
            return name1 < name2
        }
        
        return result
    }
    
    var body: some View {
        List {
            Section {
                TextField("\(Image(systemName: "magnifyingglass")) Search", text: $search)
                    .font(.headline)
                    .focused($searchIsFocused)
            } header: {
                VStack(alignment: .leading) {
                    Text("Select currency")
                        .font(.system(.largeTitle).bold())
                    
                    Text("You can change default currency or add more later in settings")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .textCase(nil)
                .foregroundColor(.primary)
                .listRowInsets(.init(top: 50, leading: 0, bottom: 20, trailing: 0))
            }
            
            Section {
                getRow(Locale.current.currencyCode ?? "USD")
            }
            
            Section {
                ForEach(searchFunc(), id: \.self) { code in
                    getRow(code)
                }
            } footer: {
                Rectangle()
                    .fill(Color(uiColor: .systemGroupedBackground))
                    .frame(height: 100)
            }
        }
        .onChange(of: searchIsFocused) { value in
            withAnimation {
                showOverlay = !value
            }
        }
    }
    
    private func getRow(_ currencyCode: String) -> some View {
        Button {
            withAnimation {
                selectedCurrency = currencyCode
                searchIsFocused = false
            }
        } label: {
            HStack {
                Text(Locale.current.localizedString(forCurrencyCode: currencyCode) ?? currencyCode)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "checkmark")
                    .font(.body.bold())
                    .foregroundColor(.orange)
                    .opacity(selectedCurrency == currencyCode ? 1 : 0)
            }
        }
    }
    
    private func searchFunc() -> [String] {
        let trimmedSearch = search.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedSearch.isEmpty {
            return currencies
        } else {
            return currencies.filter { $0.localizedStandardContains(trimmedSearch) || (Locale.current.localizedString(forCurrencyCode: $0) ?? "").localizedCaseInsensitiveContains(trimmedSearch) }
        }
    }
}
