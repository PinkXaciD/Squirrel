//
//  CurrencySelectorRow.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/10/15.
//

import SwiftUI

struct CurrencyRow: View {
    @EnvironmentObject private var cdm: CoreDataModel
    @EnvironmentObject private var rvm: RatesViewModel
    
    @AppStorage(UDKeys.defaultCurrency) var defaultCurrency: String = Locale.current.currencyCode ?? "USD"
    
    let code: String
    let currency: CurrencyEntity
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(Locale.current.localizedString(forCurrencyCode: code)?.capitalized ?? "Error")
                
                HStack {
                    Image(systemName: currency.isFavorite ? "star.fill" : "star")
                        .foregroundColor(currency.isFavorite ? Color.yellow : Color.secondary)
                    
                    if rvm.rates[code] != nil, rvm.rates[defaultCurrency] != nil {
                        if code == defaultCurrency {
                            Text("Selected as default")
                        } else {
                            getRateRepresentation()
                        }
                    } else {
                        Text("No up to date exchange rate found")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if defaultCurrency == code {
                Image(systemName: "checkmark")
                    .font(.body.bold())
                    .foregroundColor(.accentColor)
            }
        }
        .background {
            Rectangle()
                .foregroundColor(Color(uiColor: .secondarySystemGroupedBackground))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.vertical, 1) /// Strange behavior without padding
        .swipeActions(edge: .leading) {
            favoriteButton
        }
        .swipeActions(edge: .trailing) {
            deleteButton
        }
        .contextMenu {
            favoriteButton
            
            deleteButton
        }
        .normalizePadding()
    }
    
    private var favoriteButton: some View {
        Button {
            withAnimation {
                cdm.changeFavoriteStateOfCurrency(currency)
            }
        } label: {
            Label(
                currency.isFavorite ? "Remove from favorites" : "Add to favorites",
                systemImage: currency.isFavorite ? "star.slash.fill" : "star.fill"
            )
        }
        .tint(Color.yellow)
    }
    
    private var deleteButton: some View {
        Button(role: .destructive) {
            withAnimation {
                cdm.deleteCurrency(currency)
            }
        } label: {
            Label("Delete", systemImage: "trash.fill")
        }
        .tint(Color.red)
    }
    
    private func getRateRepresentation() -> Text {
        guard
            let rate = rvm.rates[code],
            let defaultRate = rvm.rates[defaultCurrency]
        else { return Text("Error") }
        
        func format1(_ code: String) -> String {
            return 1.formatted(.currency(code: code).precision(.fractionLength(0)).presentation(.isoCode))
        }
        
        if ((1 / rate) * defaultRate) > 1 {
            return Text("\(format1(code)) = \(((1 / rate) * defaultRate).formatted(.currency(code: defaultCurrency).presentation(.isoCode)))")
        } else {
            return Text("\(format1(defaultCurrency)) = \(((1 / defaultRate) * rate).formatted(.currency(code: code).presentation(.isoCode)))")
        }
    }
}

//#Preview {
//    CurrencyRow()
//}
