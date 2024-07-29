//
//  ReturnEntity+CoreDataClass.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/11/30.
//
//

import Foundation
import CoreData

@objc(ReturnEntity)
public final class ReturnEntity: NSManagedObject, Codable {
    public enum CodingKeys: CodingKey {
        case id, amount, amountUSD, name, currency, date
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.moc] as? NSManagedObjectContext else {
            throw URLError(.badURL)
        }
        
        self.init(context: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.amount = try container.decode(Double.self, forKey: .amount)
        self.amountUSD = try container.decode(Double.self, forKey: .amountUSD)
        self.name = try container.decode(String.self, forKey: .name)
        self.currency = try container.decode(String.self, forKey: .currency)
        self.date = try container.decode(Date.self, forKey: .date)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(amount, forKey: .amount)
        try container.encode(amountUSD, forKey: .amountUSD)
        try container.encode(name, forKey: .name)
        try container.encode(currency, forKey: .currency)
        try container.encode(date, forKey: .date)
    }
}

extension ReturnEntity: ToSafeObject {
    func safeObject() -> TSReturnEntity {
        return TSReturnEntity(self)
    }
}

/// Thread-safe immutable structure, mirroring `ReturnEntity` CoreData class
struct TSReturnEntity: ToUnsafeObject, Hashable, Identifiable {
    let amount: Double
    let amountUSD: Double
    let currency: String?
    let date: Date?
    let id: UUID?
    let name: String?
    let spendingID: UUID?
    
    func unsafeObject(in context: NSManagedObjectContext) throws -> ReturnEntity {
        guard let id = self.id else {
            throw CoreDataError.failedToGetEntityDescription // TODO: Fix
        }
        
        return try context.performAndWait {
            let predicate = NSPredicate(format: "id == %@", id as NSUUID)
            let request = ReturnEntity.fetchRequest()
            request.predicate = predicate
            
            guard let unsafeEntity = try context.fetch(request).first else {
                throw CoreDataError.failedToFindCategory // TODO: Fix
            }
            
            return unsafeEntity
        }
    }
    
    /// Memberwise initializer
    /// - Important: You can crerate object with this initializer, but to convert created object to CoreData class you need to be sure that `id` you passed is valid and CoreData class with such id exists and can be fetched
    init(amount: Double, amountUSD: Double, currency: String?, date: Date?, id: UUID?, name: String?, spendingID: UUID?) {
        self.amount = amount
        self.amountUSD = amountUSD
        self.currency = currency
        self.date = date
        self.id = id
        self.name = name
        self.spendingID = spendingID
    }
    
    /// Creates thread-safe, immutable spending object from CoreData object
    /// - Parameter returnEntity: CoreData object
    /// - Important: While created object is thread-safe, this method is not, and should be called only from CoreData object's context
    init(_ returnEntity: ReturnEntity) {
        self.amount = returnEntity.amount
        self.amountUSD = returnEntity.amountUSD
        self.currency = returnEntity.currency
        self.date = returnEntity.date
        self.id = returnEntity.id
        self.name = returnEntity.name
        self.spendingID = returnEntity.spending?.wrappedId
    }
}
