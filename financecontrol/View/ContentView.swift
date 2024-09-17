
//
//  ContentView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/06/26.
//

import SwiftUI
#if DEBUG
import OSLog
#endif

struct ContentView: View {
    @Environment(\.scenePhase) 
    private var scenePhase
    @Environment(\.openURL)
    private var openURL
    
    @AppStorage(UDKeys.presentOnboarding.rawValue)
    private var presentOnboarding: Bool = true
    @AppStorage(UDKeys.color.rawValue)
    private var tint: String = "Orange"
    @AppStorage(UDKeys.autoDarkMode.rawValue)
    private var autoDarkMode: Bool = true
    @AppStorage(UDKeys.darkMode.rawValue)
    private var darkMode: Bool = false
    @AppStorage(UDKeys.privacyScreen.rawValue)
    private var privacyScreenIsEnabled: Bool = false
    
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
    @StateObject
    private var privacyMonitor: PrivacyMonitor = PrivacyMonitor(privacyScreenIsEnabled: false, hideExpenseSum: false)
    @StateObject
    private var statsViewModel: StatsViewModel = StatsViewModel()
    
    @ObservedObject 
    private var errorHandler = ErrorHandler.shared
    
    @State
    private var addExpenseAction: Bool = false
    @State
    private var hideContent: Bool = false
    
    init() {
        let coreDataModel = CoreDataModel()
        let filtersViewModel = FiltersViewModel()
        let pieChartViewModel = PieChartViewModel(cdm: coreDataModel, fvm: filtersViewModel)
        let statsSearchViewModel = StatsSearchViewModel()
        let statsListViewModel = StatsListViewModel(cdm: coreDataModel, fvm: filtersViewModel, pcvm: pieChartViewModel, searchModel: statsSearchViewModel)
        self._cdm = StateObject(wrappedValue: coreDataModel)
        self._pieChartViewModel = StateObject(wrappedValue: pieChartViewModel)
        self._filtersViewModel = StateObject(wrappedValue: filtersViewModel)
        self._statsListViewModel = StateObject(wrappedValue: statsListViewModel)
        self._statsSearchViewModel = StateObject(wrappedValue: statsSearchViewModel)
    }
        
    var body: some View {
        NavigationView {
            TabView {
                homeTab
                
                statsTab
                
                settingsTab
            }
        }
        .blur(radius: hideContent ? Vars.privacyBlur : 0)
        .animation(.easeOut(duration: 0.1), value: hideContent)
        .ignoresSafeArea()
        .onOpenURL { url in
            if url == URLs.addExpenseAction {
                addExpenseAction = true
            }
        }
        .onChange(of: scenePhase) { value in
            scenePhaseChange(value)
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
//        .preferredColorScheme(themeConvert(autoDarkMode: autoDarkMode, darkMode: darkMode))
        .onAppear {
            setColorScheme()
        }
        .customAlert()
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
        .styleListsToDynamicType()
    }
    
    private var homeTab: some View {
        HomeView(showingSheet: $addExpenseAction, presentOnboarding: $presentOnboarding)
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
    }
    
    private var statsTab: some View {
        StatsView()
            .environmentObject(pieChartViewModel)
            .environmentObject(filtersViewModel)
            .environmentObject(statsSearchViewModel)
            .environmentObject(statsListViewModel)
            .environmentObject(privacyMonitor)
            .environmentObject(statsViewModel)
            .sheet(item: $statsViewModel.entityToEdit) { entity in
                SpendingCompleteView(
                    edit: $statsViewModel.edit,
                    entity: entity
                )
                .smallSheet(0.7)
                .environmentObject(privacyMonitor)
                .environmentObject(cdm)
                .environmentObject(rvm)
            }
            .sheet(item: $statsViewModel.entityToAddReturn) { entity in
                AddReturnView(spending: entity, cdm: cdm, rvm: rvm)
                    .accentColor(colorIdentifier(color: tint))
                    .tint(colorIdentifier(color: tint))
            }
            .tabItem {
                Label("Stats", systemImage: "chart.pie.fill")
            }
    }
    
    private var settingsTab: some View {
        SettingsView(presentOnboarding: $presentOnboarding)
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
    }
    
    private func setColorScheme() {
        if !autoDarkMode {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            let window = windowScene?.windows.first
            window?.overrideUserInterfaceStyle = darkMode ? .dark : .light
        }
    }
    
    private func scenePhaseChange(_ value: ScenePhase) {
        if value == .inactive {
            WidgetsManager.shared.reloadSumWidgets()
            WidgetsManager.shared.updateAccentColor()
        }
        
        if privacyScreenIsEnabled {
            hideContent = value != .active
        }
        
        privacyMonitor.changePrivacyScreenValue(value != .active)
        
        if value == .active {
            rvm.checkForUpdate()
            
            if !Calendar.current.isDateInToday(cdm.lastFetchDate) {
                cdm.fetchSpendings(updateWidgets: false)
            }
            
            #if DEBUG
            Logger(subsystem: Vars.appIdentifier, category: #fileID).log("Moved to foreground, CD last fetch: \(cdm.lastFetchDate.formatted())")
            #endif
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
