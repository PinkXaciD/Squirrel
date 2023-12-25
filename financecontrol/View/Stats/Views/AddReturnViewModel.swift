//
//  AddReturnViewModel.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/11/30.
//

import SwiftUI

final class AddReturnViewModel: ViewModel {
    @ObservedObject var cdm: CoreDataModel
    @ObservedObject var rvm: RatesViewModel
    
    @Published var amount: String
    @Published var name: String
    @Published var date: Date
    @Published var currency: String
    var spending: SpendingEntity
    
    init(spending: SpendingEntity, cdm: CoreDataModel, rvm: RatesViewModel) {
        self.amount = ""
        self.name = ""
        self.date = .now
        self.currency = spending.wrappedCurrency
        self.spending = spending
        self._cdm = ObservedObject(wrappedValue: cdm)
        self._rvm = ObservedObject(wrappedValue: rvm)
    }
    
    func done() {
        guard
            let doubleAmount = Double(amount),
            let returns = spending.returns?.allObjects as? [ReturnEntity]
        else {
            HapticManager.shared.notification(.error)
            
            ErrorType(
                errorDescription: "Failed to add return",
                failureReason: "Cannot convert amount to number",
                recoverySuggestion: "Try again"
            )
            .publish()
            
            return
        }
        
        if !Calendar.current.isDateInToday(date) {
            Task {
                let oldRates = try? await rvm.getRates(date).rates
                await MainActor.run {
                    if let oldRates = oldRates {
                        if countSum(doubleAmount / (oldRates[currency] ?? 1), returns: returns) {
                            return
                        }
                        
                        cdm.addReturn(
                            to: spending,
                            amount: doubleAmount,
                            amountUSD: doubleAmount / (oldRates[currency] ?? 1),
                            currency: currency,
                            date: date,
                            name: name
                        )
                    } else {
                        if countSum(doubleAmount / (rvm.rates[currency] ?? 1), returns: returns) {
                            return
                        }
                        
                        cdm.addReturn(
                            to: spending,
                            amount: doubleAmount,
                            amountUSD: doubleAmount / (rvm.rates[currency] ?? 1),
                            currency: currency,
                            date: date,
                            name: name
                        )
                    }
                }
            }
        } else {
            if countSum(doubleAmount / (rvm.rates[currency] ?? 1), returns: returns) {
                return
            }
            
            cdm.addReturn(
                to: spending,
                amount: doubleAmount,
                amountUSD: doubleAmount / (rvm.rates[currency] ?? 1),
                currency: currency,
                date: date,
                name: name
            )
        }
        
        HapticManager.shared.notification(.success)
    }
    
    func addFull() {
        self.amount = String(spending.amountWithReturns)
    }
    
    private func countSum(_ newAmount: Double, returns: [ReturnEntity]) -> Bool {
        var existingReturnsSum = returns.map { $0.amountUSD }.reduce(0, +)
        existingReturnsSum += newAmount
        
        return !returns.isEmpty && existingReturnsSum > spending.amountUSD
    }
    
    func validate() -> Bool {
        guard
            !amount.isEmpty,
            let doubleAmount = Double(amount),
            doubleAmount != 0,
            doubleAmount <= spending.amountWithReturns
        else {
            return true
        }
        
        return false
    }
}
