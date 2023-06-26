//
//  ContentView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/06/26.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("color") var tint: String = "Blue"
    @AppStorage("theme") var theme: String = "None"
    @StateObject private var vm = CoreDataViewModel()
    @StateObject private var rvm = RatesViewModel(update: true)
    
    
    var body: some View {
        
        TabView {
            HomeView()
                .environmentObject(vm)
                .environmentObject(rvm)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            StatsView()
                .environmentObject(vm)
                .environmentObject(rvm)
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("Stats")
                }
            SettingsView()
                .environmentObject(vm)
                .environmentObject(rvm)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
        .tint(colorIdentifier(color: tint))
        .preferredColorScheme(themeConvert(theme))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
