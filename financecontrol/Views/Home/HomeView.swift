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
                barChartSection
                
                addButton
                    .sheet(isPresented: $showingSheet) {
                        AddSpendingView()
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
                Text("Add Expense")
            }
        }
        .padding()
    }
    
    var barChartSection: some View {
        Section {
            BarChartGenerator()
                .padding(.vertical)
        }
    }
}

extension HomeView {
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
