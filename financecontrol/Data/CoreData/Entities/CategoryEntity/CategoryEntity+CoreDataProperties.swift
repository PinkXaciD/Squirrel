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

struct CategoryEntityLocal: Identifiable, Equatable, Comparable {
    static func < (lhs: CategoryEntityLocal, rhs: CategoryEntityLocal) -> Bool {
        return lhs.sumUSDWithReturns < rhs.sumUSDWithReturns
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
