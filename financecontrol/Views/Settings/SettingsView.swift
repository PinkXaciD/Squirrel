//
//  SettingsView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/10.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("color") var defaultColor: String = "Blue"
    @AppStorage("defaultCurrency") var defaultCurrency: String = "USD"
    @AppStorage("theme") var theme: String = "None"
    
    @State private var autoDarkModeToggle: Bool = true
    @State private var darkModeToggle: Bool = false
    
    let version: String? = Bundle.main.releaseVersionNumber
    
    var body: some View {
        NavigationView {
            List {
                
                aboutSection
                
                themeSection
                    .onAppear(perform: appearActions)
                    .onChange(of: autoDarkModeToggle) { newValue in
                        if newValue {
                            theme = "auto"
                        } else {
                            if darkModeToggle {
                                theme = "dark"
                            } else {
                                theme = "light"
                            }
                        }
                    }
                    .onChange(of: darkModeToggle) { newValue in
                        if newValue {
                            withAnimation {
                                theme = "dark"
                            }
                        } else {
                            withAnimation {
                                theme = "light"
                            }
                        }
                    }
                
                currencySection
                
                categorySection
            }
            .listStyle(.insetGrouped)
            .animation(.linear, value: autoDarkModeToggle)
            .navigationTitle("Settings")
        } // End of Nav View
        .navigationViewStyle(.stack)
    }
    
    var aboutSection: some View {
        Section {
            NavigationLink("About") {
                AboutView()
                    .navigationTitle("About")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    var themeSection: some View {
        Section(header: Text("Accent color and dark mode")) {
            NavigationLink {
                UiColorSelector()
                
            } label: {
                HStack {
                    Text("Color")
                    Spacer()
                    Text("\(defaultColor)")
                        .foregroundColor(Color.secondary)
                }
            }
            
            Toggle("Automatic Dark Mode", isOn: $autoDarkModeToggle)
            
            if !autoDarkModeToggle {
                Toggle("Dark Mode", isOn: $darkModeToggle)
            }
            
        }
    }
    
    var currencySection: some View {
        Section(header: Text("Currencies")) {
            NavigationLink {
                DefaultCurrencySelector()
                
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
    
    var categorySection: some View {
        Section(header: Text("Categories"), footer: footer) {
            NavigationLink("Categories") {
                CategoriesEditView()
            }
            
        }
    }
    
    var footer: some View {
        HStack {
            Spacer()
            
            VStack {
                Text("🐿️")
                    .font(.largeTitle)
                    .padding(.bottom, 5)
                
                Text("Squirrel")
                    .bold()
                
                Text("Ver. \(version ?? "") α")
            }
            .padding()
            
            Spacer()
        }
    }
}

extension SettingsView {
    func appearActions() {
        if theme == "light" {
            autoDarkModeToggle = false
            darkModeToggle = false
        } else if theme == "dark" {
            autoDarkModeToggle = false
            darkModeToggle = true
        } else {
            autoDarkModeToggle = true
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(CoreDataViewModel())
    }
}
