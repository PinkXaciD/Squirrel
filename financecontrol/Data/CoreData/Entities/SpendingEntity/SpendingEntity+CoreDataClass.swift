//
//  SpendingEntity+CoreDataClass.swift
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

public final class SpendingEntity: NSManagedObject, Codable {
    enum CodingKeys: CodingKey {
        case id, amount, amountUSD, comment, currency, date, place, returns, timeZoneIdentifier
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.moc] as? NSManagedObjectContext else {
            throw URLError(.badServerResponse)
        }
        
        self.init(context: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Required fields
        do {
            self.id = try container.decode(UUID.self, forKey: .id)
            self.amount = try container.decode(Double.self, forKey: .amount)
            self.amountUSD = try container.decode(Double.self, forKey: .amountUSD)
            self.currency = try container.decode(String.self, forKey: .currency)
            self.date = try container.decode(Date.self, forKey: .date)
        } catch {
            #if DEBUG
            print(error)
            #endif
            throw error
        }
        
        // Optional fields
        do {
            self.comment = try container.decode(String.self, forKey: .comment)
        } catch DecodingError.keyNotFound(_, let context) {
            self.comment = ""
            
            #if DEBUG
            let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
            logger.debug("\(context.debugDescription)")
            #endif
        }
        
        do {
            self.place = try container.decode(String.self, forKey: .place)
        } catch DecodingError.keyNotFound(_, let context) {
            self.place = ""
            
            #if DEBUG
            let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
            logger.debug("\(context.debugDescription)")
            #endif
        }
        
        do {
            self.returns = try container.decode(Set<ReturnEntity>.self, forKey: .returns) as NSSet
        } catch DecodingError.keyNotFound(_, let context) {
            self.returns = Set<ReturnEntity>() as NSSet
            
            #if DEBUG
            let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
            logger.debug("\(context.debugDescription)")
            #endif
        }
        
        do {
            self.timeZoneIdentifier = try container.decode(String?.self, forKey: .timeZoneIdentifier)
        } catch DecodingError.keyNotFound(_, let context) {
            self.timeZoneIdentifier = nil
            
            #if DEBUG
            let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
            logger.debug("\(context.debugDescription)")
            #endif
        } catch DecodingError.valueNotFound(_, let context) {
            self.timeZoneIdentifier = nil
            
            #if DEBUG
            let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
            logger.error("\(context.debugDescription)")
            #endif
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(amount, forKey: .amount)
        try container.encode(amountUSD, forKey: .amountUSD)
        try container.encode(comment, forKey: .comment)
        try container.encode(currency, forKey: .currency)
        try container.encode(date, forKey: .date)
        try container.encode(timeZoneIdentifier, forKey: .timeZoneIdentifier)
        try container.encode(place, forKey: .place)
        if let array = returns?.allObjects as? [ReturnEntity] {
            try container.encode(array, forKey: .returns)
        }
    }
}
