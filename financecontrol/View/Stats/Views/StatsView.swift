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
    @Environment(\.managedObjectContext)
    private var viewContext
    @AppStorage(UDKey.color.rawValue)
    private var tint: String = "Orange"
    
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
#if DEBUG
                .refreshable {
                    NotificationCenter.default.post(name: .UpdatePieChart, object: nil)
                }
#endif
        }
    }
    
    private var iPhoneStatsView: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea(.all)
                
                ScrollView (.vertical) {
                    LazyVStack {
                        if !isSearching, searchModel.input.isEmpty {
                            VStack {
                                PieChartView(size: size, showMinimizeButton: true)
                            }
                        }
                        
                        StatsListView()
                    }
                    .padding()
                    .toolbar {
                        leadingToolbar
                        
                        trailingToolbar
                    }
                    .sheet(isPresented: $showFilters) {
                        filters
                    }
                    .navigationTitle("Stats")
                }
            }
        }
        .navigationViewStyle(.stack)
        .searchable(text: $searchModel.input, placement: .automatic, prompt: "Search by place or comment")
        .navigationViewStyle(.stack)
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
                .buttonStyle(.bordered)
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
    
//    private func getListPredicate() -> NSPredicate {
//        if pcvm.selection == 0, !fvm.applyFilters, pcvm.selectedCategory == nil, searchModel.search.isEmpty {
//            return NSPredicate(value: true)
//        }
//        
//        var predicates = [NSPredicate]()
//        
//        if let selectedCategory = pcvm.selectedCategory {
//            let selectedCategoryPredicate = NSPredicate(format: "category.id == %@", selectedCategory.id as CVarArg)
//            predicates.append(selectedCategoryPredicate)
//        }
//        
//        if pcvm.selection != 0 {
//            let selectedMonthPredicate = NSPredicate(
//                format: "date >= %@ AND date < %@",
//                Date().getFirstDayOfMonth(-pcvm.selection) as CVarArg,
//                Date().getFirstDayOfMonth(-pcvm.selection + 1) as CVarArg
//            )
//            predicates.append(selectedMonthPredicate)
//        }
//        
////        if !fvm.applyFilters && searchModel.search.isEmpty {
////            if pcvm.selection == 0 {
//////                let selectedMonthPredicate = NSPredicate(
//////                    format: "date >= %@ AND date < %@",
//////                    Date().getFirstDayOfMonth(-(pcvm.selection + loadMoreCount)) as CVarArg,
//////                    Date().getFirstDayOfMonth(-pcvm.selection + 1) as CVarArg
//////                )
//////                predicates.append(selectedMonthPredicate)
////            } else {
////                let selectedMonthPredicate = NSPredicate(
////                    format: "date >= %@ AND date < %@",
////                    Date().getFirstDayOfMonth(-pcvm.selection) as CVarArg,
////                    Date().getFirstDayOfMonth(-pcvm.selection + 1) as CVarArg
////                )
////                predicates.append(selectedMonthPredicate)
////            }
////        }
//        
//        if fvm.applyFilters {
//            let datePredicate = NSPredicate(format: "date >= %@ AND date < %@", fvm.startFilterDate as CVarArg, fvm.endFilterDate as CVarArg)
//            predicates.append(datePredicate)
//            
//            if !fvm.filterCategories.isEmpty {
//                let filterCategoriesPredicate = NSPredicate(format: "category.id IN %@", fvm.filterCategories as CVarArg)
//                predicates.append(filterCategoriesPredicate)
//            }
//            
//            if !fvm.currencies.isEmpty {
//                let currenciesPredicate = NSPredicate(format: "currency IN %@", fvm.currencies as CVarArg)
//                predicates.append(currenciesPredicate)
//            }
//            
//            if let withReturns = fvm.withReturns {
//                let returnsPredicate = NSPredicate(format: "returns.@count \(withReturns ? ">" : "==") 0")
//                predicates.append(returnsPredicate)
//            }
//        }
////        else {
////            let selectedMonthPredicate = NSPredicate(
////                format: "date >= %@ AND date < %@",
////                Date().getFirstDayOfMonth(-pcvm.selection) as CVarArg,
////                Date().getFirstDayOfMonth(-pcvm.selection + 1) as CVarArg
////            )
////            predicates.append(selectedMonthPredicate)
////        }
//        
//        if !searchModel.search.isEmpty {
//            let searchPredicate = NSPredicate(format: "place CONTAINS[cd] %@ OR comment CONTAINS[cd] %@", searchModel.search, searchModel.search)
//            predicates.append(searchPredicate)
//        }
//        
//        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
//    }
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
        StatsListView(
//            spendings: SectionedFetchRequest(
//                sectionIdentifier: \SpendingEntity.startOfDay,
//                sortDescriptors: [
//                    SortDescriptor(\SpendingEntity.date, order: .reverse)
//                ],
////                predicate: getListPredicate(),
//                predicate: NSPredicate(value: true),
//                animation: .default
//            )
        )
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
