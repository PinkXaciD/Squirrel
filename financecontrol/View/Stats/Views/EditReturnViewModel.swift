//
//  EditReturnViewModel.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/12/05.
//

import SwiftUI

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
        self.amount = String(returnEntity.amount)
        self.name = returnEntity.name ?? ""
        self.date = returnEntity.date ?? .now
        self.currency = returnEntity.currency ?? "USD"
        self.oldAmount = returnEntity.amount
        self.spending = returnEntity.spending
        self.returnEntity = returnEntity
        self._cdm = .init(initialValue: cdm)
        self._rvm = .init(initialValue: rvm)
    }
    
    var doubleAmount: Double {
        if currency == spending?.wrappedCurrency {
            return Double(amount.replacingOccurrences(of: ",", with: ".")) ?? 0
        } else {
            let doubleAmount = Double(amount.replacingOccurrences(of: ",", with: ".")) ?? 0
            
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
        cdm.editRerturnFromSpending(
            spending: spending,
            oldReturn: returnEntity,
            amount: doubleAmount,
            amountUSD: doubleAmount / (rvm.rates[spending.wrappedCurrency] ?? 1),
            currency: spending.wrappedCurrency,
            date: date,
            name: name
        )
    }
    
    func validate() -> Bool {
        guard
            !amount.isEmpty,
            let doubleAmount = Double(amount.replacingOccurrences(of: ",", with: ".")),
            doubleAmount != 0,
            let spending = self.spending,
            doubleAmount <= (spending.amountWithReturns + oldAmount)
        else {
            return true
        }
        
        return false
    }
}
