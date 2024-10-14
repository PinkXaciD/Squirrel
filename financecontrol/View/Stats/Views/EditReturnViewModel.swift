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
    private var cdm: CoreDataModel
    private var rvm: RatesViewModel
    
    init(returnEntity: ReturnEntity, cdm: CoreDataModel, rvm: RatesViewModel) {
        let formatter = NumberFormatter.currency
        
        self.amount = formatter.string(from: returnEntity.amount as NSNumber) ?? "\(returnEntity.amount)".replacingOccurrences(of: ".", with: Locale.current.decimalSeparator ?? ".")
        self.name = returnEntity.name ?? ""
        self.date = returnEntity.date ?? .now
        self.currency = returnEntity.currency ?? "USD"
        self.oldAmount = returnEntity.amount
        self.spending = returnEntity.spending
        self.returnEntity = returnEntity
        self.cdm = cdm
        self.rvm = rvm
    }
    
    var doubleAmount: Double {
        if currency == spending?.wrappedCurrency {
            return Double(truncating: NumberFormatter.standard.number(from: amount) ?? 0)
        } else {
            let doubleAmount = Double(truncating: NumberFormatter.standard.number(from: amount) ?? 0)
            
            return round(doubleAmount / (rvm.rates[currency] ?? 1) * (rvm.rates[spending?.wrappedCurrency ?? "USD"] ?? 1) * 100) / 100
        }
    }
    
    func editFromSpending(spending: SpendingEntity) {
        let amountUSD: Double = doubleAmount / (spending.amount / spending.amountUSD)
        
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
