//
//  LaunchActions.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/21.
//

import Foundation
import OSLog

func launch() -> Void {
    let logger = Logger(subsystem: "com.pinkxacid.financecontrol", category: "Launch Actions")
    let dateFormatter = ISO8601DateFormatter()
    dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    dateFormatter.timeZone = .gmt
    
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
