//
//  SpendingsModel.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/09/07.
//

import Foundation
import CoreData

extension CoreDataViewModel {
    
    func fetchSpendings() {
        
        let request = SpendingEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            savedSpendings = try context.fetch(request)
        } catch let error {
            print("Error fetching CoreData: \(error)")
        }
    }
    
    func addSpending(
        amount: Double,
        amountUSD: Double,
        currency: String,
        date: Date,
        comment: String,
        place: String,
        categoryId: UUID
    ) {
        if let description = NSEntityDescription.entity(forEntityName: "SpendingEntity", in: context), let category = findCategory(categoryId) {
            
            let newSpending = SpendingEntity(entity: description, insertInto: context)
            
            newSpending.id = UUID()
            newSpending.amount = amount
            newSpending.amountUSD = amountUSD
            newSpending.currency = currency
            newSpending.date = date
            newSpending.place = place
            newSpending.comment = comment
            
            addToCategory(newSpending, category)
            
            manager.save()
            fetchSpendings()
        }
    }
    
    func editSpending(
        spending: SpendingEntity,
        amount: Double,
        amountUSD: Double,
        currency: String,
        place: String,
        categoryId: UUID,
        date: Date,
        comment: String
    ) {
        spending.amount = amount
        spending.amountUSD = amountUSD
        spending.currency = currency
        spending.place = place
        spending.date = date
        spending.comment = comment
        
        if let category = findCategory(categoryId) {
            spending.category = category
        }
        
        manager.save()
        fetchSpendings()
    }
    
    func deleteSpending(_ spending: SpendingEntity) {
        
        context.delete(spending)
        manager.save()
        fetchSpendings()
    }
    
    func operationsSum() -> Double {
        
        return savedSpendings.compactMap { $0.amountUSD }.reduce(0, +)
    }
    
    func operationsSortByMonth() -> [Dictionary<String, [SpendingEntity]>.Element] {
        
        var operations: [String:[SpendingEntity]] = [:]
        for entity in savedSpendings {
            
            if let date = entity.date {
                
                let key = dateFormatForSort(date: date)
                var value: [SpendingEntity] = operations[key] ?? []
                value.append(entity)
                operations.updateValue(value, forKey: key)
            }
        }
        return operations.sorted { asDate($0.key) > asDate($1.key) }
    }
    
    func operationsSumWeek() -> Double {
        
        savedSpendings.filter {
            $0.wrappedDate > Date.now.lastWeek
        }
        .compactMap {
            $0.amountUSD
        }
        .reduce(0, +)
    }
}
