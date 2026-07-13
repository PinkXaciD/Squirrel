//
//  HomeView.swift
//  Squirrel
//
//  Created by PinkXaciD on 2023/06/26.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.managedObjectContext)
    private var viewContext
    @Environment(\.colorScheme)
    private var colorScheme
    
    @EnvironmentObject
    private var cdm: CoreDataModel
    @EnvironmentObject
    private var rvm: RatesViewModel
    
    @AppStorage(UDKey.updateRates.rawValue)
    private var updateRates: Bool = false
    @AppStorage("LatestLaunchedBuild")
    private var latestLaunchedBuild: Int = -1
    
    @State
    private var ratesAreFetching: Bool = UserDefaults.standard.bool(forKey: UDKey.updateRates.rawValue)
    @State
    private var showWhatsNew: Bool = false
    @State
    private var animateWhatsNewButton: Bool = false
    
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
            }
            .navigationTitle("Home")
            .sheet(isPresented: $showingSheet) {
                AddSpendingView(
                    ratesViewModel: rvm,
                    codeDataModel: cdm
                )
                .addColorPresentationBackground()
            }
            .sheet(isPresented: $showWhatsNew) {
                latestLaunchedBuild = currentBuild
            } content: {
                WhatsNewView()
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
            if ratesAreFetching {
                VStack(alignment: .leading) {
                    if ratesAreFetching {
                        ratesFetchStatus
                    }
                }
            }
        }
    }
    
    private var whatsNewSection: some View {
        Section {
            Button {
                showWhatsNew.toggle()
            } label: {
                ZStack {
                    Text("What's new in \(Bundle.main.releaseVersionNumber ?? "")")
                        .foregroundStyle(gradient)
                        .opacity(animateWhatsNewButton ? 0 : 0.75)
                        .blur(radius: 5)
                    
                    Text("What's new in \(Bundle.main.releaseVersionNumber ?? "")")
                        .foregroundStyle(gradient)
                }
            }
            .hueRotation(.degrees(animateWhatsNewButton ? 720 : 0))
            .onAppear {
                withAnimation(.linear(duration: 5).delay(0.5)) {
                    animateWhatsNewButton = true
                }
            }
            .onDisappear {
                animateWhatsNewButton = false
            }
        }
    }
    
    private var gradient: LinearGradient {
        let colors = stride(from: 0, to: 1, by: 0.05).map { value in
            Color(
                lightness: colorScheme == .light ? CategoryColorValues.lightModeLightness : CategoryColorValues.darkModeLightness,
                chroma: 0.12,
                hue: value * 360
            )
        }
        
        return .init(colors: colors, startPoint: .leading, endPoint: .trailing)
    }
    
    private var ratesFetchStatus: some View {
        HStack(spacing: 7) {
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
//                EmptyView()
                ProgressView()
                    .tint(.secondary)
                
                Text("Updating rates...")
            }
            
//            Image(systemName: "chevron.forward")
//                .scaleEffect(0.9, anchor: .leading)
//                .padding(.leading, -3)
        }
        .padding(.vertical, 3)
        .foregroundStyle(Color.secondary)
        .font(.footnote)
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
