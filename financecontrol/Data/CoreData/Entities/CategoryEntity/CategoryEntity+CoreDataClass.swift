//
//  CategoryEntity+CoreDataClass.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/31.
//
//

import Foundation
import CoreData

@objc(CategoryEntity)
public final class CategoryEntity: NSManagedObject, Codable {
    enum CodingKeys: CodingKey {
        case id, color, isShadowed, isFavorite, name, spendings
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.moc] as? NSManagedObjectContext else {
            throw URLError(.badURL)
        }
        
        self.init(context: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.color = try container.decode(String.self, forKey: .color)
        self.isShadowed = try container.decode(Bool.self, forKey: .isShadowed)
        self.isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        self.name = try container.decode(String.self, forKey: .name)
        self.spendings = try container.decode(Set<SpendingEntity>.self, forKey: .spendings) as NSSet
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
