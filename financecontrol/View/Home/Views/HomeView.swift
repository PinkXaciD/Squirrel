//
//  HomeView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/06/26.
//

import SwiftUI

struct HomeView: View {
    @AppStorage(UDKeys.addExpenseAction.rawValue) private var addExpenseAction: Bool = false
    @Binding var showingSheet: Bool
    @Binding var presentOnboarding: Bool
    @State private var shortcut: AddSpendingShortcut? = nil
    @EnvironmentObject private var cdm: CoreDataModel
    @EnvironmentObject private var rvm: RatesViewModel
    
    var body: some View {
        NavigationView {
            List {
                barChartSection
                    .padding(.horizontal, -10)
                
                addButton
                    #if DEBUG
                    .swipeActions(edge: .leading) {
                        Button {
                            cdm.addSpending(
                                spending: .init(
                                    amountUSD: 1,
                                    amount: 1,
                                    amountWithReturns: 1,
                                    amountUSDWithReturns: 1,
                                    comment: "Test comment",
                                    currency: "USD",
                                    date: Date(),
                                    place: "Test place",
                                    categoryId: cdm.savedCategories.first?.id ?? .init()
                                )
                            )
                        } label: {
                            Label {
                                Text(verbatim: "Add test")
                            } icon: {
                                Image(systemName: "ladybug.fill")
                            }
                        }
                    }
                    #endif
                
                #if DEBUG
                Section {
                    Button {
                        presentOnboarding = true
                    } label: {
                        Text(verbatim: "Present onboarding")
                    }
                }
                #endif
                
//                shortcutsSection
            }
            .navigationTitle("Home")
            .sheet(isPresented: $showingSheet) {
                AddSpendingView(ratesViewModel: rvm, codeDataModel: cdm, shortcut: shortcut)
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private var barChartSection: some View {
        Section {
            BarChartGenerator()
                .padding(.vertical)
        }
    }
    
    private var addButton: some View {
        Button(action: toggleSheet) {
            HStack(spacing: 15) {
                Image(systemName: "plus")
                    .imageScale(.large)
                Text("Add Expense")
            }
        }
        .padding()
    }
    
    @ViewBuilder
    private var shortcutsSection: some View {
        if let shortcuts = UserDefaults.standard.value(forKey: "addSpendingShortcuts") as? [AddSpendingShortcut], !shortcuts.isEmpty {
            Section {
                ForEach(shortcuts) { shortcut in
                    Button {
                        self.shortcut = shortcut
                        showingSheet.toggle()
                    } label: {
                        Text(shortcut.shortcutName)
                    }

                }
            }
        }
    }
    
    func toggleSheet() {
        showingSheet = true
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(showingSheet: .constant(false), presentOnboarding: .constant(false))
            .environmentObject(CoreDataModel())
    }
}
