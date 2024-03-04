//
//  EditReturnViewModel.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/12/05.
//

import SwiftUI
#if DEBUG
import OSLog
#endif

final class EditReturnViewModel: ViewModel {
    @Published var amount: String
    @Published var name: String
    @Published var date: Date
    @Published var currency: String
    var oldAmount: Double
    var spending: SpendingEntity?
    var returnEntity: ReturnEntity
    @ObservedObject private var cdm: CoreDataModel
    @ObservedObject private var rvm: RatesViewModel
    
    init(returnEntity: ReturnEntity, cdm: CoreDataModel, rvm: RatesViewModel) {
        var formatter: NumberFormatter {
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = 0
            formatter.decimalSeparator = Locale.current.decimalSeparator ?? "."
            return formatter
        }
        
        self.amount = formatter.string(from: returnEntity.amount as NSNumber) ?? "\(returnEntity.amount)".replacingOccurrences(of: ".", with: Locale.current.decimalSeparator ?? ".")
        self.name = returnEntity.name ?? ""
        self.date = returnEntity.date ?? .now
        self.currency = returnEntity.currency ?? "USD"
        self.oldAmount = returnEntity.amount
        self.spending = returnEntity.spending
        self.returnEntity = returnEntity
        self._cdm = .init(initialValue: cdm)
        self._rvm = .init(initialValue: rvm)
    }
    
//    var formatter: NumberFormatter {
//        let formatter = NumberFormatter()
//        formatter.maximumFractionDigits = 2
//        formatter.minimumFractionDigits = 0
//        formatter.decimalSeparator = Locale.current.decimalSeparator ?? "."
//        return formatter
//    }
    
    var doubleAmount: Double {
        if currency == spending?.wrappedCurrency {
            return Double(truncating: NumberFormatter().number(from: amount) ?? 0)
        } else {
            let doubleAmount = Double(truncating: NumberFormatter().number(from: amount) ?? 0)
            
            return round(doubleAmount / (rvm.rates[currency] ?? 1) * (rvm.rates[spending?.wrappedCurrency ?? "USD"] ?? 1) * 100) / 100
        }
    }
    
    func edit() -> Bool {
        cdm.editReturn(
            entity: returnEntity,
            amount: doubleAmount,
            amountUSD: doubleAmount / (rvm.rates[spending?.wrappedCurrency ?? currency] ?? 1),
            currency: spending?.wrappedCurrency ?? currency,
            date: date,
            name: name
        )
        
        return true
    }
    
    func editFromSpending(spending: SpendingEntity) {
        var amountUSD: Double {
            if spending.wrappedCurrency == "USD" {
                #if DEBUG
                let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
                logger.log("Currency is USD, skipping rates fetching...")
                #endif
                return doubleAmount
            }
            
            var result: Double = 0
            
            if Calendar.current.isDateInToday(date) {
                result = doubleAmount / (rvm.rates[spending.wrappedCurrency] ?? 1)
            } else {
                Task {
                    let oldRates = try? await rvm.getRates(date).rates
                    let preResult: Double = await MainActor.run {
                        if let rate = oldRates?[spending.wrappedCurrency] {
                            return doubleAmount / rate
                        } else {
                            return doubleAmount / (rvm.rates[spending.wrappedCurrency] ?? 1)
                        }
                    }
                    
                    result = preResult
                }
            }
            
            return result
        }
        
        cdm.editRerturnFromSpending(
            spending: spending,
            oldReturn: returnEntity,
            amount: doubleAmount,
            amountUSD: amountUSD,
            currency: spending.wrappedCurrency,
            date: date,
            name: name
        )
    }
    
    func validate() -> Bool {
        guard
            !amount.isEmpty,
            let number = NumberFormatter().number(from: amount),
            Double(truncating: number) != 0,
            let spending = self.spending,
            Double(truncating: number) <= (spending.amountWithReturns + oldAmount)
        else {
            return true
        }
        
        return false
    }
}
