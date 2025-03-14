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
        var safeSpendings: [TSSpendingEntity] {
            guard let spendings = self.spendings?.allObjects as? [SpendingEntity] else {
                return []
            }
            
            return spendings.map { $0.safeObject() }
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

/// Thread-safe immutable structure, mirroring `CategoryEntity` CoreData class
struct TSCategoryEntity: ToUnsafeObject, Identifiable, Comparable {
    func unsafeObject(in context: NSManagedObjectContext) throws -> CategoryEntity {
        try context.performAndWait {
            guard let id = self.id else {
                throw CoreDataError.failedToFindCategory
            }
            
            let predicate = NSPredicate(format: "id == %@", id as NSUUID)
            let request = CategoryEntity.fetchRequest()
            request.predicate = predicate
            
            guard let unsafeEntity = try context.fetch(request).first else {
                throw CoreDataError.failedToFindCategory
            }
            
            return unsafeEntity
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
    var spendings: [TSSpendingEntity]
    
//    var spendingsArray: [TSSpendingEntity] {
//        return spendings?.allObjects as? [TSSpendingEntity] ?? []
//    }
    
    var sumWithReturns: Double {
        let rates = UserDefaults.standard.getRates() ?? [:]
        let defaultCurrency = UserDefaults.standard.string(forKey: UDKey.defaultCurrency.rawValue) ?? Locale.current.currencyCode ?? "USD"
        let sum = self.spendings.compactMap {
            if $0.wrappedCurrency == defaultCurrency {
                return $0.amountWithReturns
            } else {
                return $0.amountUSDWithReturns * (rates[defaultCurrency] ?? 1)
            }
        }
        
        return sum.reduce(0, +)
    }
    
    var sumUSDWithReturns: Double {
        self.spendings.compactMap { $0.amountUSDWithReturns }.reduce(0, +)
    }
    
    /// Memberwise initializer
    /// - Important: You can crerate object with this initializer, but to convert created object to CoreData class you need to be sure that `id` you passed is valid and CoreData class with such id exists and can be fetched
    init(color: String?, id: UUID?, isShadowed: Bool, isFavorite: Bool, name: String?, spendings: [TSSpendingEntity]) {
        self.color = color
        self.id = id
        self.isShadowed = isShadowed
        self.isFavorite = isFavorite
        self.name = name
        self.spendings = spendings
    }
    
    /// Creates thread-safe, immutable spending object from CoreData object
    /// - Parameter category: CoreData object
    /// - Important: While created object is thread-safe, this method is not, and should be called only from CoreData object's context
    init(_ category: CategoryEntity) {
        self.color = category.color
        self.id = category.id
        self.isShadowed = category.isShadowed
        self.isFavorite = category.isFavorite
        self.name = category.name
        
        var safeSpendings: [TSSpendingEntity] {
            guard let spendings = category.spendings?.allObjects as? [SpendingEntity] else {
                return []
            }
            
            return spendings.map { $0.safeObject() }
        }
        
        self.spendings = safeSpendings
    }
}
