//
//  ReturnsModel.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/11/30.
//

import CoreData

extension CoreDataModel {
    func addReturn(to spending: SpendingEntity, amount: Double, amountUSD: Double, currency: String, date: Date, name: String) {
        guard
            let description = NSEntityDescription.entity(forEntityName: "ReturnEntity", in: context)
        else {
            return
        }
        
        let newReturn: ReturnEntity = .init(entity: description, insertInto: context)
        newReturn.id = .init()
        newReturn.amount = amount
        newReturn.amountUSD = amountUSD
        newReturn.currency = currency
        newReturn.date = date
        newReturn.name = name
        
        spending.addToReturns(newReturn)
        manager.save()
        
        fetchSpendings()
    }
    
    func addFullReturn(to spending: SpendingEntity) {
        addReturn(
            to: spending,
            amount: spending.amountWithReturns,
            amountUSD: spending.amountUSDWithReturns,
            currency: spending.wrappedCurrency,
            date: .now,
            name: ""
        )
    }
    
    func deleteReturn(spendingReturn: ReturnEntity) {
        context.delete(spendingReturn)
        manager.save()
        fetchSpendings()
    }
}
