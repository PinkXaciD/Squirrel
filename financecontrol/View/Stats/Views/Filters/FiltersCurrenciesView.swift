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
    
    @EnvironmentObject
    private var fvm: FiltersViewModel
    
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
                        fvm.currencies = usedCurrencies.map { $0.code }
                    }
                    .disabled(fvm.currencies.count == usedCurrencies.count)
                    
                    Button("Clear Selection", role: .destructive) {
                        fvm.currencies = []
                    }
                    .disabled(fvm.currencies.isEmpty)
                    .animation(.default.speed(3), value: fvm.currencies)
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
                .opacity(fvm.currencies.contains(currency.code) ? 1 : 0)
                .animation(.default.speed(3), value: fvm.currencies)
        }
    }
    
    private func rowAction(_ code: String) {
        if let index = fvm.currencies.firstIndex(of: code) {
            fvm.currencies.remove(at: index)
            return
        }
        
        fvm.currencies.append(code)
    }
}
