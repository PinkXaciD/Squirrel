//
//  ContentView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/06/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) 
    private var scenePhase
    @Environment(\.openURL)
    private var openURL
    
    @AppStorage("color")
    private var tint: String = "Orange"
    @AppStorage("theme")
    private var theme: String = "None"
    
    @StateObject
    private var cdm: CoreDataModel = .init()
    @StateObject
    private var rvm: RatesViewModel = .init()
    
    @ObservedObject 
    private var errorHandler = ErrorHandler.shared
    
    @Binding
    var addExpenseAction: Bool
        
    var body: some View {
        TabView {
            HomeView(showingSheet: $addExpenseAction)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            StatsSearchView()
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
        .onChange(of: scenePhase) { value in
            if value == .inactive {
                WidgetsManager.shared.reloadSumWidgets()
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
        ContentView(addExpenseAction: .constant(false))
    }
}
