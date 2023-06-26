//
//  financecontrolApp.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/06/26.
//

import SwiftUI

@main
struct financecontrolApp: App {
    init() {
        LaunchActions().updateRates()
        LaunchActions().addCurrencies()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
