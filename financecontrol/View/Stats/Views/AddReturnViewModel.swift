//
//  AddReturnViewModel.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/11/30.
//

import SwiftUI
#if DEBUG
import OSLog
#endif

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
            return Double(truncating: NumberFormatter().number(from: amount) ?? 0)
        } else {
            let doubleAmount = Double(truncating: NumberFormatter().number(from: amount) ?? 0)
            
            return round(doubleAmount / (rvm.rates[currency] ?? 1) * (rvm.rates[spending.wrappedCurrency] ?? 1) * 100) / 100
        }
    }
    
    func done() {
        guard
            let returns = spending.returns?.allObjects as? [ReturnEntity]
        else {
            ErrorType(
                errorDescription: "Failed to add return",
                failureReason: "Cannot convert amount to number",
                recoverySuggestion: "Try again"
            )
            .publish()
            
            return
        }
        
        if spending.wrappedCurrency == "USD" {
            if countSum(doubleAmount, returns: returns) {
                return
            }
            
            cdm.addReturn(
                to: spending,
                amount: doubleAmount,
                amountUSD: doubleAmount,
                currency: spending.wrappedCurrency,
                date: date,
                name: name
            )
            #if DEBUG
            let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
            logger.log("Currency is USD, skipping rates fetching...")
            #endif
            
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
                            amountUSD: doubleAmount / (oldRates[spending.wrappedCurrency] ?? 1),
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
                            amountUSD: doubleAmount / (rvm.rates[spending.wrappedCurrency] ?? 1),
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
                amountUSD: doubleAmount / (rvm.rates[spending.wrappedCurrency] ?? 1),
                currency: spending.wrappedCurrency,
                date: date,
                name: name
            )
        }
    }
    
    func addFull() {
        var formatter: NumberFormatter {
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = 0
            formatter.decimalSeparator = Locale.current.decimalSeparator ?? "."
            return formatter
        }
        
        self.currency = spending.wrappedCurrency
        self.amount = String(spending.amountWithReturns)
        self.amount = formatter.string(from: spending.amountWithReturns as NSNumber) ?? String(spending.amountWithReturns).replacingOccurrences(of: ",", with: Locale.current.decimalSeparator ?? ".")
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
