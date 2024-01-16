//
//  financecontrolApp.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/06/26.
//

import SwiftUI

@main
struct financecontrolApp: App {
    @State private var addExpenseAction: Bool = false
    
    init() {
        launch()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(addExpenseAction: $addExpenseAction)
                .onOpenURL { url in
                    guard 
                        url.scheme == "financecontrol"
                    else {
                        return
                    }
                    
                    addExpenseAction = true
                }
        }
    }
}
