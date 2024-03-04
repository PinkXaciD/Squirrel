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
    private var cdm: CoreDataModel
    @StateObject
    private var rvm: RatesViewModel = .init()
    @StateObject
    private var fvm: FiltersViewModel
    @StateObject
    private var pcvm: PieChartViewModel
    @StateObject
    private var searchModel: StatsSearchViewModel = StatsSearchViewModel()
    
    @ObservedObject 
    private var errorHandler = ErrorHandler.shared
    
    @Binding
    var addExpenseAction: Bool
    
    init(addExpenseAction: Binding<Bool>) {
        let cdm = CoreDataModel()
        let pcvm = PieChartViewModel(cdm: cdm)
        let fvm = FiltersViewModel(pcvm: pcvm)
        self._cdm = StateObject(wrappedValue: cdm)
        self._pcvm = StateObject(wrappedValue: pcvm)
        self._fvm = StateObject(wrappedValue: fvm)
        self._addExpenseAction = addExpenseAction
    }
        
    var body: some View {
        TabView {
            HomeView(showingSheet: $addExpenseAction)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            StatsSearchView()
                .environmentObject(pcvm)
                .environmentObject(fvm)
                .environmentObject(searchModel)
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
                    openURL(URLs.newGithubIssue)
                }
            }
            
            Button("OK", role: .cancel) {
                errorHandler.dropError()
            }
        } message: { error in
            Text("\(error.errorDescription)\n\(error.recoverySuggestion)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(addExpenseAction: .constant(false))
    }
}
