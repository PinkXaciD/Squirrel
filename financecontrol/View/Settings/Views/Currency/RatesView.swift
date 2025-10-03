//
//  RatesView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/09/18.
//

import SwiftUI

struct RatesView: View {
    @EnvironmentObject private var rvm: RatesViewModel
    
    var body: some View {
        List {
            Section {
                ForEach(filteredRates) {
                    $0
                }
            } header: {
                ratesHeader
            }
        }
        .navigationTitle("Rates")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var filteredRates: [RatesRowView] {
        let rates = rvm.rates
        
        return rates
            .filter { Locale.customCommonISOCurrencyCodes.contains($0.key.uppercased()) }
            .map { RatesRowView(code: $0.key.uppercased(), rate: $0.value) }
            .sorted { $0.name < $1.name }
    }
    
    private var ratesHeader: some View {
        HStack {
            Text("Name")
            
            Spacer()
            
            Text("1 USD")
        }
    }
}

struct RatesRowView: View, Identifiable {
    internal init(code: String, rate: Double) {
        self.name = Locale.current.localizedString(forCurrencyCode: code)?.capitalized ?? "Error with: \(code)"
        self.code = code
        self.rate = rate
    }
    
    let name: String
    let code: String
    let rate: Double
    var id: String {
        name
    }
    
    var body: some View {
        HStack {
            Text(name)
            
            Spacer()
            
            Text(rate.formatted(.currency(code: code)))
        }
    }
}

struct CurrencyConvertView: View {
    @EnvironmentObject private var rvm: RatesViewModel
    
    @State private var firstWheelCurrency: String = UserDefaults.defaultCurrency()
    @State private var firstPickerCurrency: String = UserDefaults.defaultCurrency()
    @State private var firstTabSelection: Int = 0
    
    private var firstCurrency: String {
        if firstTabSelection == 1 {
            return firstPickerCurrency
        }
        
        return firstWheelCurrency
    }
    
    @State private var secondWheelCurrency: String = UserDefaults.standard.string(forKey: UDKey.defaultSelectedCurrency.rawValue) ?? "USD"
    @State private var secondPickerCurrency: String = UserDefaults.standard.string(forKey: UDKey.defaultSelectedCurrency.rawValue) ?? "USD"
    @State private var secondTabSelection: Int = 0
    
    private var secondCurrency: String {
        if secondTabSelection == 1 {
            return secondPickerCurrency
        }
        
        return secondWheelCurrency
    }
    
    @State private var firstValue: String = ""
    @State private var swap: Bool = false
    
    @FocusState private var focus: Bool
    
    var currencies: [Currency] {
        UserDefaults.standard.getCurrencies()
    }
    
    let formatter = NumberFormatter.standard
    
    var secondValue: String {
        let firstRate = rvm.rates[firstCurrency] ?? 1
        let secondRate = rvm.rates[secondCurrency] ?? 1
        
        let number = formatter.number(from: firstValue) ?? 0
    
        let doubleAmount = Double(truncating: number)
        
        return Locale.autoupdatingCurrent.currencyNarrowFormat((doubleAmount * (secondRate)) / (firstRate), currency: secondCurrency, removeFractionDigigtsFrom: 1000, showCurrencySymbol: false) ?? "0.00"
    }
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Text(secondValue)
                    .font(.system(size: 100, design: .rounded).bold())
                    .minimumScaleFactor(0.1)
                    .lineLimit(1)
                    .foregroundStyle(.tint)
                    .contentTransitionNumericText()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .animation(.default, value: secondValue)
                
                HStack {
                    getWheel("Currency 1", wheelSelection: $firstWheelCurrency, menuSelection: $firstPickerCurrency, tabSelection: $firstTabSelection)
                    
                    Button {
                        withAnimation(.bouncy) {
                            swap.toggle()
                            
                            let tempValue = firstWheelCurrency
                            firstWheelCurrency = secondWheelCurrency
                            secondWheelCurrency = tempValue
                            
                            let menuTempValue = firstPickerCurrency
                            firstPickerCurrency = secondPickerCurrency
                            secondPickerCurrency = menuTempValue
                            
                            if firstTabSelection != secondTabSelection {
                                let firstTab = firstTabSelection
                                firstTabSelection = secondTabSelection
                                secondTabSelection = firstTab
                            }
                        }
                        
                        HapticManager.shared.impact(.soft)
                    } label: {
                        Label("Swap", systemImage: "arrow.left.arrow.right")
                            .rotationEffect(.degrees(swap ? 0 : 180))
                    }
                    .buttonStyle(.borderless)
                    .labelStyle(.iconOnly)
                    .font(.body.bold())
                    .zIndex(2)
                    
                    getWheel("Currency 2", wheelSelection: $secondWheelCurrency, menuSelection: $secondPickerCurrency, tabSelection: $secondTabSelection)
                }
                .pickerStyle(.wheel)
                
                Spacer()
                
                getField(currency: firstCurrency, text: $firstValue)
            }
            .padding()
        }
//        .overlay(alignment: .topTrailing) {
//            VStack {
//                Text(firstCurrency)
//                Text(secondCurrency)
//                Text(firstWheelCurrency)
//                Text(secondWheelCurrency)
//                Text(firstPickerCurrency)
//                Text(secondPickerCurrency)
//            }
//            .padding()
//            .background(Color.red)
//        }
        .animation(.default, value: firstWheelCurrency)
        .animation(.default, value: secondWheelCurrency)
        .task {
            await MainActor.run {
                focus = true
            }
        }
        .onChange(of: firstValue) { newValue in
            HapticManager.shared.impact(.soft)
        }
        .onChange(of: firstCurrency) { newValue in
            if newValue == "Other" {
                firstPickerCurrency = firstWheelCurrency
                return
            }
            
            if newValue == secondCurrency {
                withAnimation {
                    secondWheelCurrency = secondWheelCurrency == (Locale.current.currencyCode ?? "USD") ? "USD" : (Locale.current.currencyCode ?? "USD")
                }
            }
        }
        .onChange(of: secondCurrency) { newValue in
            if newValue == "Other" {
                secondPickerCurrency = secondWheelCurrency
                return
            }
            
            if newValue == firstCurrency {
                withAnimation {
                    firstWheelCurrency = firstWheelCurrency == (Locale.current.currencyCode ?? "USD") ? "USD" : (Locale.current.currencyCode ?? "USD")
                }
            }
        }
        .navigationTitle("Currency convert")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func getWheel(_ name: LocalizedStringKey, wheelSelection: Binding<String>, menuSelection: Binding<String>, tabSelection: Binding<Int>) -> some View {
        TabView(selection: tabSelection) {
            Picker(name, selection: wheelSelection) {
                ForEach(currencies) { currency in
                    VStack {
                        Text(currency.name ?? currency.code)
                            .font(.system(.title2, design: .rounded).bold())
                            .foregroundStyle(.tint)
                            .padding(.horizontal)
                            .minimumScaleFactor(0.5)
                    }
                    .tag(currency.code)
                }
            }
            .pickerStyle(.wheel)
            .fixWheelPicker()
            .tabItem {
                Text("Your Currencies")
            }
            .tag(0)
            
            NavigationLink {
                OtherCurrencySelector(selectedCurrency: menuSelection)
            } label: {
                HStack {
                    Text(Currency(code: menuSelection.wrappedValue).name ?? menuSelection.wrappedValue)
                        .font(.body.bold())
                        .multilineTextAlignment(.leading)
                    
                    Image(systemName: "chevron.forward")
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(uiColor: .tertiarySystemGroupedBackground))
                }
            }
            .tabItem {
                Text("Other Currencies")
            }
            .tag(1)
        }
        .tabViewStyle(.page)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                .aspectRatio(1, contentMode: .fit)
        }
        
//        VStack {
//            Picker(name, selection: wheelSelection) {
//                ForEach(currencies) { currency in
//                    VStack {
//                        Text(currency.name ?? currency.code)
//                            .font(.system(.title2, design: .rounded).bold())
//                            .foregroundStyle(.tint)
//                            .padding(.horizontal)
//                            .minimumScaleFactor(0.5)
//                    }
//                    .tag(currency.code)
//                }
//                
//                VStack {
//                    Text("Other")
//                        .font(.system(.title2, design: .rounded))
//                        .foregroundStyle(.tint)
//                        .padding(.horizontal)
//                        .minimumScaleFactor(0.5)
//                }
//                .tag("Other")
//            }
//            .pickerStyle(.wheel)
//            .fixWheelPicker()
//        }
//        .overlay(alignment: .bottom) {
//            if wheelSelection.wrappedValue == "Other" {
//                NavigationLink {
//                    OtherCurrencySelector(selectedCurrency: menuSelection)
////                    List {
////                        Picker("Currency", selection: menuSelection) {
////                            ForEach(Currency.getAll()) { currency in
////                                Text(currency.name ?? currency.code)
////                                    .tag(currency.code)
////                            }
////                        }
////                        .pickerStyle(.inline)
////                    }
//                } label: {
//                    HStack {
//                        Text(Currency(code: menuSelection.wrappedValue).name ?? menuSelection.wrappedValue)
//                            .font(.body.bold())
//                        
//                        Image(systemName: "chevron.forward")
//                    }
//                }
//                
////                Picker(selection: menuSelection) {
////                    ForEach(Currency.getAll()) { currency in
////                        Text(currency.name ?? currency.code)
////                            .tag(currency.code)
////                    }
////                } label: {
////                    Text(Currency(code: menuSelection.wrappedValue).name ?? menuSelection.wrappedValue)
////                }
////                .pickerStyle(.menu)
//            }
//        }
    }
    
    private func getField(currency: String, text: Binding<String>) -> some View {
        VStack {
            TextField(0.formatted(.number), text: text)
                .focused($focus)
                .currencyFormatted($firstValue, currencyCode: firstCurrency)
                .multilineTextAlignment(.center)
                .keyboardType(.decimalPad)
                .font(.system(.largeTitle, design: .rounded).bold())
                .foregroundStyle(.tint)
                .padding(5)
                .background {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(uiColor: .secondarySystemGroupedBackground), lineWidth: 1)
                }
                .padding(.horizontal)
//                .onAppear {
//                    focus = true
//                }
        }
    }
    
    private var button: some View {
        Button {
            withAnimation {
                swap.toggle()
            }
        } label: {
            Label("Switch", systemImage: "arrow.up.arrow.down")
                .font(.title2.bold())
                .labelStyle(.iconOnly)
        }
        .buttonStyle(.bordered)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

#Preview("Currency Converter") {
    NavigationView {
        CurrencyConvertView()
    }
    .tint(.orange)
}

struct RatesView_Previews: PreviewProvider {
    static var previews: some View {
        RatesView()
    }
}
