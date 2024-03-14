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
    
    @AppStorage(UDKeys.color)
    private var tint: String = "Orange"
    @AppStorage(UDKeys.theme)
    private var theme: String = "None"
    
    @StateObject
    private var cdm: CoreDataModel
    @StateObject
    private var rvm: RatesViewModel = .init()
    @StateObject
    private var filtersViewModel: FiltersViewModel
    @StateObject
    private var pieChartViewModel: PieChartViewModel
    @StateObject
    private var statsListViewModel: StatsListViewModel
    @StateObject
    private var statsSearchViewModel: StatsSearchViewModel
    
    @ObservedObject 
    private var errorHandler = ErrorHandler.shared
    
    @Binding
    var addExpenseAction: Bool
    @AppStorage(UDKeys.presentOnboarding)
    private var presentOnboarding: Bool = true
    
    init(addExpenseAction: Binding<Bool>) {
        let coreDataModel = CoreDataModel()
        let pieChartViewModel = PieChartViewModel(cdm: coreDataModel)
        let filtersViewModel = FiltersViewModel(pcvm: pieChartViewModel)
        let statsSearchViewModel = StatsSearchViewModel()
        let statsListViewModel = StatsListViewModel(cdm: coreDataModel, fvm: filtersViewModel, pcvm: pieChartViewModel, searchModel: statsSearchViewModel)
        self._cdm = StateObject(wrappedValue: coreDataModel)
        self._pieChartViewModel = StateObject(wrappedValue: pieChartViewModel)
        self._filtersViewModel = StateObject(wrappedValue: filtersViewModel)
        self._statsListViewModel = StateObject(wrappedValue: statsListViewModel)
        self._statsSearchViewModel = StateObject(wrappedValue: statsSearchViewModel)
        self._addExpenseAction = addExpenseAction
    }
        
    var body: some View {
        TabView {
            HomeView(showingSheet: $addExpenseAction, presentOnboarding: $presentOnboarding)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            StatsSearchView()
                .environmentObject(pieChartViewModel)
                .environmentObject(filtersViewModel)
                .environmentObject(statsSearchViewModel)
                .environmentObject(statsListViewModel)
                .tabItem {
                    Label("Stats", systemImage: "chart.pie.fill")
                }
            
            SettingsView(presentOnboarding: $presentOnboarding)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .onChange(of: scenePhase) { value in
            if value == .inactive {
                WidgetsManager.shared.reloadSumWidgets()
            }
        }
        .environmentObject(cdm)
        .environmentObject(rvm)
        .sheet(isPresented: $presentOnboarding) {
            OnboardingView()
                .environmentObject(cdm)
                .accentColor(.orange)
                .interactiveDismissDisabled()
        }
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
