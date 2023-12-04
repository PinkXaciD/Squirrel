//
//  LaunchActions.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/21.
//

import Foundation

class LaunchActions {
    init() {}
    
    func launch() -> Void {
        let dateFormatter: ISO8601DateFormatter = .init()
        
        let currentDate = dateFormatter.string(from: .now)
        let updateTime = UserDefaults.standard.string(forKey: "updateTime") ?? dateFormatter.string(from: .distantPast)
        
        if !Calendar.current.isDate(dateFormatter.date(from: updateTime) ?? .distantPast, equalTo: .now, toGranularity: .hour) {
            print("Rates are not up to date")
            print("Last updated at: \(updateTime)")
            UserDefaults.standard.set(true, forKey: "updateRates")
            let newUpdateTime: String = dateFormatter.string(from: .now)
            UserDefaults.standard.set(newUpdateTime, forKey: "updateTime")
            print("Updated to: \(newUpdateTime)")
            print("Rates updated")
        } else {
            print("Rates are up to date")
            print("Current date: \(currentDate)")
            print("Updated at: \(updateTime)")
        }
    }
}
