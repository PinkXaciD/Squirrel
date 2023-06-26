//
//  DefaultCurrencySelector.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/19.
//

import SwiftUI

struct DefaultCurrencySelector: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var vm: CoreDataViewModel
    
    @State var currency: String = UserDefaults.standard.string(forKey: "defaultCurrency") ?? "USD"
    
    @AppStorage("defaultCurrency") var defaultCurrency: String = "USD"
    
    var body: some View {
        let currencies = vm.savedCurrencies
        
        List {
            Picker("Currency selection", selection: $currency) {
                ForEach(currencies) { currency in
                    Text(currency.name!.capitalized).tag(currency.tag!)
                        .swipeActions(edge: .leading) {
                            Button {
                                vm.changeFavoriteStateOfCurrency(currency)
                            } label: {
                                Image(systemName: "star.fill")
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                vm.deleteCurrency(currency)
                            } label: {
                                Image(systemName: "trash.fill")
                            }
                        }
                        .contextMenu {
                            Button {
                                vm.changeFavoriteStateOfCurrency(currency)
                            } label: {
                                Text("Favorite")
                            }
                            
                            Button(role: .destructive) {
                                vm.deleteCurrency(currency)
                            } label: {
                                Text("Delete")
                            }
                        }
                }
            }
            .onAppear {
                currency = defaultCurrency
            }
            .onDisappear {
                defaultCurrency = currency
            }
            .pickerStyle(.inline)
            .labelsHidden()
            
            Section {
                NavigationLink {
                    AddCurrencyView()
                } label: {
                    Text("Add New")
                }
            }
        }
        .navigationTitle("Currencies")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    AddCurrencyView()
                } label: {
                    Label("Add New currency", systemImage: "plus")
                }

            }
        }
    }
}

struct DefaultCurrencySelector_Previews: PreviewProvider {
    static var previews: some View {
        DefaultCurrencySelector()
            .environmentObject(CoreDataViewModel())
    }
}
