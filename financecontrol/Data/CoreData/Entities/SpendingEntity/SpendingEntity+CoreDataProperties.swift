//
//  SpendingEntity+CoreDataProperties.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/09/07.
//
//

import Foundation
import CoreData
import SwiftUI

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
    @NSManaged public var timeZoneIdentifier: String?
    @NSManaged public var category: CategoryEntity?
    @NSManaged public var returns: NSSet?

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

extension SpendingEntity : Identifiable {

}

extension SpendingEntity {
    public var wrappedCurrency: String {
        currency ?? "Error"
    }
    
    public var wrappedDate: Date {
        date ?? Date()
    }
    
    @objc
    public var startOfDay: Date {
        UserDefaults.standard.bool(forKey: UDKey.formatWithoutTimeZones.rawValue) ? Calendar.current.startOfDay(for: self.wrappedDate) : Calendar.current.startOfDay(for: self.dateAdjustedToTimeZone)
    }
    
    public var dateAdjustedToTimeZone: Date {
        guard let secondsFromExpenseTimeZone = TimeZone(identifier: self.timeZoneIdentifier ?? "")?.secondsFromGMT() else {
            return self.wrappedDate
        }
        
        let secondsFromCurrent = TimeZone.autoupdatingCurrent.secondsFromGMT()
        
        guard let result = Calendar.autoupdatingCurrent.date(byAdding: .second, value: (secondsFromCurrent - secondsFromExpenseTimeZone) * -1, to: self.wrappedDate) else {
            return self.wrappedDate
        }
        
        return result
    }
    
    public var wrappedId: UUID {
        id ?? UUID()
    }
    
    public var categoryName: String {
        category?.name ?? "Error"
    }
    
    @objc
    public var categoryID: UUID {
        category?.id ?? .init()
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

extension SpendingEntity: ToSafeObject {
    func safeObject() -> TSSpendingEntity {
        return TSSpendingEntity(self)
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

// MARK: Thread-safe SpendingEntity
/// Thread-safe immutable structure, mirroring `SpendingEntity` CoreData class
struct TSSpendingEntity: ToUnsafeObject, Hashable, Identifiable {
    let amount: Double
    let amountUSD: Double
    let comment: String?
    let currency: String?
    let date: Date?
    let timeZoneIdentifier: String?
    let id: UUID?
    let place: String?
    let categoryID: UUID?
    let categoryName: String
    let categoryColor: String?
    let returns: [TSReturnEntity]
    
    var wrappedCurrency: String {
        currency ?? "Error"
    }
    
    var wrappedDate: Date {
        date ?? Date()
    }
    
    var dateAdjustedToTimeZone: Date {
        guard let secondsFromExpenseTimeZone = self.timeZone?.secondsFromGMT() else {
            return self.wrappedDate
        }
        
        let secondsFromCurrent = TimeZone.autoupdatingCurrent.secondsFromGMT()
        
        guard let result = Calendar.autoupdatingCurrent.date(byAdding: .second, value: (secondsFromCurrent - secondsFromExpenseTimeZone) * -1, to: self.wrappedDate) else {
            return self.wrappedDate
        }
        
        return result
    }
    
    var wrappedId: UUID {
        id ?? UUID()
    }
    
    var amountUSDWithReturns: Double {
        guard
            !returns.isEmpty
        else {
            return amountUSD
        }
        
        let result = returns.map{ $0.amountUSD }.reduce(amountUSD, -)
        
        if result < 0 {
            return 0
        } else {
            return result
        }
    }
    
    var returnsSum: Double {
        guard
            !returns.isEmpty
        else {
            return 0
        }
        
        return returns.map({ $0.amount }).reduce(0, +)
    }
    
    var amountWithReturns: Double {
        return amount - returnsSum
    }
    
    var timeZone: TimeZone? {
        guard
            let timeZoneIdentifier,
            let timeZone = TimeZone(identifier: timeZoneIdentifier)
        else {
            return nil
        }
        
        return timeZone
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
    
    /// Memberwise initializer
    /// - Important: You can crerate object with this initializer, but to convert created object to CoreData class you need to be sure that `id` you passed is valid and CoreData class with such id exists and can be fetched
    init(amount: Double, amountUSD: Double, comment: String?, currency: String?, date: Date?, timeZoneIdentifier: String?, id: UUID?, place: String?, categoryID: UUID?, categoryName: String, categoryColor: String?, returns: [TSReturnEntity]) {
        self.amount = amount
        self.amountUSD = amountUSD
        self.comment = comment
        self.currency = currency
        self.date = date
        self.timeZoneIdentifier = timeZoneIdentifier
        self.id = id
        self.place = place
        self.categoryID = categoryID
        self.categoryName = categoryName
        self.categoryColor = categoryColor
        self.returns = returns
    }
    
    /// Creates thread-safe, immutable spending object from CoreData object
    /// - Parameter spending: CoreData object
    /// - Important: While created object is thread-safe, this method is not, and should be called only from CoreData object's context
    init(_ spending: SpendingEntity) {
        self.amount = spending.amount
        self.amountUSD = spending.amountUSD
        self.comment = spending.comment
        self.currency = spending.currency
        self.date = spending.date
        self.timeZoneIdentifier = spending.timeZoneIdentifier
        self.id = spending.id
        self.place = spending.place
        self.categoryID = spending.category?.id
        self.categoryName = spending.categoryName
        self.categoryColor = spending.category?.color
        self.returns = spending.returnsArr.map({ $0.safeObject() })
    }
}
