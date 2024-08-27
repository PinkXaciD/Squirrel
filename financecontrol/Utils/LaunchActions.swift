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

func launch() -> Void {
    #if DEBUG
    let logger = Logger(subsystem: Vars.appIdentifier, category: "\(#fileID)")
    #endif
    let dateFormatter = ISO8601DateFormatter()
    dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    dateFormatter.timeZone = .init(identifier: "GMT")
    
    // MARK: Rates update scheduling
    let currentDate = dateFormatter.string(from: .now)
    let updateTime = UserDefaults.standard.string(forKey: UDKeys.updateTime.rawValue) ?? dateFormatter.string(from: .distantPast)
    
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
    
    if UserDefaults.standard.string(forKey: UDKeys.defaultCurrency.rawValue) == nil {
        UserDefaults.standard.set(Locale.current.currencyCode ?? "USD", forKey: UDKeys.defaultCurrency.rawValue)
    }
    
    if let sharedDefaults = UserDefaults(suiteName: Vars.groupName), sharedDefaults.string(forKey: UDKeys.defaultCurrency.rawValue) == nil {
        sharedDefaults.set(Locale.current.currencyCode ?? "USD", forKey: UDKeys.defaultCurrency.rawValue)
        WidgetsManager.shared.reloadSumWidgets()
    }
    
    // TODO: Remove
//    #if DEBUG
//    UserDefaults.standard.set(true, forKey: "updateRates")
//    #endif
    
    // MARK: Theme migration
    if let theme = UserDefaults.standard.string(forKey: "theme") {
        switch theme {
        case "dark":
            UserDefaults.standard.setValue(false, forKey: UDKeys.autoDarkMode.rawValue)
            UserDefaults.standard.setValue(true, forKey: UDKeys.darkMode.rawValue)
            #if DEBUG
            logger.debug("Dark mode was enabled, migrated")
            #endif
        case "light":
            UserDefaults.standard.setValue(false, forKey: UDKeys.autoDarkMode.rawValue)
            UserDefaults.standard.setValue(false, forKey: UDKeys.darkMode.rawValue)
            #if DEBUG
            logger.debug("Light mode was enabled, migrated")
            #endif
        default:
            UserDefaults.standard.setValue(true, forKey: UDKeys.autoDarkMode.rawValue)
            UserDefaults.standard.setValue(false, forKey: UDKeys.darkMode.rawValue)
            #if DEBUG
            logger.debug("Auto mode was enabled, migrated")
            #endif
        }
        
        UserDefaults.standard.setValue(nil, forKey: "theme")
    }
}
