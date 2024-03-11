//
//  CategoryEntity+CoreDataProperties.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/09/07.
//
//

import Foundation
import CoreData


extension CategoryEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CategoryEntity> {
        return NSFetchRequest<CategoryEntity>(entityName: "CategoryEntity")
    }

    @NSManaged public var color: String?
    @NSManaged public var id: UUID?
    @NSManaged public var isShadowed: Bool
    @NSManaged public var isFavorite: Bool
    @NSManaged public var name: String?
    @NSManaged public var spendings: NSSet?

}

// MARK: Generated accessors for spendings
extension CategoryEntity {

    @objc(addSpendingsObject:)
    @NSManaged public func addToSpendings(_ value: SpendingEntity)

    @objc(removeSpendingsObject:)
    @NSManaged public func removeFromSpendings(_ value: SpendingEntity)

    @objc(addSpendings:)
    @NSManaged public func addToSpendings(_ values: NSSet)

    @objc(removeSpendings:)
    @NSManaged public func removeFromSpendings(_ values: NSSet)

}

extension CategoryEntity : Identifiable {

}

extension CategoryEntity: ToSafeObject {
    func safeObject() -> TSCategoryEntity {
        var safeSpendings: NSSet {
            guard let spendings = self.spendings?.allObjects as? [SpendingEntity] else {
                return []
            }
            
            let array = spendings.map { $0.safeObject() }
            
            return Set(array) as NSSet
        }
        
        return TSCategoryEntity(
            color: color,
            id: id,
            isShadowed: isShadowed,
            isFavorite: isFavorite,
            name: name,
            spendings: safeSpendings
        )
    }
}

struct CategoryEntityLocal: Identifiable, Equatable, Comparable {
    static func < (lhs: CategoryEntityLocal, rhs: CategoryEntityLocal) -> Bool {
        let firstSum = lhs.sumUSDWithReturns
        let secondSum = rhs.sumUSDWithReturns
        
        if firstSum == secondSum {
            return lhs.name > rhs.name
        }
        
        return firstSum < secondSum
    }
    
    static func == (lhs: CategoryEntityLocal, rhs: CategoryEntityLocal) -> Bool {
        return lhs.id == rhs.id
    }
    
    var color: String
    var id: UUID
    var name: String
    var spendings: [SpendingEntityLocal]
    var sumUSDWithReturns: Double
    var sumWithReturns: Double
}

extension CategoryEntityLocal {
    init(from category: CategoryEntity) {
        self.color = category.color ?? ""
        self.id = category.id ?? .init()
        self.name = category.name ?? ""
        
        var spendings: [SpendingEntityLocal] = []
        var sumUSDWithReturns: Double = 0
        var sumWithReturns: Double = 0
        
        if let unwrapped = category.spendings?.allObjects as? [SpendingEntity] {
            for spending in unwrapped {
                spendings.append(
                    .init(
                        amountUSD: spending.amountUSD,
                        amount: spending.amount,
                        amountWithReturns: spending.amountWithReturns,
                        amountUSDWithReturns: spending.amountUSDWithReturns,
                        comment: spending.comment ?? "",
                        currency: spending.wrappedCurrency,
                        date: spending.wrappedDate,
                        place: spending.place ?? "",
                        categoryId: category.id ?? .init()
                    )
                )
                
                sumUSDWithReturns += spending.amountUSDWithReturns
                
                let defaultCurrency = UserDefaults.standard.string(forKey: "defaultCurrency") ?? Locale.current.currencyCode ?? "USD"
                
                if spending.wrappedCurrency == defaultCurrency {
                    sumWithReturns += spending.amount
                } else {
                    guard
                        let fetchedRates = UserDefaults.standard.dictionary(forKey: "rates") as? [String:Double],
                        let defaultCurrencyRate = fetchedRates[defaultCurrency]
                    else {
                        continue
                    }
                    
                    sumWithReturns += (spending.amountUSDWithReturns * defaultCurrencyRate)
                }
            }
        }
        
        self.spendings = spendings
        self.sumUSDWithReturns = sumUSDWithReturns
        self.sumWithReturns = sumWithReturns
    }
}

struct TSCategoryEntity: ToUnsafeObject, Identifiable, Comparable {
    func unsafeObject(in context: NSManagedObjectContext) throws -> CategoryEntity {
        try context.performAndWait {
            guard let description = NSEntityDescription.entity(forEntityName: "CategoryEntity", in: context) else {
                throw CoreDataError.failedToGetEntityDescription
            }
            
            let entity = CategoryEntity(entity: description, insertInto: context)
            entity.id = self.id
            entity.name = self.name
            entity.color = self.color
            entity.isFavorite = self.isFavorite
            entity.isShadowed = self.isShadowed
            
            var unsafeSpendings: NSSet {
                guard let spendings = self.spendings?.allObjects as? [TSSpendingEntity] else {
                    return []
                }
                
                guard
                    let array = try? spendings.map({ try $0.unsafeObject(in: context) })
                else {
                    return []
                }
                
                return Set(array) as NSSet
            }
            
            entity.spendings = unsafeSpendings
            return entity
        }
    }
    
    static func < (lhs: TSCategoryEntity, rhs: TSCategoryEntity) -> Bool {
        let firstSum = lhs.sumUSDWithReturns
        let secondSum = rhs.sumUSDWithReturns
        
        if firstSum == secondSum {
            return lhs.name ?? "" > rhs.name ?? ""
        }
        
        return firstSum < secondSum
    }
    
    static func == (lhs: TSCategoryEntity, rhs: TSCategoryEntity) -> Bool {
        return lhs.id == rhs.id
    }
    
    let color: String?
    let id: UUID?
    let isShadowed: Bool
    let isFavorite: Bool
    let name: String?
    var spendings: NSSet?
    
    var spendingsArray: [TSSpendingEntity] {
        return spendings?.allObjects as? [TSSpendingEntity] ?? []
    }
    
    var sumWithReturns: Double {
        let rates = UserDefaults.standard.dictionary(forKey: "rates") as? [String: Double] ?? [:]
        let defaultCurrency = UserDefaults.standard.string(forKey: "defaultCurrency") ?? Locale.current.currencyCode ?? "USD"
        let sum = self.spendingsArray.compactMap {
            if $0.wrappedCurrency == defaultCurrency {
                return $0.amountWithReturns
            } else {
                return $0.amountUSDWithReturns * (rates[defaultCurrency] ?? 1)
            }
        }
        
        return sum.reduce(0, +)
    }
    
    var sumUSDWithReturns: Double {
        self.spendingsArray.compactMap { $0.amountUSDWithReturns }.reduce(0, +)
    }
}
