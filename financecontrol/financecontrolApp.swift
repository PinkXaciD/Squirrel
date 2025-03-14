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
        launch()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, DataManager.shared.context)
        }
    }
}
