//
//  StatsView.swift
//  Squirrel
//
//  Created by PinkXaciD on 2023/07/06.
//

import SwiftUI
import CoreData
#if DEBUG
import OSLog
#endif

struct StatsView: View {
    @Environment(\.isSearching)
    private var isSearching
    @Environment(\.managedObjectContext)
    private var viewContext
    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass
    
    @AppStorage(UDKey.color.rawValue)
    private var tint: String = "Orange"
    
    @EnvironmentObject
    private var pcvm: PieChartViewModel
    @EnvironmentObject
    private var cdm: CoreDataModel
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
    
    @State
    private var presentExportSheet: Bool = false
    
    @Binding
    var scrollToTop: Int?
    
    private var windowSize: CGSize {
        let currentScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let windowBounds = currentScene?.windows.first(where: { $0.isKeyWindow })?.bounds
        return windowBounds?.size ?? .init(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
    
    private var size: CGFloat {
        if horizontalSizeClass == .compact {
//            return min(min(windowSize.width, windowSize.height) / 1.7, 225)
            return min(min(windowSize.width, windowSize.height) / 1.7, 250)
        } else {
            return min(windowSize.height * 0.3, 250)
        }
    }
    
    private var dateText: Text {
        let date = Calendar.autoupdatingCurrent.date(byAdding: .month, value: -pcvm.selection, to: .now) ?? .now
        
        if Calendar.current.isDate(date, equalTo: Date(), toGranularity: .year) {
            return Text(date, format: .dateTime.month(.wide))
        } else {
            return Text(date, format: .dateTime.month(.wide).year())
        }
    }
    
    #if DEBUG
    let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
    #endif
    
    var body: some View {
        switch horizontalSizeClass {
        case .compact:
            if #available(iOS 26.0, *) {
                NavigationView {
                    compactStatsView
                        .toolbar {
                            if fvm.applyFilters {
                                ToolbarItem(placement: .topBarLeading) {
                                    clearToolbarButton
                                }
                                
                                ToolbarSpacer(.fixed, placement: .topBarLeading)
                                
                                ToolbarItem(placement: .topBarLeading) {
                                    exportToolbarButton
                                }
                            }
                        }
                        .toolbar {
                            newTrailingToolbar
                        }
                }
            } else {
                NavigationView {
                    compactStatsView
                        .toolbar {
                            leadingToolbar
                            
                            trailingToolbar
                        }
                }
            }
        default:
            expandedStatsView
        }
    }
    
    private var compactStatsView: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea(.all)
            
            ScrollViewReader { scroll in
                ScrollView (.vertical) {
                    LazyVStack {
                        if !isSearching, searchModel.input.isEmpty {
                            VStack {
                                PieChartView(size: size, showMinimizeButton: true, spendingsCount: listVM.spendingsCount)
                            }
                            .id(0)
                        } else if fvm.applyFilters {
                            getSearchNotificationRow("Searching Filtered Results", systemImage: "line.3.horizontal.decrease")
                        } else if pcvm.selection != 0 {
                            getSearchNotificationRow("Searching For \(dateText)", systemImage: "calendar")
                        }
                        
                        StatsListView()
                            .id(1)
                    }
                    .padding()
                    .sheet(isPresented: $showFilters) {
                        filters
                    }
                    .navigationTitle("Stats")
                    .onChange(of: scrollToTop) { value in
                        guard value == 1 else {
                            return
                        }
                        
                        withAnimation {
                            scroll.scrollTo((isSearching || !searchModel.input.isEmpty) ? 1 : 0, anchor: .top)
                        }
                        
                        self.scrollToTop = nil
                    }
                }
            }
        }
        .searchable(text: $searchModel.input, placement: .automatic, prompt: "Search by place or comment")
#if DEBUG
        .refreshable {
            NotificationCenter.default.post(name: .UpdatePieChart, object: nil)
        }
#endif
        .sheet(isPresented: $presentExportSheet) {
            WrappedNavigationStack {
                ExportCSVView(cdm: cdm, predicate: listVM.getPredicate(), showTimePicker: false)
            }
        }
        .navigationTitle("Stats")
    }
    
    private var expandedStatsView: some View {
        WrappedNavigationSplitView(style: .balanced) {
            ZStack {
                if #unavailable(iOS 26.0) {
                    Color(uiColor: .systemGroupedBackground)
                        .ignoresSafeArea()
                }
                
                ScrollViewReader { scroll in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading) {
                            VStack {
                                PieChartView(
                                    size: size,
                                    showMinimizeButton: false,
                                    spendingsCount: listVM.spendingsCount,
                                    inSidebar: true
                                )
                            }
                            .id(0)
                            
                            if fvm.applyFilters {
                                getSearchNotificationRow("Searching Filtered Results", systemImage: "line.3.horizontal.decrease")
                            } else if !searchModel.input.isEmpty, pcvm.selection != 0 {
                                getSearchNotificationRow("Searching For \(dateText)", systemImage: "calendar")
                            }
                        }
                        .padding()
                    }
                    .onChange(of: scrollToTop) { value in
                        guard value == 1 else {
                            return
                        }
                        
                        withAnimation {
                            scroll.scrollTo(0, anchor: .top)
                        }
                        
                        self.scrollToTop = nil
                    }
                }
            }
            .navigationTitle("Stats")
        } detail: {
            Group {
                if #available(iOS 26.0, *) {
                    list
                        .toolbar {
                            if fvm.applyFilters {
                                ToolbarItem(placement: .topBarLeading) {
                                    clearToolbarButton
                                }
                                
                                ToolbarSpacer(.fixed, placement: .topBarLeading)
                                
                                ToolbarItem(placement: .topBarLeading) {
                                    exportToolbarButton
                                }
                            }
                        }
                        .toolbar {
                            newTrailingToolbar
                        }
                } else {
                    list
                        .toolbar {
                            leadingToolbar
                            
                            trailingToolbar
                        }
                }
            }
        }
        .sheet(isPresented: $showFilters) {
            filters
        }
        .sheet(isPresented: $presentExportSheet) {
            WrappedNavigationStack {
                ExportCSVView(cdm: cdm, predicate: listVM.getPredicate(), showTimePicker: false)
            }
        }
    }
    
    private var list: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea(.all)
            
            ScrollViewReader { scroll in
                ScrollView (.vertical) {
                    LazyVStack {
                        StatsListView()
                            .id(0)
                    }
                    .padding(.horizontal)
                    .onChange(of: scrollToTop) { value in
                        guard value == 1 else {
                            return
                        }
                        
                        withAnimation {
                            scroll.scrollTo(0, anchor: .top)
                        }
                        
                        self.scrollToTop = nil
                    }
                }
                .searchable(text: $searchModel.input, placement: .automatic, prompt: "Search by place or comment")
            }
        }
    }
    
    @available(iOS 26.0, *)
    private var clearToolbarButton: some View {
        Button {
            clearFilters()
        } label: {
            Label("Clear filters", systemImage: "xmark")
        }
        .addFiltersButtonStyle()
        .animation(.default, value: fvm.applyFilters)
        .hoverEffect()
    }
    
    @available(iOS 26.0, *)
    private var exportToolbarButton: some View {
        Button {
            presentExportSheet.toggle()
        } label: {
            Label("Export", systemImage: "arrow.up.doc")
        }
        .addFiltersButtonStyle()
        .animation(.default, value: fvm.applyFilters)
        .hoverEffect()
    }
    
    private var leadingToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            if fvm.applyFilters {
                Group {
                    Button {
                        clearFilters()
                    } label: {
                        Label("Clear filters", systemImage: "xmark")
                    }
                    .addFiltersButtonStyle()
                    
                    if !listVM.data.isEmpty {
                        Button {
                            presentExportSheet.toggle()
                        } label: {
                            Label("Export", systemImage: "xmark")
                                .opacity(0)
                        }
                        .addFiltersButtonStyle()
                        .overlay(alignment: .center) {
                            Image(systemName: "arrow.up.doc")
                                .font(.subheadline)
                                .foregroundStyle(.tint)
                        }
                    }
                }
                .disabled(!fvm.applyFilters)
                .hoverEffect()
            }
        }
    }
    
    @available(iOS 26.0, *)
    private var newTrailingToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showFilters.toggle()
            } label: {
                if fvm.applyFilters {
                    Text(formatDateForFilterButton())
                } else {
                    Label("Filter", systemImage: "line.3.horizontal.decrease")
                }
            }
            .addFiltersButtonStyle()
            .hoverEffect()
            .animation(.default, value: fvm.applyFilters)
        }
    }
    
    private var trailingToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            if fvm.applyFilters {
                Button {
                    showFilters.toggle()
                } label: {
                    Text(formatDateForFilterButton())
                        .font(.footnote)
                }
                .addFiltersButtonStyle()
                .hoverEffect()
            } else {
                Button {
                    showFilters.toggle()
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease")
                }
                .addFiltersButtonStyle()
                .hoverEffect()
            }
        }
    }
    
    private var filters: some View {
        NavigationView {
            FiltersView(
                startDate: max(cdm.firstSpendingDate ?? Date().getFirstDayOfMonth(), Date().getFirstDayOfMonth()),
                fvm: fvm,
                spendingsCount: cdm.spendingsCount,
                firstSpendingDate: cdm.firstSpendingDate ?? .firstAvailableDate,
                usedCurrencies: cdm.usedCurrencies,
                usedTimeZones: cdm.usedTimeZones
            )
        }
        .accentColor(colorIdentifier(color: tint))
        .environmentObject(fvm)
        .environmentObject(pcvm)
        .environmentObject(privacyMonitor)
    }
    
    private func getSearchNotificationRow(_ text: LocalizedStringKey, systemImage: String) -> some View {
        HStack {
            Group {
                Image(systemName: systemImage)
                
                Text(text)
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

fileprivate extension View {
    func addFiltersButtonStyle() -> some View {
        if #available(iOS 26.0, *) {
            return self.buttonStyle(.automatic)
        }
        
        return self.buttonStyle(.bordered)
    }
}

extension StatsView {
    private func formatDateForFilterButton() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.autoupdatingCurrent
        
        switch fvm.dateType {
        case .single:
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: fvm.endFilterDate)
        case .month:
            return (DateComponents(calendar: .init(identifier: .gregorian), year: fvm.year, month: fvm.month).date ?? Date()).formatted(.dateTime.month(.abbreviated).year())
        case .year:
            return (DateComponents(calendar: .init(identifier: .gregorian), year: fvm.year).date ?? Date()).formatted(.dateTime.year())
        case .all:
            return NSLocalizedString("All Time", comment: "")
        default:
            if Calendar.current.isDate(fvm.startFilterDate, equalTo: fvm.endFilterDate, toGranularity: .year) {
                formatter.setLocalizedDateFormatFromTemplate("Md")
            } else {
                formatter.setLocalizedDateFormatFromTemplate("yM")
            }
            
            return "\(formatter.string(from: fvm.startFilterDate)) - \(formatter.string(from: fvm.endFilterDate))"
        }
    }
    
    private func clearFilters() {
        withAnimation {
            pcvm.selectedCategory = nil
            fvm.clearFilters()
        }
        
        pcvm.updateData()
        pcvm.isScrollDisabled = false
    }
}

fileprivate struct ListButtonStyle: ButtonStyle {
    @Environment(\.isEnabled)
    private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
            
            configuration.label
                .foregroundStyle(.tint)
                .opacity(configuration.isPressed ? 0.5 : 1)
                .padding(.horizontal)
                .grayscale(isEnabled ? 0 : 1)
        }
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
