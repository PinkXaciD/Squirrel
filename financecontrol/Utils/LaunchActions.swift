//
//  LaunchActions.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/21.
//

import Foundation
import UIKit
#if DEBUG
import OSLog
#endif

func launch() -> Void {
    #if DEBUG
    let logger = Logger(subsystem: Vars.appIdentifier, category: "\(#fileID)")
    #endif
    let dateFormatter = ISO8601DateFormatter()
    dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    dateFormatter.timeZone = .init(identifier: "GMT")
    
    let currentDate = dateFormatter.string(from: .now)
    let updateTime = UserDefaults.standard.string(forKey: UDKeys.updateTime) ?? dateFormatter.string(from: .distantPast)
    
    if !Calendar.current.isDate(dateFormatter.date(from: updateTime) ?? .distantPast, equalTo: .now, toGranularity: .hour) {
        #if DEBUG
        logger.debug("Rates aren't up to date")
        logger.debug("Last updated at: \(updateTime)")
        logger.info("Updating rates...")
        #endif
        UserDefaults.standard.set(true, forKey: "updateRates")
    } else {
        #if DEBUG
        logger.debug("Rates are up to date")
        logger.debug("Current date: \(currentDate)")
        logger.debug("Updated at: \(updateTime)")
        #endif
    }
    
    if UserDefaults.standard.string(forKey: UDKeys.defaultCurrency) == nil {
        UserDefaults.standard.setValue(Locale.current.currencyCode ?? "USD", forKey: UDKeys.defaultCurrency)
    }
    
    // MARK: Theme migration
    if let theme = UserDefaults.standard.string(forKey: "theme") {
        switch theme {
        case "dark":
            UserDefaults.standard.setValue(false, forKey: UDKeys.autoDarkMode)
            UserDefaults.standard.setValue(true, forKey: UDKeys.darkMode)
            #if DEBUG
            logger.debug("Dark mode was enabled, migrated")
            #endif
        case "light":
            UserDefaults.standard.setValue(false, forKey: UDKeys.autoDarkMode)
            UserDefaults.standard.setValue(false, forKey: UDKeys.darkMode)
            #if DEBUG
            logger.debug("Light mode was enabled, migrated")
            #endif
        default:
            UserDefaults.standard.setValue(true, forKey: UDKeys.autoDarkMode)
            UserDefaults.standard.setValue(false, forKey: UDKeys.darkMode)
            #if DEBUG
            logger.debug("Auto mode was enabled, migrated")
            #endif
        }
        
        UserDefaults.standard.setValue(nil, forKey: "theme")
    } else {
        #if DEBUG
        logger.debug("Nothing to migrate")
        #endif
    }
}
