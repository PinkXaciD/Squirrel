//
//  AddSpendingViewModel.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/11/22.
//

import SwiftUI

final class AddSpendingViewModel: ViewModel {
    @ObservedObject internal var cdm: CoreDataModel
    @ObservedObject private var rvm: RatesViewModel
    
    @Published var amount: String
    @Published var currency: String
    @Published var date: Date
    @Published var categoryName: String
    @Published var categoryId: UUID
    @Published var place: String
    @Published var comment: String
    
    init(ratesViewModel rvm: RatesViewModel, coreDataModel cdm: CoreDataModel) {
        self.amount = ""
        self.currency = UserDefaults.standard.string(forKey: "defaultCurrency") ?? "USD"
        self.date = .now
        self.categoryName = "Select Category"
        self.categoryId = .init()
        self.place = ""
        self.comment = ""
        self.rvm = rvm
        self.cdm = cdm
        print("AddSpendingViewModel init")
    }
    
    deinit {
        print("AddSpendingViewModel deinit")
    }
    
    func done() {
        if let doubleAmount = Double(amount) {
            var spending: SpendingEntityLocal = .init(
                amountUSD: 0,
                amount: doubleAmount,
                comment: comment,
                currency: currency,
                date: date,
                place: place,
                categoryId: categoryId
            )
            
            if !Calendar.current.isDateInToday(date) {
                Task {
                    let oldRates = try? await rvm.getRates(date).rates
                    await MainActor.run {
                        if let oldRates = oldRates {
                            spending.amountUSD = doubleAmount / (oldRates[currency] ?? 1)
                        } else {
                            spending.amountUSD = doubleAmount / (rvm.rates[currency] ?? 1)
                        }
                        
                        cdm.addSpending(spending: spending)
                    }
                }
            } else {
                spending.amountUSD = doubleAmount / (rvm.rates[currency] ?? 1)
                
                cdm.addSpending(spending: spending)
            }
            
            HapticManager.shared.notification(.success)
        } else {
            HapticManager.shared.notification(.error)
            
            ErrorType(
                errorDescription: "Failed to add expence",
                failureReason: "Cannot convert amount to number",
                recoverySuggestion: "Try again"
            )
            .publish()
        }
    }
    
    func clear() {
        self.amount = ""
        self.currency = UserDefaults.standard.string(forKey: "defaultCurrency") ?? "USD"
        self.date = .now
        self.categoryName = "Select Category"
        self.categoryId = .init()
        self.place = ""
        self.comment = ""
    }
}
