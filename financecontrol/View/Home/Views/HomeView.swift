//
//  HomeView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/06/26.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var cdm: CoreDataModel
    @EnvironmentObject private var rvm: RatesViewModel
    @AppStorage(UDKey.updateRates.rawValue) private var updateRates: Bool = false
    @State private var ratesAreFetching: Bool = UserDefaults.standard.bool(forKey: UDKey.updateRates.rawValue)
    @Binding var showingSheet: Bool
    @Binding var presentOnboarding: Bool
    @State private var shortcut: AddSpendingShortcut? = nil
    
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
                
//                shortcutsSection
            }
            .navigationTitle("Home")
            .sheet(isPresented: $showingSheet) {
                AddSpendingView(ratesViewModel: rvm, codeDataModel: cdm, shortcut: shortcut)
            }
            .onChange(of: rvm.status) { newValue in
                if newValue == .success || newValue == .failed {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            ratesAreFetching = false
                        }
                    }
                } else if newValue == .downloading {
                    withAnimation {
                        ratesAreFetching = true
                    }
                }
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
        Section {
            Button(action: toggleSheet) {
                HStack(spacing: 15) {
                    Image(systemName: "plus")
                        .imageScale(.large)
                    Text("Add Expense")
                }
            }
            .padding()
        } footer: {
            if ratesAreFetching {
                ratesFetchStatus
            }
        }
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
    
    private var ratesFetchStatus: some View {
        HStack(spacing: 10) {
            switch rvm.status {
            case .downloading:
                ProgressView()
                    .tint(.secondary)
                
                Text("Updating rates...")
                
            case .waitingForNetwork:
                if #available(iOS 17.0, *) {
                    Image(systemName: "network.slash")
                        .font(.body.bold())
                } else {
                    Image(systemName: "network")
                        .font(.body.bold())
                }
                
                Text("No network")
                
            case .failed:
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.body.bold())
                
                Text("Failed to update rates")
                
            case .success:
                Image(systemName: "checkmark.circle.fill")
                    .font(.body.bold())
                
                Text("Rates updated")
                
            case .tryingAgain:
                ProgressView()
                    .tint(.secondary)
                
                Text("Trying again...")
                
            default:
                EmptyView()
            }
        }
        .padding(.vertical, 3)
        .animation(.default, value: rvm.status)
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
