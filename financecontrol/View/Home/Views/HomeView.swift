//
//  HomeView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/06/26.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.managedObjectContext)
    private var viewContext
    
    @EnvironmentObject
    private var cdm: CoreDataModel
    @EnvironmentObject
    private var rvm: RatesViewModel
    @EnvironmentObject
    private var kvmManager: CloudKitKVSManager
    
    @AppStorage(UDKey.updateRates.rawValue)
    private var updateRates: Bool = false
    @AppStorage("LatestLaunchedBuild")
    private var latestLaunchedBuild: Int = -1
    
    @State
    private var ratesAreFetching: Bool = UserDefaults.standard.bool(forKey: UDKey.updateRates.rawValue)
    @State
    private var shortcut: AddSpendingShortcut? = nil
    @State
    private var showWhatsNew: Bool = false
    
    @Binding
    var showingSheet: Bool
    @Binding
    var presentOnboarding: Bool
    
    let cloudSyncWasEnabled: Bool
    let currentBuild = Int(Bundle.main.buildVersionNumber ?? "") ?? 0
    
    var body: some View {
        NavigationView {
            List {
                barChartSection
                    .padding(.horizontal, -10)
                
                addButton
                    #if DEBUG
                    .swipeActions(edge: .leading) {
                        Button {
                            cdm.addTestSpending()
                        } label: {
                            Label {
                                Text(verbatim: "Add test")
                            } icon: {
                                Image(systemName: "ladybug.fill")
                            }
                            .labelStyle(.iconOnly)
                        }
                    }
                    #endif
                
                if latestLaunchedBuild < currentBuild {
                    whatsNewSection
                }
                
#if DEBUG
                if latestLaunchedBuild >= currentBuild {
                    Button("Drop last version to 0") {
                        latestLaunchedBuild = 0
                    }
                }
#endif
                
//                shortcutsSection
            }
            .navigationTitle("Home")
            .sheet(isPresented: $showingSheet) {
                AddSpendingView(ratesViewModel: rvm, codeDataModel: cdm, shortcut: shortcut)
            }
            .sheet(isPresented: $showWhatsNew) {
                latestLaunchedBuild = currentBuild
            } content: {
                WhatsNewView()
                    .environmentObject(kvmManager)
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
        .animation(.default, value: latestLaunchedBuild)
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
            if ratesAreFetching || cloudSyncWasEnabled != kvmManager.iCloudSync {
                VStack(alignment: .leading) {
                    if ratesAreFetching {
                        ratesFetchStatus
                    }
                    
                    if cloudSyncWasEnabled != kvmManager.iCloudSync {
                        Text("appication-restart-required-key")
                            .foregroundStyle(.red)
                    }
                }
            }
        }
    }
    
    private var whatsNewSection: some View {
        Section {
            Button("What's new in \(Bundle.main.releaseVersionNumber ?? "")") {
//                latestLaunchedBuild = currentBuild
                
                showWhatsNew.toggle()
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
        HomeView(showingSheet: .constant(false), presentOnboarding: .constant(false), cloudSyncWasEnabled: false)
            .environmentObject(CoreDataModel())
    }
}
