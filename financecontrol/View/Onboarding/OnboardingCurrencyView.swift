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
    @Namespace var namespace
    
    private var topPadding: CGFloat {
        if #available(iOS 26.0, *) {
            return 50
        }
        
        return 40
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                header
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.top, topPadding)
                
                List {
                    if search.isEmpty {
                        recommendedSection
                    }
                    
                    currenciesSection
                }
                .overlay(alignment: .top) {
                    LinearGradient(
                        colors: [Color(uiColor: .systemGroupedBackground), Color(uiColor: .systemGroupedBackground).opacity(0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(width: geometry.size.width - 20, height: 20)
                }
                .safeAreaInset(edge: .bottom) {
                    EmptyView()
                        .frame(height: 100)
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
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
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 15) {
            OnboardingHeaderView(header: "Select currency", description: "You can change the default currency or add more later in settings")
            
            if #available(iOS 26.0, *) {
                newSearchBar
            } else {
                searchBar
            }
        }
    }
    
    private var searchBar: some View {
        HStack(spacing: 5) {
            Image(systemName: "magnifyingglass")
                .font(.body.bold())
                .foregroundColor(.secondary.opacity(0.5))
                .animation(.default, value: showButton)
            
            TextField("Search", text: $search)
                .focused($searchIsFocused)
                .tint(.orange)
                .accentColor(.orange)
            
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
            .contentShape(.hoverEffect, Circle())
            .hoverEffect()
        }
        .padding(9)
        .padding(.horizontal, 3)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        }
    }
    
    @available(iOS 26.0, *)
    private var newSearchBar: some View {
        GlassEffectContainer {
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "magnifyingglass")
                        .font(.body.bold())
                        .foregroundColor(.secondary.opacity(0.5))
                        .animation(.default, value: showButton)
                    
                    TextField("Search", text: $search)
                        .focused($searchIsFocused)
                        .tint(.orange)
                        .accentColor(.orange)
                }
                .padding(9)
                .padding(.horizontal, 3)
                .background {
                    Capsule()
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                }
                .glassEffect(.regular, in: Capsule())
                .glassEffectID("Bar", in: namespace)
                
                if showButton {
                    Button {
                        search = ""
                        withAnimation {
                            searchIsFocused = false
                        }
                    } label: {
                        Label("Cancel", systemImage: "xmark")
                            .labelStyle(.iconOnly)
                            .font(.title3)
                            .foregroundStyle(Color.primary)
                            .padding(10)
                            .background {
                                Circle()
                                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
                            }
                    }
                    .disabled(!showButton)
                    .contentShape(.hoverEffect, Circle())
                    .hoverEffect()
                    .glassEffect(.regular, in: Circle())
                    .glassEffectID("Button", in: namespace)
                    .glassEffectTransition(.materialize)
                }
            }
        }
        .animation(.default, value: showButton)
    }
    
    private var recommendedSection: some View {
        Section {
            getRow(Locale.current.currencyCode ?? "USD")
        } header: {
            Text("Recommended")
        }
    }
    
    private var currenciesSection: some View {
        let searchResult = searchFunc()
        let sortedKeys = Array(searchResult.keys).sorted(by: <)
        
        return Group {
            if !searchResult.isEmpty {
                ForEach(sortedKeys, id: \.self) { key in
                    Section {
                        ForEach(searchResult[key]?.sorted(by: { Locale.current.localizedString(forCurrencyCode: $0) ?? "" < Locale.current.localizedString(forCurrencyCode: $1) ?? "" }) ?? [], id: \.self) { code in
                            getRow(code)
                        }
                    } header: {
                        Text(key)
                    }
                }
            } else {
                CustomContentUnavailableView.search(search)
                    .listRowInsets(.init(top: 20, leading: 0, bottom: 20, trailing: 0))
                    .frame(maxWidth: .infinity)
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
    
    private func searchFunc() -> [String:[String]] {
        let trimmedSearch = search.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedSearch.isEmpty {
            return Dictionary(grouping: Locale.customCommonISOCurrencyCodes) { code in
                (Locale.current.localizedString(forCurrencyCode: code) ?? code).prefix(1).capitalized
            }
        } else {
            let filtered = Locale.customCommonISOCurrencyCodes.filter { $0.localizedStandardContains(trimmedSearch) || (Locale.current.localizedString(forCurrencyCode: $0) ?? "").localizedCaseInsensitiveContains(trimmedSearch) }
            
            return Dictionary(grouping: filtered) { code in
                (Locale.current.localizedString(forCurrencyCode: code) ?? code).prefix(1).capitalized
            }
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
