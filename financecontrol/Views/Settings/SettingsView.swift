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
                
                NavigationLink {
                    
                    AboutView()
                        .navigationTitle("About")
                        .navigationBarTitleDisplayMode(.inline)
                    
                } label: {
                    
                    Text("About")
                    
                }
                
                Section {
                    
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
                    
                } header: {
                    
                    Text("accent color and dark mode")
                    
                }
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
                
                Section {
                    
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
                    
                } header: {
                    
                    Text("currency")
                    
                }
                
                Section {
                    
                    NavigationLink("Categories") {
                        
                        CategoriesEditView()
                        
                    }
                    
                } header: {
                    
                    Text("categories")
                    
                } footer: {
                    
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
            .listStyle(.insetGrouped)
            .animation(.linear, value: autoDarkModeToggle)
            .navigationTitle("Settings") 
        } // End of Nav View
        .navigationViewStyle(.stack)
    }
    
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
