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
    
    @AppStorage("defaultCurrency") var defaultCurrency: String = "USD"
    
    let tag: String
    let currency: CurrencyEntity
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(Locale.current.localizedString(forCurrencyCode: tag)?.capitalized ?? "Error")
                
                HStack {
                    Image(systemName: currency.isFavorite ? "star.fill" : "star")
                        .foregroundColor(currency.isFavorite ? Color.yellow : Color.secondary)
                    
                    if let rate = rvm.rates[tag], let defaultRate = rvm.rates[defaultCurrency] {
                        if tag == defaultCurrency {
                            Text("Selected as default")
                        } else {
                            Text("1 \(tag) = \(String((1 / rate) * defaultRate).currencyFormat) \(defaultCurrency)")
                        }
                    } else {
                        Text("No up to date exchange rate found")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if defaultCurrency == tag {
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
}

//#Preview {
//    CurrencyRow()
//}
