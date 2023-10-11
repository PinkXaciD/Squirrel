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
    
    func addSpending(spending: SpendingEntityLocal) {
        
        if
            let description = NSEntityDescription.entity(forEntityName: "SpendingEntity", in: context),
            let category = findCategory(spending.categoryId)
        {
            let newSpending = SpendingEntity(entity: description, insertInto: context)
            
            newSpending.id = UUID()
            newSpending.amount = spending.amount
            newSpending.amountUSD = spending.amountUSD
            newSpending.currency = spending.currency
            newSpending.date = spending.date
            newSpending.place = spending.place
            newSpending.comment = spending.comment
            
            addToCategory(newSpending, category)
            
            manager.save()
            fetchSpendings()
        }
    }
    
    func editSpending(spending: SpendingEntity,newSpending: SpendingEntityLocal) {
        spending.amount = newSpending.amount
        spending.amountUSD = newSpending.amountUSD
        spending.currency = newSpending.currency
        spending.place = newSpending.place
        spending.date = newSpending.date
        spending.comment = newSpending.comment
        
        if let category = findCategory(newSpending.categoryId) {
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
