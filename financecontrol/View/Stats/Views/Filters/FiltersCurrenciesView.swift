//
//  FiltersCurrenciesView.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/06/12.
//

import SwiftUI

struct FiltersCurrenciesView: View {
    @Environment(\.dismiss)
    private var dismiss
    
    @Binding var currencies: [String]
    let usedCurrencies: Set<Currency>
//    @EnvironmentObject
//    private var cdm: CoreDataModel
    
    var body: some View {
        List {
            ForEach(usedCurrencies.sorted(by: <)) { currency in
                Button {
                    rowAction(currency.code)
                } label: {
                    rowLabel(currency)
                }
            }
            
            if !usedCurrencies.isEmpty {
                Section {
                    Button("Select All") {
                        currencies = usedCurrencies.map { $0.code }
                    }
                    .disabled(currencies.count == usedCurrencies.count)
                    
                    Button("Clear Selection", role: .destructive) {
                        currencies = []
                    }
                    .disabled(currencies.isEmpty)
                    .animation(.default.speed(3), value: currencies)
                }
            }
        }
        .navigationTitle("Currencies")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            trailingToolbar
        }
        .overlay {
            if usedCurrencies.isEmpty {
                CustomContentUnavailableView("No Expenses", imageName: "list.bullet", description: "You can add expenses from home screen.")
            }
        }
    }
    
    private var trailingToolbar: ToolbarItem<Void, some View> {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                dismiss()
            } label: {
                Text("Done")
                    .bold()
            }

        }
    }
    
    private func rowLabel(_ currency: Currency) -> some View {
        HStack {
            Text(currency.name ?? currency.code)
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "checkmark")
                .font(.body.bold())
                .opacity(currencies.contains(currency.code) ? 1 : 0)
                .animation(.default.speed(3), value: currencies)
        }
    }
    
    private func rowAction(_ code: String) {
        if let index = currencies.firstIndex(of: code) {
            currencies.remove(at: index)
            return
        }
        
        currencies.append(code)
    }
}
