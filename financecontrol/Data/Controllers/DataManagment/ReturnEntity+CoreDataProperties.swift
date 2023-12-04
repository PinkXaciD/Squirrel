//
//  ReturnEntity+CoreDataProperties.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/11/30.
//
//

import Foundation
import CoreData


extension ReturnEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReturnEntity> {
        return NSFetchRequest<ReturnEntity>(entityName: "ReturnEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var amount: Double
    @NSManaged public var amountUSD: Double
    @NSManaged public var name: String?
    @NSManaged public var currency: String?
    @NSManaged public var date: Date?
    @NSManaged public var spending: SpendingEntity?

}

extension ReturnEntity : Identifiable {

}
