//
//  EditSpendingViewModel.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/11/23.
//

import SwiftUI

final class EditSpendingViewModel: SpendingViewModel {
    @ObservedObject
    var cdm: CoreDataModel
    @ObservedObject
    var rvm: RatesViewModel
    var entity: SpendingEntity
    
    @Published var amount: String
    @Published var currency: String
    @Published var date: Date
    @Published var categoryName: String
    @Published var categoryId: UUID
    @Published var place: String
    @Published var comment: String
    
    init(ratesViewModel rvm: RatesViewModel, coreDataModel cdm: CoreDataModel, entity: SpendingEntity) {
        self.cdm = cdm
        self.rvm = rvm
        self.entity = entity
        self.amount = "\(entity.amount)"
        self.currency = entity.wrappedCurrency
        self.date = entity.wrappedDate
        self.categoryName = entity.categoryName
        self.categoryId = entity.category?.id ?? .init()
        self.place = entity.place ?? ""
        self.comment = entity.comment ?? ""
        
        print("EditSpendingViewModel init")
    }
    
    deinit {
        print("EditSpendingViewModel deinit")
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
                        
                        cdm.editSpending(spending: entity, newSpending: spending)
                    }
                }
            } else {
                spending.amountUSD = doubleAmount / (rvm.rates[currency] ?? 1)
                
                cdm.editSpending(spending: entity, newSpending: spending)
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
}
