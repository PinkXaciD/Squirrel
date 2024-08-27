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
        case failedToDecodeResult, failedToGetResult
        
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
