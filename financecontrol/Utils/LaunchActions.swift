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
    let logger = Logger(subsystem: Vars.appIdentifier, category: "Launch Actions")
    #endif
    let dateFormatter = ISO8601DateFormatter()
    dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    dateFormatter.timeZone = .init(identifier: "GMT")
    
    let currentDate = dateFormatter.string(from: .now)
    let updateTime = UserDefaults.standard.string(forKey: "updateTime") ?? dateFormatter.string(from: .distantPast)
    
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
}
