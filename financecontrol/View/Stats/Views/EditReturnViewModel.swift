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
    var currency: String
    var oldAmount: Double
    var spending: SpendingEntity?
    var returnEntity: ReturnEntity
    @ObservedObject private var cdm: CoreDataModel
    
    init(returnEntity: ReturnEntity, cdm: CoreDataModel, rvm: RatesViewModel) {
        self.amount = String(returnEntity.amount)
        self.name = returnEntity.name ?? ""
        self.date = returnEntity.date ?? .now
        self.currency = returnEntity.currency ?? "USD"
        self.oldAmount = returnEntity.amount
        self.spending = returnEntity.spending
        self.returnEntity = returnEntity
        self._cdm = .init(initialValue: cdm)
    }
    
    func edit() -> Bool {
        guard let doubleAmount = Double(amount) else {
            HapticManager.shared.notification(.error)
            return false
        }
        
        cdm.editReturn(
            entity: returnEntity,
            amount: doubleAmount,
            amountUSD: doubleAmount,
            currency: currency,
            date: date,
            name: name
        )
        
        return true
    }
    
    func editFromSpending(spending: SpendingEntity) {
        guard let doubleAmount = Double(amount) else {
            return
        }
        
        cdm.editRerturnFromSpending(
            spending: spending,
            oldReturn: returnEntity,
            amount: doubleAmount,
            amountUSD: doubleAmount,
            currency: currency,
            date: date,
            name: name
        )
    }
    
    func validate() -> Bool {
        guard
            !amount.isEmpty,
            let doubleAmount = Double(amount),
            doubleAmount != 0,
            let spending = self.spending,
            doubleAmount <= (spending.amountWithReturns + oldAmount)
        else {
            return true
        }
        
        return false
    }
}
