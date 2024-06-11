//
//  SpendingEntity+CoreDataProperties.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/09/07.
//
//

import Foundation
import CoreData


extension SpendingEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SpendingEntity> {
        return NSFetchRequest<SpendingEntity>(entityName: "SpendingEntity")
    }

    @NSManaged public var amount: Double
    @NSManaged public var amountUSD: Double
    @NSManaged public var comment: String?
    @NSManaged public var currency: String?
    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var place: String?
    @NSManaged public var category: CategoryEntity?
    @NSManaged public var returns: NSSet?
    
    public var wrappedCurrency: String {
        currency ?? "Error"
    }
    
    public var wrappedDate: Date {
        date ?? Date()
    }
    
    public var wrappedId: UUID {
        id ?? UUID()
    }
    
    public var categoryName: String {
        category?.name ?? "Error"
    }
    
    public var amountUSDWithReturns: Double {
        guard
            !returnsArr.isEmpty
        else {
            return amountUSD
        }
        
        let result = returnsArr.map{ $0.amountUSD }.reduce(amountUSD, -)
        
        if result < 0 {
            return 0
        } else {
            return result
        }
    }
    
    public var returnsArr: [ReturnEntity] {
        guard
            let returns = returns?.allObjects as? [ReturnEntity]
        else {
            return []
        }
        
        return returns.sorted { $0.date ?? Date() < $1.date ?? Date() }
    }
    
    public var returnsSum: Double {
        guard
            !returnsArr.isEmpty
        else {
            return 0
        }
        
        return returnsArr.map({ $0.amount }).reduce(0, +)
    }
    
    public var amountWithReturns: Double {
        return amount - returnsSum
    }
}

extension SpendingEntity : Identifiable {

}

// MARK: Generated accessors for returns
extension SpendingEntity {

    @objc(addReturnsObject:)
    @NSManaged public func addToReturns(_ value: ReturnEntity)

    @objc(removeReturnsObject:)
    @NSManaged public func removeFromReturns(_ value: ReturnEntity)

    @objc(addReturns:)
    @NSManaged public func addToReturns(_ values: NSSet)

    @objc(removeReturns:)
    @NSManaged public func removeFromReturns(_ values: NSSet)

}

extension SpendingEntity: ToSafeObject {
    func safeObject() -> TSSpendingEntity {
        TSSpendingEntity(
            amount: amount,
            amountUSD: amountUSD,
            comment: comment,
            currency: currency,
            date: date,
            id: id,
            place: place,
            categoryID: category?.id,
            categoryName: categoryName,
            returns: returns
        )
    }
}

struct SpendingEntityLocal {
    var amountUSD: Double
    var amount: Double
    var amountWithReturns: Double
    var amountUSDWithReturns: Double
    var comment: String
    var currency: String
    var date: Date
    var place: String
    var categoryId: UUID
}

extension SpendingEntityLocal {
    init(
        amount: Double = 0,
        amountUSD: Double = 0,
        currency: String = "USD",
        date: Date = .init(),
        place: String = "",
        categoryId: UUID = .init(),
        comment: String = ""
    ) {
        self.amount = amount
        self.amountUSD = amountUSD
        self.currency = currency
        self.date = date
        self.place = place
        self.categoryId = categoryId
        self.comment = comment
        self.amountUSDWithReturns = amountUSD
        self.amountWithReturns = amount
    }
    
    init(
        amount: Double = 0,
        amountWithReturns: Double = 0,
        amountUSD: Double = 0,
        amountUSDWithReturns: Double = 0,
        currency: String = "USD",
        date: Date = .init(),
        place: String = "",
        categoryId: UUID = .init(),
        comment: String = ""
    ) {
        self.amount = amount
        self.amountUSD = amountUSD
        self.currency = currency
        self.date = date
        self.place = place
        self.categoryId = categoryId
        self.comment = comment
        self.amountUSDWithReturns = amountUSDWithReturns
        self.amountWithReturns = amountWithReturns
    }
}

struct TSSpendingEntity: ToUnsafeObject, Hashable, Identifiable {
    let amount: Double
    let amountUSD: Double
    let comment: String?
    let currency: String?
    let date: Date?
    let id: UUID?
    let place: String?
//    let category: CategoryEntity?
    let categoryID: UUID?
    let categoryName: String
    let returns: NSSet?
    
    public var wrappedCurrency: String {
        currency ?? "Error"
    }
    
    public var wrappedDate: Date {
        date ?? Date()
    }
    
    public var wrappedId: UUID {
        id ?? UUID()
    }
    
    public var amountUSDWithReturns: Double {
        guard
            let returnsArr = returns?.allObjects as? [ReturnEntity],
            !returnsArr.isEmpty
        else {
            return amountUSD
        }
        
        let result = returnsArr.map{ $0.amountUSD }.reduce(amountUSD, -)
        
        if result < 0 {
            return 0
        } else {
            return result
        }
    }
    
    public var returnsArr: [ReturnEntity] {
        guard
            let returns = returns?.allObjects as? [ReturnEntity]
        else {
            return []
        }
        
        return returns.sorted { $0.date ?? Date() < $1.date ?? Date() }
    }
    
    public var returnsSum: Double {
        guard
            !returnsArr.isEmpty
        else {
            return 0
        }
        
        return returnsArr.map({ $0.amount }).reduce(0, +)
    }
    
    public var amountWithReturns: Double {
        return amount - returnsSum
    }
    
    func unsafeObject(in context: NSManagedObjectContext) throws -> SpendingEntity {
        try context.performAndWait {
            let predicate = NSPredicate(format: "id == %@", self.wrappedId as CVarArg)
            let request = SpendingEntity.fetchRequest()
            request.predicate = predicate
            
            guard let unsafeEntity = try context.fetch(request).first else {
                throw CoreDataError.failedToFindCategory
            }
            
            return unsafeEntity
        }
    }
}
