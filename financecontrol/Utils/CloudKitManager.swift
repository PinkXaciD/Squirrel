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
            switch self {
            case .networkUnavailable:
                "Network Unavailable"
            default:
                "CloudKit error \(self.rawValue)"
            }
        }
        
        var recoverySuggestion: String? {
            "Try to restart the app"
        }
        
        var failureReason: String? {
            "CloudKitError.\(self.rawValue)"
        }
    }
    
    @Published
    private(set) var accountStatus: CKAccountStatus?
    
    private let container = CKContainer(identifier: "iCloud.dev.squirrelapp.squirrel")
    private let cloudKitCoreDataZoneID = CKRecordZone.ID(zoneName: "com.apple.coredata.cloudkit.zone")
    
    #if DEBUG
    private let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
    #endif
    
    fileprivate init() {
        #if DEBUG
        logger.debug("CloudKitManager init")
        #endif
        
        container.accountStatus { [weak self] status, error in
            if let error {
                ErrorType(error: error).publish()
            }
            
            self?.accountStatus = status
            
            if NSUbiquitousKeyValueStore.default.bool(forKey: UDKey.iCloudSync.rawValue), status != .available {
                NSUbiquitousKeyValueStore.default.set(false, forKey: UDKey.iCloudSync.rawValue)
                
                DispatchQueue.main.async {
                    CustomAlertManager.shared.addAlert(
                        .init(type: .error, title: "iCloud sync turned off", description: "Sign in your iCloud account on device or allow Squirrel to use iCloud in settings.", systemImage: "exclamationmark.icloud.fill")
                    )
                }
            }
        }
        
        Task { [weak self] in
            await self?.updateCloudKitContent()
        }
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
            } catch CKError.networkUnavailable, CKError.serviceUnavailable, CKError.networkFailure {
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
    
    func updateCloudKitContent(forceUpdate: Bool = false) async {
        let publicDB = container.publicCloudDatabase
        
        let urlVersion = try? await publicDB.record(for: CKRecord.ID(recordName: "AllURLUpdateVersion"))
        let socialVersion = try? await publicDB.record(for: CKRecord.ID(recordName: "AllSocialNetworksUpdateVersion"))
        
        if let urlVersion, let value = urlVersion.value(forKey: "value") as? Int {
            if (value > UserDefaults.standard.integer(forKey: UDKey.urlUpdateVersion.rawValue)) || forceUpdate {
                await self.updateAppURLS(urlVersion: value)
            }
        }
        
        if let socialVersion, let value = socialVersion.value(forKey: "value") as? Int {
            if (value > UserDefaults.standard.integer(forKey: UDKey.socialNetworksUpdateVersion.rawValue)) || forceUpdate {
                await self.updateSocialNetworks(socialVersion: value)
            }
        }
    }
    
    private func updateAppURLS(urlVersion: Int) async {
        let publicDB = container.publicCloudDatabase
        var count = 0
        let udKeys = UDKey.urlKeys
        
        var ckIDs: [CKRecord.ID] {
            var result = [CKRecord.ID]()
            result.reserveCapacity(udKeys.count)
            
            for key in udKeys {
                if let ckID = key.ckID {
                    result.append(CKRecord.ID(recordName: ckID))
                }
            }
            
            return result
        }
        
        let records = try? await publicDB.records(for: ckIDs)
        
        for key in udKeys {
            guard let ckID = key.ckID else {
                continue
            }
            
            guard let record = records?[CKRecord.ID(recordName: ckID)] else {
                continue
            }
            
            guard let urlString = try? record.get().value(forKey: "urlString") as? String else {
                continue
            }
            
            guard let url = URL(string: urlString) else {
                continue
            }
            
            UserDefaults.standard.set(url, forKey: key.rawValue)
            count += 1
            
            #if DEBUG
            logger.info("URL \(url.absoluteString) is saved for key \(key.rawValue)")
            #endif
        }
        
        if count == ckIDs.count {
            UserDefaults.standard.set(urlVersion, forKey: UDKey.urlUpdateVersion.rawValue)
        }
        
        #if DEBUG
        logger.info("URLs updated to version \(urlVersion.description)")
        #endif
    }
    
    private func updateSocialNetworks(socialVersion: Int) async {
        let publicDB = container.publicCloudDatabase
        
        do {
            let record = try await publicDB.record(for: CKRecord.ID(recordName: "SocialNetworks"))
            guard let string = record.value(forKey: "content") as? String else { return }
            guard let data = string.data(using: .utf8) else { return }
            UserDefaults.standard.set(data, forKey: UDKey.socialNetworksJSON.rawValue)
            UserDefaults.standard.set(socialVersion, forKey: UDKey.socialNetworksUpdateVersion.rawValue)
        } catch {}
    }
    
    func dropUserDataFromPublicDatabase() async throws {
        guard accountStatus == .available else {
            return
        }
        
        let zoneIDs = try await container.privateCloudDatabase.allRecordZones()
        
        if zoneIDs.contains(where: { $0.zoneID == cloudKitCoreDataZoneID }) {
            try await container.privateCloudDatabase.deleteRecordZone(withID: cloudKitCoreDataZoneID)
            HapticManager.shared.notification(.success)
        }
    }
    
    func hasDataInCloudKit() async -> Bool {
        guard accountStatus == .available else {
            return false
        }
        
        let zoneIDs = try? await container.privateCloudDatabase.allRecordZones()
        
        guard let zoneIDs else { return true }
        
        return zoneIDs.contains(where: { $0.zoneID == cloudKitCoreDataZoneID })
    }
}

// MARK: Singleton
extension CloudKitManager {
    static let shared = CloudKitManager()
}
