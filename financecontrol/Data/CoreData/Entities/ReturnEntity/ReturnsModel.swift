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
        
        if Calendar.current.isDateInToday(spending.wrappedDate) {
            passSpendingsToSumWidget()
        }
        
        HapticManager.shared.notification(.success)
    }
    
    func importReturn(to spending: SpendingEntity, returnEntity: ReturnEntity) {
        guard
            let description = NSEntityDescription.entity(forEntityName: "ReturnEntity", in: context)
        else {
            ErrorType(CoreDataError.failedToGetEntityDescription).publish()
            return
        }
        
        let newReturn: ReturnEntity = .init(entity: description, insertInto: context)
        newReturn.id = returnEntity.id ?? .init()
        newReturn.amount = returnEntity.amount
        newReturn.amountUSD = returnEntity.amountUSD
        newReturn.currency = returnEntity.currency ?? spending.wrappedCurrency
        newReturn.date = returnEntity.date ?? Date()
        newReturn.name = returnEntity.name
        
        spending.addToReturns(newReturn)
        
        let privateContext = returnEntity.managedObjectContext
        
        privateContext?.delete(returnEntity)
    }
    
    func deleteReturn(spendingReturn: ReturnEntity) {
        let date = spendingReturn.date
        context.delete(spendingReturn)
        manager.save()
        fetchSpendings()
        
        if Calendar.current.isDateInToday(date ?? .distantPast) {
            passSpendingsToSumWidget()
        }
    }
    
    func editReturn(
        entity returnEntity: ReturnEntity,
        amount: Double,
        amountUSD: Double,
        currency: String,
        date: Date,
        name: String
    ) {
        returnEntity.amount = amount
        returnEntity.amountUSD = amountUSD
        returnEntity.currency = currency
        returnEntity.date = date
        returnEntity.name = name
        manager.save()
        fetchSpendings()
        
        if Calendar.current.isDateInToday(date) {
            passSpendingsToSumWidget()
        }
    }
    
    func editRerturnFromSpending(
        spending: SpendingEntity,
        oldReturn: ReturnEntity,
        amount: Double,
        amountUSD: Double,
        currency: String,
        date: Date,
        name: String
    ) {
        guard
            let description = NSEntityDescription.entity(forEntityName: "ReturnEntity", in: context)
        else {
            return
        }
        
        let newReturn = ReturnEntity(entity: description, insertInto: context)
        
        newReturn.id = UUID()
        newReturn.amount = amount
        newReturn.amountUSD = amountUSD
        newReturn.currency = currency
        newReturn.date = date
        newReturn.name = name
        
        spending.removeFromReturns(oldReturn)
        spending.addToReturns(newReturn)
        
        manager.save()
        fetchSpendings()
        
        if Calendar.current.isDateInToday(spending.wrappedDate) {
            passSpendingsToSumWidget()
        }
    }
}
