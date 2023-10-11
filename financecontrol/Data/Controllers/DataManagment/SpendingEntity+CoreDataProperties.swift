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

}

extension SpendingEntity : Identifiable {

}

struct SpendingEntityLocal {
    var amountUSD: Double
    var amount: Double
    var comment: String
    var currency: String
    var date: Date
    var place: String
    var categoryId: UUID
}
