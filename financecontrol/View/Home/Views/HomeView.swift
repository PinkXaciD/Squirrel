//
//  HomeView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/06/26.
//

import SwiftUI

struct HomeView: View {
    @AppStorage("addExpenseAction") private var addExpenseAction: Bool = false
    @Binding var showingSheet: Bool
    @EnvironmentObject private var cdm: CoreDataModel
    @EnvironmentObject private var rvm: RatesViewModel
    
    var body: some View {
        
        NavigationView {
            Form {
                barChartSection
                
                SheetPresenter("Add Expense", image: .init(systemName: "plus"), style: .sheet) {
                    AddSpendingView(ratesViewModel: rvm, codeDataModel: cdm)
                        .environmentObject(rvm)
                        .environmentObject(cdm)
                }
                .padding(.horizontal, -5)
            }
            .navigationTitle("Home")
            .sheet(isPresented: $showingSheet) {
                AddSpendingView(ratesViewModel: rvm, codeDataModel: cdm)
            }
        }
        .navigationViewStyle(.stack)
    }
    
//    var addButton: some View {
//        Button(action: toggleSheet) {
//            HStack(spacing: 15) {
//                Image(systemName: "plus")
//                    .imageScale(.large)
//                Text("Add Expense")
//            }
//        }
//        .padding()
//    }
    
    var barChartSection: some View {
        Section {
            BarChartGenerator()
                .padding(.vertical)
        }
    }
}

extension HomeView {
    func toggleSheet() {
        showingSheet = true
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(showingSheet: .constant(false))
            .environmentObject(CoreDataModel())
    }
}
