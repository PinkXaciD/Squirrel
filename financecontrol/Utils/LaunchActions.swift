//
//  LaunchActions.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/21.
//

import Foundation
#if DEBUG
import OSLog
#endif

func launch() {
    let dateFormatter = ISO8601DateFormatter()
    #if DEBUG
    let _ = CloudKitManager.shared
    #endif
    
    // MARK: Rates update scheduling
    let updateTime = UserDefaults.standard.string(forKey: UDKey.updateTime.rawValue) ?? dateFormatter.string(from: .distantPast)
    
    if !Calendar.current.isDate(dateFormatter.date(from: updateTime) ?? .distantPast, equalTo: .now, toGranularity: .hour) {
        #if DEBUG
        let logger = Logger(subsystem: Vars.appIdentifier, category: "\(#fileID)")
        logger.debug("Rates aren't up to date")
        logger.debug("Last updated at: \(updateTime)")
        logger.info("Updating rates...")
        #endif
        
        UserDefaults.standard.set(true, forKey: "updateRates")
    }
    
    // MARK: Currency checks
    if UserDefaults.standard.string(forKey: UDKey.defaultCurrency.rawValue) == nil {
        UserDefaults.standard.set(Locale.current.currencyCode ?? "USD", forKey: UDKey.defaultCurrency.rawValue)
    }
    
    if let sharedDefaults = UserDefaults(suiteName: Vars.groupName), sharedDefaults.string(forKey: UDKey.defaultCurrency.rawValue) == nil {
        sharedDefaults.set(Locale.current.currencyCode ?? "USD", forKey: UDKey.defaultCurrency.rawValue)
        WidgetsManager.shared.reloadSumWidgets()
    }
}
