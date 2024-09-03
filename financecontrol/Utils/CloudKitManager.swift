//
//  CloudKitManager.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/07/22.
//

import CloudKit
#if DEBUG
import OSLog
#endif

final class CloudKitManager {
    enum CloudKitError: String, LocalizedError {
        case failedToDecodeResult, failedToGetResult, noValueFound
        
        var errorDescription: String? {
            "CloudKit error \(self.rawValue)"
        }
        
        var recoverySuggestion: String? {
            "Try to restart the app"
        }
        
        var failureReason: String? {
            "CloudKitError.\(self.rawValue)"
        }
    }
    
    private let container = CKContainer(identifier: "iCloud.dev.squirrelapp.squirrel")
    
    #if DEBUG
    let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
    #endif
    
    init() {
        #if DEBUG
        logger.debug("CloudKitManager init")
        #endif
    }
    
    deinit {
        #if DEBUG
        logger.debug("CloudKitManager deinit")
        #endif
    }
    
    func fetchAPIKey() async throws -> String {
        let publicDb = container.publicCloudDatabase
        let predicate = NSPredicate(format: "APIName == %@", "Rates" as CVarArg)
        let query = CKQuery(recordType: "APIKey", predicate: predicate)
        
        do {
            return try completionHandler(try await publicDb.records(matching: query))
        } catch {
            throw error
        }
    }
    
    func fetchRates(timestamp recordName: String) async throws -> Rates {
        let publicDB = container.publicCloudDatabase
        
        let result = try await publicDB.record(for: CKRecord.ID(recordName: recordName))
        
        guard let rawRates = result.value(forKey: "rates") as? String else {
            throw CloudKitError.noValueFound
        }
        
        guard let ratesData = rawRates.data(using: .utf8) else {
            throw CloudKitError.failedToDecodeResult
        }
        
        let decoder = JSONDecoder()
        
        let rates = try decoder.decode([String : Double].self, from: ratesData)
        
        if recordName == "latest" {
            let isoDateFormatter = ISO8601DateFormatter()
            isoDateFormatter.timeZone = .init(secondsFromGMT: 0) ?? .current
            
            let gmtCalendar = Calendar.gmt
            let currentHour = gmtCalendar.component(.hour, from: .now)
            let currentTime = gmtCalendar.date(bySettingHour: currentHour, minute: 0, second: 0, of: .now) ?? gmtCalendar.startOfDay(for: .now)
            
            let currentTimeString = isoDateFormatter.string(from: currentTime)
            
            return Rates(timestamp: currentTimeString, rates: rates)
        }
        
        return Rates(timestamp: result.recordID.recordName, rates: rates)
    }
    
    private func completionHandler(
        _ input: (matchResults: [(CKRecord.ID, Result<CKRecord, any Error>)], queryCursor: CKQueryOperation.Cursor?)
    ) throws -> String {
        do {
            let result = input.matchResults.first
            
            guard let result else {
                throw CloudKitError.failedToGetResult
            }
            
            guard let value = try result.1.get().value(forKey: "Value") as? String else {
                throw CloudKitError.failedToDecodeResult
            }
            
            return value
        } catch {
            throw error
        }
    }
}
