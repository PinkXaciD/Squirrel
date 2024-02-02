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
    
    var doubleAmount: Double {
        if currency == spending.wrappedCurrency {
            return Double(amount.replacingOccurrences(of: ",", with: ".")) ?? 0
        } else {
            let doubleAmount = Double(amount.replacingOccurrences(of: ",", with: ".")) ?? 0
            
            return round(doubleAmount / (rvm.rates[currency] ?? 1) * (rvm.rates[spending.wrappedCurrency] ?? 1) * 100) / 100
        }
    }
    
    func done() {
        guard
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
                        if countSum(doubleAmount, returns: returns) {
                            return
                        }
                        
                        cdm.addReturn(
                            to: spending,
                            amount: doubleAmount,
                            amountUSD: doubleAmount / (oldRates[currency] ?? 1),
                            currency: spending.wrappedCurrency,
                            date: date,
                            name: name
                        )
                    } else {
                        if countSum(doubleAmount, returns: returns) {
                            return
                        }
                        
                        cdm.addReturn(
                            to: spending,
                            amount: doubleAmount,
                            amountUSD: doubleAmount / (rvm.rates[currency] ?? 1),
                            currency: spending.wrappedCurrency,
                            date: date,
                            name: name
                        )
                    }
                }
            }
        } else {
            if countSum(doubleAmount, returns: returns) {
                return
            }
            
            cdm.addReturn(
                to: spending,
                amount: doubleAmount,
                amountUSD: doubleAmount / (rvm.rates[currency] ?? 1),
                currency: spending.wrappedCurrency,
                date: date,
                name: name
            )
        }
        
        HapticManager.shared.notification(.success)
    }
    
    func addFull() {
        self.currency = spending.wrappedCurrency
        self.amount = String(spending.amountWithReturns)
    }
    
    private func countSum(_ newAmount: Double, returns: [ReturnEntity]) -> Bool {
        var existingReturnsSum = returns.map { $0.amount }.reduce(0, +)
        existingReturnsSum += newAmount
        
        return !returns.isEmpty && existingReturnsSum > spending.amount
    }
    
    func validate() -> Bool {
        guard
            !amount.isEmpty,
            doubleAmount != 0,
            doubleAmount <= spending.amountWithReturns
        else {
            return true
        }
        
        return false
    }
}
