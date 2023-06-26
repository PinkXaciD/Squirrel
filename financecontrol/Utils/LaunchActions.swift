//
//  LaunchActions.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/21.
//

import Foundation
import SwiftUI

struct LaunchActions {
    @AppStorage("updateTime") var updateTime: String = dateConvertFromDate(Date.distantPast)
    @AppStorage("defaultCurrency") var defaultCurrency: String = "USD"
    
    func updateRates() {
            
        let currentDate = dateConvertFromDate(Date.now)
        
        if dateConvertFromString(updateTime) < Date.now.pastHour {
            print(dateConvertFromString(updateTime))
            print("Rates are not up to date")
            print("Last updated at: \(updateTime)")
            updateTime = dateConvertFromDate(Date.now)
            print("Updated to: \(updateTime)")
            print("Rates updated")
        } else {
            print("Rates are up to date")
            print("Current date: \(currentDate)")
            print("Updated at: \(updateTime)")
        }
    }
    
    func addCurrencies() {
        let vm = CoreDataViewModel()
        
        if vm.savedCurrencies == [] {
            vm.addCurrency(name: "US Dollar", tag: "USD", isFavorite: true)
            defaultCurrency = "USD"
        }
    }
}
