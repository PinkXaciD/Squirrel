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
