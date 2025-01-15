//
//  SettingsView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/10.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject
    private var cdm: CoreDataModel
    @EnvironmentObject
    private var rvm: RatesViewModel
    @EnvironmentObject
    private var kvsManager: CloudKitKVSManager
    
    @AppStorage(UDKey.color.rawValue)
    var defaultColor: String = "Orange"
    @AppStorage(UDKey.defaultCurrency.rawValue)
    var defaultCurrency: String = Locale.current.currencyCode ?? "USD"
    @AppStorage(UDKey.autoDarkMode.rawValue)
    private var autoDarkMode: Bool = true
    @AppStorage(UDKey.darkMode.rawValue)
    private var darkMode: Bool = false
    @AppStorage(UDKey.privacyScreen.rawValue)
    private var privacyScreenIsEnabled: Bool = false
    @State
    private var showDarkModeToggle: Bool = false
    
    @Binding
    var presentOnboarding: Bool
    let cloudSyncWasEnabled: Bool
    
    let version: String? = Bundle.main.releaseVersionNumber
    let build: String? = Bundle.main.buildVersionNumber
    
    var body: some View {
        if UIDevice.current.isIPad {
            if #available(iOS 16.0, *) {
                NavigationSplitView {
                    list
                } detail: {
                    NavigationStack {
                        ZStack {
                            Color(uiColor: .systemGroupedBackground)
                                .ignoresSafeArea()
                                
                            Text("Select a tab from sidebar")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .environmentObject(rvm)
                    .environmentObject(cdm)
                }
            } else {
                NavigationView {
                    list
                    
                    ZStack {
                        Color(uiColor: .systemGroupedBackground)
                            .ignoresSafeArea()
                            
                        
                        Text("Select a tab from sidebar")
                            .foregroundStyle(.secondary)
                    }
                }
                .onAppear {
                    withAnimation {
                        showDarkModeToggle = !autoDarkMode
                    }
                }
            }
        } else {
            NavigationView {
                list
            }
            .navigationViewStyle(.stack)
            .onAppear {
                withAnimation {
                    showDarkModeToggle = !autoDarkMode
                }
            }
        }
    }
    
    private var list: some View {
        List {
            aboutSection
            
            appearanceSection
            
            currencySection
            
//                shortcutsSection
            
            categorySection
            
            privacySection
            
            exportImportSection
        }
        .navigationTitle("Settings")
    }
    
    var aboutSection: some View {
        Section {
            NavigationLink("About") {
                aboutView
            }
        }
    }
    
    var aboutView: some View {
        AboutView(presentOnboarding: $presentOnboarding)
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
    }
    
    var appearanceSection: some View {
        Section {
            NavigationLink {
                ColorAndIconView()
            } label: {
                HStack {
                    Text("Color and Icon")
                    Spacer()
                    Text(LocalizedStringKey(defaultColor))
                        .foregroundStyle(.secondary)
                }
            }
            
            Toggle("Automatic Dark Mode", isOn: $autoDarkMode)
            
            if showDarkModeToggle {
                Toggle("Dark Mode", isOn: $darkMode)
                    .zIndex(0)
            }
            
            NavigationLink("Formatting") {
                SettingsFormattingView()
            }
            .zIndex(1)
        } header: {
            Text("Appearance")
        }
        .onChange(of: autoDarkMode) { newValue in
            withAnimation {
                showDarkModeToggle = !newValue
            }
            
            if newValue {
                UIApplication.shared.keyWindow?.overrideUserInterfaceStyle = .unspecified
            } else {
                UIApplication.shared.keyWindow?.overrideUserInterfaceStyle = darkMode ? .dark : .light
            }
        }
        .onChange(of: darkMode) { newValue in
            UIApplication.shared.keyWindow?.overrideUserInterfaceStyle = newValue ? .dark : .light
        }
    }
    
    var currencySection: some View {
        Section(header: Text("Currencies")) {
            NavigationLink {
                DefaultCurrencySelectorView()
            } label: {
                HStack {
                    Text("Currency")
                    
                    Spacer()
                    
                    Text("\(Locale.current.localizedString(forCurrencyCode: defaultCurrency) ?? defaultCurrency)")
                        .foregroundStyle(.secondary)
                }
            }
            
            NavigationLink("Rates", destination: RatesView())
        }
    }
    
    var categorySection: some View {
        Section(header: Text("Categories")) {
            NavigationLink("Categories") {
                CategoriesEditView()
            }
        }
    }
    
    private var privacySection: some View {
        Section {
            NavigationLink("Hide app content") {
                List {
                    Section {
                        Toggle("Hide app content in app switcher", isOn: $privacyScreenIsEnabled)
                    } header: {
                        BlurContentExample()
                    } footer: {
                        Text("Content will be blurred when you minimize the app")
                    }
                }
                .navigationTitle("Hide app content")
                .navigationBarTitleDisplayMode(.inline)
            }
        } header: {
            Text("Privacy")
        }
    }
    
    private var exportImportSection: some View {
        Section {
            NavigationLink {
                ICloudSyncView(cloudSyncWasEnabled: cloudSyncWasEnabled)
            } label: {
                HStack {
                    Text("iCloud sync")
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text(kvsManager.iCloudSync ? "On" : "Off")
                            .foregroundStyle(.secondary)
                        
                        if kvsManager.iCloudSync != cloudSyncWasEnabled {
                            Text("appication-restart-required-key")
                                .foregroundStyle(.red)
                                .font(.footnote)
                        }
                    }
                }
            }
            
            NavigationLink("Export and backup data") {
                ExportAndBackupView()
            }
        } header: {
            Text("Export and Backup")
        } footer: {
            footer
        }
    }
    
    var footer: some View {
        VStack(alignment: .center) {
            Text("Squirrel")
                .bold()
            
            Text("Ver. \(version ?? "")")
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

extension SettingsView {
    struct BlurContentExample: View {
        @State private var blur: CGFloat = 0
        
        var sum: Decimal {
            let sum = (10 * (Rates.fallback.rates[UserDefaults.standard.string(forKey: UDKey.defaultCurrency.rawValue) ?? Locale.current.currencyCode ?? "USD"] ?? 1))
            let count = "\(Int(sum))".count
            return pow(10, count - 1)
        }
        
        let defaultCurrency = UserDefaults.standard.string(forKey: UDKey.defaultCurrency.rawValue) ?? "USD"
        
        var body: some View {
            ZStack {
                VStack(spacing: 10) {
                    Text("Some expense")
                        .font(.headline)
                    
                    Text(sum.formatted(.currency(code: defaultCurrency)))
                        .font(.system(.title, design: .rounded).bold())
                }
                .padding(.vertical, 30)
                .padding(.horizontal, 30)
                .foregroundColor(.primary)
                .blur(radius: blur)
            }
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
                    .shadow(radius: 5)
            }
            .textCase(nil)
            .listRowInsets(.init(top: 50, leading: 0, bottom: 30, trailing: 0))
            .frame(maxWidth: .infinity, alignment: .center)
            .onAppear {
                withAnimation(.easeInOut.speed(0.5).delay(2).repeatForever()) {
                    blur = 10
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(presentOnboarding: .constant(false), cloudSyncWasEnabled: false)
            .environmentObject(CoreDataModel())
            .environmentObject(RatesViewModel())
    }
}
