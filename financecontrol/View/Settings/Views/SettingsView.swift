//
//  SettingsView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/10.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage(UDKeys.color)
    var defaultColor: String = "Orange"
    @AppStorage(UDKeys.defaultCurrency)
    var defaultCurrency: String = Locale.current.currencyCode ?? "USD"
    @AppStorage(UDKeys.autoDarkMode)
    private var autoDarkMode: Bool = true
    @AppStorage(UDKeys.darkMode)
    private var darkMode: Bool = false
    @State
    private var showDarkModeToggle: Bool = false
    
    @State
    private var presentCustomAlert: Bool = false
    @State
    private var customAlertMessage: Text = .init("")
    @State
    private var customAlertType: CustomAlertType = .unknown
    
    @Binding
    var presentOnboarding: Bool
    
    let version: String? = Bundle.main.releaseVersionNumber
    let build: String? = Bundle.main.buildVersionNumber
    
    var body: some View {
        NavigationView {
            List {
                aboutSection
                
                themeSection
                
                currencySection
                
//                shortcutsSection
                
                categorySection
                
                exportImportSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
        }
        .navigationViewStyle(.stack)
        .customAlert(customAlertType, presenting: $presentCustomAlert, message: customAlertMessage)
        .onAppear {
            withAnimation {
                showDarkModeToggle = !autoDarkMode
            }
        }
    }
    
    var aboutSection: some View {
        Section {
            NavigationLink("About") {
                AboutView(presentOnboarding: $presentOnboarding)
                    .navigationTitle("About")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    var themeSection: some View {
        Section {
            NavigationLink {
                ColorAndIconView()
            } label: {
                HStack {
                    Text("Color and Icon")
                    Spacer()
                    Text(LocalizedStringKey(defaultColor))
                        .foregroundColor(Color.secondary)
                }
            }
            
            Toggle("Automatic Dark Mode", isOn: $autoDarkMode)
            
            if showDarkModeToggle {
                Toggle("Dark Mode", isOn: $darkMode)
            }
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
                    Text("Currencies")
                    
                    Spacer()
                    
                    Text("Default: \(defaultCurrency)")
                        .foregroundColor(Color.secondary)
                }
            }
            
            NavigationLink("Rates", destination: RatesView())
        }
    }
    
    private var shortcutsSection: some View {
        Section {
            NavigationLink("Shortcuts (beta)") {
                AddSpendingShortcutListView()
            }
        } header: {
            Text("Shortcuts (beta)")
        }
    }
    
    var categorySection: some View {
        Section(header: Text("Categories")) {
            NavigationLink("Categories") {
                CategoriesEditView()
            }
        }
    }
    
    private var exportImportSection: some View {
        Section(header: Text("Export and Import"), footer: footer) {
            NavigationLink("Export and import data") {
                ExportImportView(presentAlert: $presentCustomAlert, alertMessage: $customAlertMessage, alertType: $customAlertType)
            }
        }
    }
    
    var footer: some View {
        VStack(alignment: .center) {
            Text("Squirrel")
                .bold()
            
            Text("Ver. \(version ?? "") (\(build ?? ""))")
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

//extension SettingsView {
//    func appearActions() {
//        if theme == "light" {
//            autoDarkMode = false
//            darkMode = false
//        } else if theme == "dark" {
//            autoDarkMode = false
//            darkMode = true
//        } else {
//            autoDarkMode = true
//        }
//    }
//}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(presentOnboarding: .constant(false))
            .environmentObject(CoreDataModel())
    }
}
