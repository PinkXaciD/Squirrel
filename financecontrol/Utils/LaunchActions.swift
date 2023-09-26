//
//  LaunchActions.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/21.
//

import Foundation

struct LaunchActions {
    
    init() {
        
        let currentDate = dateConvertFromDate(Date.now)
        let updateTime = UserDefaults.standard.string(forKey: "updateTime") ?? dateConvertFromDate(Date.distantPast)
        
        if dateConvertFromString(updateTime) < Date.now.pastHour {
            print("Rates are not up to date")
            print("Last updated at: \(updateTime)")
            UserDefaults.standard.set(true, forKey: "updateRates")
            let newUpdateTime: String = dateConvertFromDate(Date.now)
            UserDefaults.standard.set(newUpdateTime, forKey: "updateTime")
            print("Updated to: \(newUpdateTime)")
            print("Rates updated")
        } else {
            print("Rates are up to date")
            print("Current date: \(currentDate)")
            print("Updated at: \(updateTime)")
            print(dateConvertFromString(updateTime))
        }
    }
}
