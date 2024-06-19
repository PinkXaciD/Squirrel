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
                .environmentObject(privacyMonitor)
                .tabItem {
                    Label("Stats", systemImage: "chart.pie.fill")
                }
            
            SettingsView(presentOnboarding: $presentOnboarding)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .blur(radius: hideContent ? Vars.privacyBlur : 0)
        .ignoresSafeArea()
        .onOpenURL { url in
            if url == URLs.addExpenseAction {
                addExpenseAction = true
            }
        }
        .onChange(of: scenePhase) { value in
            if value == .inactive {
                WidgetsManager.shared.reloadSumWidgets()
            }
            
            if privacyScreenIsEnabled {
                if value == .active {
                    withAnimation(.easeOut(duration: 0.2)) {
                        hideContent = false
                    }
                } else {
                    withAnimation {
                        hideContent = true
                    }
                }
            }
            
            privacyMonitor.changePrivacyScreenValue(value != .active)
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
        .preferredColorScheme(themeConvert(autoDarkMode: autoDarkMode, darkMode: darkMode))
        .onAppear {
            setColorScheme()
        }
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
    
    private func setColorScheme() {
        if !autoDarkMode {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            let window = windowScene?.windows.first
            window?.overrideUserInterfaceStyle = darkMode ? .dark : .light
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
