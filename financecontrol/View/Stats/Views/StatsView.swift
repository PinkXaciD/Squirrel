//
//  StatsView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/06.
//

import SwiftUI
#if DEBUG
import OSLog
#endif

struct StatsView: View {
    @Environment(\.isSearching)
    private var isSearching
    @AppStorage(UDKey.color.rawValue)
    private var tint: String = "Orange"
    
    @EnvironmentObject
    private var cdm: CoreDataModel
    @EnvironmentObject
    private var rvm: RatesViewModel
    @EnvironmentObject
    private var pcvm: PieChartViewModel
    @EnvironmentObject
    private var fvm: FiltersViewModel
    @EnvironmentObject
    private var listVM: StatsListViewModel
    @EnvironmentObject
    private var privacyMonitor: PrivacyMonitor
    @EnvironmentObject
    private var searchModel: StatsSearchViewModel
    @EnvironmentObject
    private var vm: StatsViewModel
    
    @State
    private var showFilters: Bool = false
    
    private var size: CGFloat {
        let currentScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let windowBounds = currentScene?.windows.first(where: { $0.isKeyWindow })?.bounds
        let width = windowBounds?.width ?? UIScreen.main.bounds.width
        let height = windowBounds?.height ?? UIScreen.main.bounds.height
        return min(height / 1.7, width / 1.7)
    }
    
    #if DEBUG
    let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
    #endif
    
    var body: some View {
        if UIDevice.current.isIPad {
            IPadStatsView(size: size)
        } else {
            iPhoneStatsView
        }
    }
    
    private var iPhoneStatsView: some View {
        NavigationView {
            List {
                if !isSearching, searchModel.input.isEmpty {
                    PieChartView(size: size, showMinimizeButton: true)
                        .id(0)
                }
                
                StatsListView()
            }
            .toolbar {
                leadingToolbar
                
                trailingToolbar
            }
            .sheet(isPresented: $showFilters) {
                filters
            }
            .navigationTitle("Stats")
        }
        .navigationViewStyle(.stack)
        .searchable(text: $searchModel.input, placement: .automatic, prompt: "Search by place or comment")
    }
    
    private var leadingToolbar: ToolbarItem<Void, some View> {
        ToolbarItem(placement: .topBarLeading) {
            if fvm.applyFilters {
                Button {
                    clearFilters()
                } label: {
                    Label("Clear filters", systemImage: "xmark")
                }
                .disabled(!fvm.applyFilters)
                .buttonStyle(BorderedButtonStyle())
                .hoverEffect()
            }
        }
    }
    
    private var trailingToolbar: ToolbarItemGroup<some View> {
        ToolbarItemGroup(placement: .topBarTrailing) {
            if fvm.applyFilters {
                Button {
                    showFilters.toggle()
                } label: {
                    HStack(spacing: 5) {
                        let dates = formatDateForFilterButton(fvm.startFilterDate, fvm.endFilterDate)
                        Text("\(dates.0) - \(dates.1)")
                    }
                    .font(.footnote)
                }
                .buttonStyle(BorderedButtonStyle())
                .hoverEffect()
            } else {
                Button {
                    showFilters.toggle()
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease")
                }
                .buttonStyle(BorderedButtonStyle())
                .hoverEffect()
            }
        }
    }
    
    private var filters: some View {
        FiltersView()
            .environmentObject(fvm)
            .environmentObject(pcvm)
            .environmentObject(privacyMonitor)
    }
}

extension StatsView {
    private func formatDateForFilterButton(_ date1: Date, _ date2: Date) -> (String, String) {
        let formatter = DateFormatter()
        formatter.locale = Locale.autoupdatingCurrent
        
        if Calendar.current.isDate(date1, equalTo: date2, toGranularity: .year) {
            formatter.setLocalizedDateFormatFromTemplate("Md")
        } else {
            formatter.setLocalizedDateFormatFromTemplate("yM")
        }
        
        return (formatter.string(from: date1), formatter.string(from: date2))
    }
    
    private func clearFilters() {
        #if DEBUG
        let startDate: Date = Date()
        
        defer {
            logger.log("\(#fileID) \(#function) completed within \(Date().timeIntervalSince(startDate)) seconds")
        }
        #endif
        
        withAnimation {
            pcvm.selectedCategory = nil
            fvm.clearFilters()
        }
        
        pcvm.updateData()
        pcvm.isScrollDisabled = false
    }
}

fileprivate struct IPadStatsView: View {
    @Environment(\.horizontalSizeClass) 
    private var horizontalSizeClass
    @EnvironmentObject
    private var vm: StatsViewModel
    @EnvironmentObject
    private var statsSearchViewModel: StatsSearchViewModel
    @EnvironmentObject
    private var pcvm: PieChartViewModel
    @EnvironmentObject
    private var fvm: FiltersViewModel
    @EnvironmentObject
    private var privacyMonitor: PrivacyMonitor
    
    @State
    private var showFilters: Bool = false
    
    let size: CGFloat
    
    var body: some View {
        NavigationView {
            Group {
                if horizontalSizeClass == .compact {
                    List {
                        PieChartView(size: size, showMinimizeButton: horizontalSizeClass == .compact)
                        
                        listView
                    }
                } else {
                    HStack(spacing: 0) {
                        List {
                            PieChartView(size: UIScreen.main.bounds.width / 4.5, showMinimizeButton: horizontalSizeClass == .compact)
                        }
                        .frame(width: UIScreen.main.bounds.width / 3)
                        
                        List {
                            listView
                        }
                    }
                }
            }
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $statsSearchViewModel.input, placement: .automatic, prompt: "Search by place or comment")
            .toolbar {
                leadingToolbar
                
                trailingToolbar
            }
            .sheet(isPresented: $showFilters) {
                filters
            }
        }
        .listStyle(.insetGrouped)
        .navigationViewStyle(.stack)
    }
    
    private var listView: some View {
        StatsListView()
    }
    
    private var filters: some View {
        FiltersView()
            .environmentObject(fvm)
            .environmentObject(pcvm)
            .environmentObject(privacyMonitor)
    }
    
    private var leadingToolbar: ToolbarItem<Void, some View> {
        ToolbarItem(placement: .topBarLeading) {
            if fvm.applyFilters {
                Button {
                    clearFilters()
                } label: {
                    Label("Clear filters", systemImage: "xmark")
                }
                .disabled(!fvm.applyFilters)
                .buttonStyle(BorderedButtonStyle())
                .hoverEffect()
            }
        }
    }
    
    private var trailingToolbar: ToolbarItemGroup<some View> {
        ToolbarItemGroup(placement: horizontalSizeClass == .compact ? .topBarTrailing : .topBarLeading) {
            if fvm.applyFilters {
                Button {
                    showFilters.toggle()
                } label: {
                    HStack(spacing: 5) {
                        let dates = formatDateForFilterButton(fvm.startFilterDate, fvm.endFilterDate)
                        Text("\(dates.0) - \(dates.1)")
                    }
                    .font(.footnote)
                }
                .buttonStyle(BorderedButtonStyle())
                .hoverEffect()
            } else {
                Button {
                    showFilters.toggle()
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease")
                }
                .buttonStyle(BorderedButtonStyle())
                .hoverEffect()
            }
        }
    }
    
    private func formatDateForFilterButton(_ date1: Date, _ date2: Date) -> (String, String) {
        let formatter = DateFormatter()
        formatter.locale = Locale.autoupdatingCurrent
        
        if horizontalSizeClass == .compact {
            if Calendar.current.isDate(date1, equalTo: date2, toGranularity: .year) {
                formatter.setLocalizedDateFormatFromTemplate("Md")
            } else {
                formatter.setLocalizedDateFormatFromTemplate("yM")
            }
        } else {
            formatter.timeStyle = .none
            formatter.dateStyle = .medium
        }
        
        return (formatter.string(from: date1), formatter.string(from: date2))
    }
    
    private func clearFilters() {
        #if DEBUG
        let startDate: Date = Date()
        
        defer {
            logger.log("\(#fileID) \(#function) completed within \(Date().timeIntervalSince(startDate)) seconds")
        }
        #endif
        
        withAnimation {
            pcvm.selectedCategory = nil
            fvm.clearFilters()
        }
        
        pcvm.updateData()
        pcvm.isScrollDisabled = false
    }
}

//struct StatsView_Previews: PreviewProvider {
//    static var previews: some View {
//        StatsView()
//            .environmentObject(CoreDataModel())
//            .environmentObject(RatesViewModel())
//            .environmentObject(FiltersViewModel(pcvmSelectionPublisher: ))
//    }
//}
