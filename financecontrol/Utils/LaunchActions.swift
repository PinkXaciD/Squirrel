//
//  LaunchActions.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/21.
//

import Foundation

func launch() -> Void {
    var dateFormatter: ISO8601DateFormatter {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        f.timeZone = .gmt
        return f
    }
    
    let currentDate = dateFormatter.string(from: .now)
    let updateTime = UserDefaults.standard.string(forKey: "updateTime") ?? dateFormatter.string(from: .distantPast)
    
    if !Calendar.current.isDate(dateFormatter.date(from: updateTime) ?? .distantPast, equalTo: .now, toGranularity: .hour) {
        print("Rates are not up to date")
        print("Last updated at: \(updateTime)")
        UserDefaults.standard.set(true, forKey: "updateRates")
        print("Updating rates...")
    } else {
        print("Rates are up to date")
        print("Current date: \(currentDate)")
        print("Updated at: \(updateTime)")
    }
}
