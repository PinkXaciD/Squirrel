//
//  OnboardingCurrencyView.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/03/13.
//

import SwiftUI

struct OnboardingCurrencyView: View {
    @Binding var showOverlay: Bool
    @Binding var selectedCurrency: String
    @State private var search: String = ""
    @State private var showButton: Bool = false
    @FocusState private var searchIsFocused: Bool
    
    var currencies: [String] {
        var result = Locale.customCommonISOCurrencyCodes
        result.sort { first, second in
            let name1 = Locale.current.localizedString(forCurrencyCode: first) ?? first
            let name2 = Locale.current.localizedString(forCurrencyCode: second) ?? second
            return name1 < name2
        }
        
        return result
    }
    
    var body: some View {
        List {
            searchSection
            
            recommendedSection
            
            currenciesSection
        }
        .onChange(of: search) { value in
            if value.isEmpty {
                showButton = false
            } else {
                showButton = true
            }
        }
        .onChange(of: searchIsFocused) { value in
            withAnimation {
                showOverlay = !value
            }
        }
    }
    
    private var searchSection: some View {
        Section {
            HStack(spacing: 5) {
                Image(systemName: "magnifyingglass")
                    .font(.body.bold())
                    .foregroundColor(.secondary.opacity(0.5))
                    .animation(.default, value: showButton)
                
                TextField("Search", text: $search)
                    .focused($searchIsFocused)
                
                Button {
                    search = ""
                    withAnimation {
                        searchIsFocused = false
                    }
                } label: {
                    Label("Cancel", systemImage: "xmark.circle.fill")
                        .labelStyle(.iconOnly)
                        .font(.body)
                        .foregroundColor(.secondary.opacity(0.5))
                }
                .opacity(showButton ? 1 : 0)
                .offset(x: showButton ? 0 : 20, y: 0)
                .foregroundColor(.secondary)
                .disabled(!showButton)
                .animation(.default, value: showButton)
            }
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
    }
    
    private var recommendedSection: some View {
        Section {
            getRow(UserDefaults.standard.string(forKey: UDKeys.defaultCurrency) ?? Locale.current.currencyCode ?? "USD")
        } header: {
            Text("Recommended")
        }
    }
    
    private var currenciesSection: some View {
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

#if DEBUG
struct OnboardingCurrencyViewPreviews: PreviewProvider {
    static var previews: some View {
        OnboardingPreview()
    }
}

fileprivate struct OnboardingPreview: View {
    @State var showSheet: Bool = true
    
    var body: some View {
        NavigationView {
            Button {
                showSheet.toggle()
            } label: {
                Rectangle()
                    .foregroundColor(.secondary)
            }
        }
        .sheet(isPresented: $showSheet) {
            OnboardingView()
                .environmentObject(CoreDataModel())
                .accentColor(.orange)
        }
    }
}
#endif
