//
//  ContentView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/06/26.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("color") var tint: String = "Orange"
    @AppStorage("theme") var theme: String = "None"
    @StateObject private var cdm: CoreDataModel = .init()
    @StateObject private var rvm: RatesViewModel = .init()
    
    @ObservedObject private var errorHandler = ErrorHandler.shared
    @Environment(\.openURL) private var openURL
        
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            StatsView()
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("Stats")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
        .environmentObject(cdm)
        .environmentObject(rvm)
        .tint(colorIdentifier(color: tint))
        .accentColor(colorIdentifier(color: tint))
        .preferredColorScheme(themeConvert(theme))
        .alert(
            "Something went wrong...",
            isPresented: $errorHandler.showAlert,
            presenting: errorHandler.appError
        ) { error in
            if error.createIssue {
                Button("Create an issue on GitHub") {
                    errorHandler.dropError()
                    openURL(URL(string: "https://github.com/PinkXaciD/Squirrel/issues/new")!)
                }
            }
            
            Button("OK", role: .cancel) {
                errorHandler.dropError()
            }
        } message: { error in
            Text("\(error.errorDescription).\n\(error.recoverySuggestion)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
