//
//  SquirrelApp.swift
//  Squirrel
//
//  Created by PinkXaciD on 2023/06/26.
//

import SwiftUI

@main
struct SquirrelApp: App {
    init() {
        Task { @MainActor in
            launch()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, DataManager.shared.context)
        }
    }
}
