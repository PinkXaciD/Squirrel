//
//  CategoryEntity+CoreDataClass.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/31.
//
//

import Foundation
import CoreData
#if DEBUG
import OSLog
#endif

@objc(CategoryEntity)
public final class CategoryEntity: NSManagedObject, Codable {
    enum CodingKeys: CodingKey {
        case id, color, isShadowed, isFavorite, name, spendings
    }
    
    override public init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.moc] as? NSManagedObjectContext else {
            throw URLError(.badURL)
        }
        
        self.init(context: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Required fields
        do {
            self.id = try container.decode(UUID.self, forKey: .id)
            self.color = try container.decode(String.self, forKey: .color)
            self.name = try container.decode(String.self, forKey: .name)
        } catch {
            #if DEBUG
            Logger(subsystem: Vars.appIdentifier, category: #fileID).error("\(error)")
            #endif
            throw error
        }
        
        // Optional fields
        do {
            self.isShadowed = try container.decode(Bool.self, forKey: .isShadowed)
        } catch let DecodingError.keyNotFound(_, context) {
            self.isShadowed = false
            
            #if DEBUG
            let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
            logger.debug("\(context.debugDescription)")
            #endif
        }
        
        do {
            self.isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        } catch let DecodingError.keyNotFound(_, context) {
            self.isFavorite = false
            
            #if DEBUG
            let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
            logger.debug("\(context.debugDescription)")
            #endif
        }
        
        do {
            self.spendings = try container.decode(Set<SpendingEntity>.self, forKey: .spendings) as NSSet
        } catch let DecodingError.keyNotFound(_, context) {
            self.spendings = Set<SpendingEntity>() as NSSet
            
            #if DEBUG
            let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
            logger.debug("\(context.debugDescription)")
            #endif
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(color, forKey: .color)
        try container.encode(isShadowed, forKey: .isShadowed)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encode(name, forKey: .name)
        if let array = spendings?.allObjects as? [SpendingEntity] {
            try container.encode(array, forKey: .spendings)
        }
    }
}
