//
//  HomeView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/06/26.
//

import SwiftUI

struct HomeView: View {
    
    @State private var showingSheet = false
    
    var body: some View {
        
        NavigationView {
            List {
                Section {
                    BarChartGenerator()
                        .padding(.vertical)
                }
                
                Section {
                    addButton
                }
                .sheet(isPresented: $showingSheet) {
                    AmountInput()
                }
            }
            .navigationTitle("Home")
        }
        .navigationViewStyle(.stack)
    }
    
    var addButton: some View {
        Button(action: toggleSheet) {
            HStack(spacing: 15) {
                Image(systemName: "plus")
                    .imageScale(.large)
                Text("Add Expence")
            }
        }
        .padding()
    }
    
    func toggleSheet() {
        showingSheet.toggle()
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(CoreDataViewModel())
    }
}
