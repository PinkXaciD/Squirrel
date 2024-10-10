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
        case failedToDecodeResult, failedToGetResult, noValueFound, noEditDateFound, noRecordFound, networkUnavailable
        
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
    
    func fetchRates(timestamp recordName: String) async throws -> (editDate: Date, rates: Rates) {
        func getRatesRecord(recordName: CKRecord.ID) async throws -> CKRecord {
            do {
                return try await container.publicCloudDatabase.record(for: recordName)
            } catch CKError.unknownItem {
                #if DEBUG
                await MainActor.run {
                    CustomAlertManager.shared.addAlert(.init(type: .error, title: "No rates found", description: "\(recordName)", systemImage: "exclamationmark.circle"))
                }
                #endif
                
                return try await container.publicCloudDatabase.record(for: CKRecord.ID(recordName: "latest"))
            } catch CKError.networkUnavailable, CKError.serviceUnavailable {
                throw CloudKitError.networkUnavailable
            }
        }
        
        let record = try await getRatesRecord(recordName: CKRecord.ID(recordName: recordName))
        
        guard let rawRates = record.value(forKey: "rates") as? String else {
            throw CloudKitError.noValueFound
        }
        
        guard let ratesData = rawRates.data(using: .utf8) else {
            throw CloudKitError.failedToDecodeResult
        }
        
        guard let editDate = record.modificationDate else {
            throw CloudKitError.noEditDateFound
        }
        
        let decoder = JSONDecoder()
        
        let rates = try decoder.decode([String : Double].self, from: ratesData)
        
        if recordName == "latest" {
            let dateFormatter = DateFormatter.forRatesTimestamp
            
            let editDateString = dateFormatter.string(from: editDate)
            
            return (editDate, Rates(timestamp: editDateString, rates: rates))
        }
        
        return (editDate, Rates(timestamp: record.recordID.recordName, rates: rates))
    }
}
