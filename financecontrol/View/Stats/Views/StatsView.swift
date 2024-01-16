//
//  StatsView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/06.
//

import SwiftUI

struct StatsView: View {
    @Environment(\.isSearching)
    private var isSearching
    @EnvironmentObject
    private var cdm: CoreDataModel
    @EnvironmentObject
    private var rvm: RatesViewModel
    
    @State
    var entityToEdit: SpendingEntity? = nil
    @State
    var entityToAddReturn: SpendingEntity? = nil
    @State
    private var edit: Bool = false
    
// MARK: Filters
    
    @State
    private var selectedMonth: Int = 0
    @State
    private var showFilters: Bool = false
    
    @State
    private var startFilterDate: Date = .now.getFirstDayOfMonth()
    @State
    private var endFilterDate: Date = .now
    @State
    private var filterCategories: [CategoryEntity] = []
    @State
    private var excludeCategories: Bool = false
    @State
    private var applyFilters: Bool = false
    @Binding
    var search: String
    
    private var sheetFraction: CGFloat = 0.7
    
    private var size: CGFloat {
        let currentScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let width = currentScene?.windows.first(where: { $0.isKeyWindow })?.bounds.width ?? UIScreen.main.bounds.width
        let height = currentScene?.windows.first(where: { $0.isKeyWindow })?.bounds.height ?? UIScreen.main.bounds.height
        return width > height ? (height / 1.7) : (width / 1.7)
    }
    
    var body: some View {
        let listData: StatsListData = getListData()
        let operationsInMonth: [CategoryEntityLocal] = cdm.operationsInMonth(.now.getFirstDayOfMonth(selectedMonth))
        let newChartData: [ChartData] = cdm.getChartData()
        
        NavigationView {
            List {
                if search.isEmpty && !isSearching {
                    PieChartView(
                        selectedMonth: $selectedMonth,
                        filterCategories: $filterCategories,
                        applyFilers: $applyFilters,
                        size: size,
                        operationsInMonth: operationsInMonth,
                        chartData: newChartData
                    )
                }
                
                if !listData.isEmpty {
                    ForEach(Array(listData.keys).sorted { keySort($0, $1) }, id: \.self) { sectionKey in
                        if let sectionData = listData[sectionKey] {
                            Section {
                                ForEach(sectionData) { spending in
                                    StatsRow(
                                        entity: spending,
                                        entityToEdit: $entityToEdit,
                                        entityToAddReturn: $entityToAddReturn,
                                        edit: $edit
                                    )
                                }
                            } header: {
                                Text(sectionKey)
                                    .textCase(nil)
                                    .font(.subheadline.bold())
                            }
                        }
                    }
                } else {
                    noResults
                }
            }
            .onChange(of: selectedMonth) {
                onChangeFunc($0)
            }
            .toolbar {
                toolbar
            }
            .sheet(item: $entityToEdit) { entity in
                SpendingCompleteView(
                    edit: $edit,
                    entity: entity,
                    coreDataModel: cdm,
                    ratesViewModel: rvm
                )
                .smallSheet(sheetFraction)
            }
            .sheet(isPresented: $showFilters) {
                filters
            }
            .sheet(item: $entityToAddReturn) { entity in
                AddReturnView(spending: entity, cdm: cdm, rvm: rvm)
            }
            .navigationTitle("Stats")
        }
        .navigationViewStyle(.stack)
    }
    
    private var toolbar: ToolbarItemGroup<some View> {
        ToolbarItemGroup(placement: .topBarTrailing) {
            HStack {
                Button {
                    clearFilters()
                } label: {
                    Label("Clear filters", systemImage: "xmark.circle")
                }
                .disabled(!applyFilters)
                .opacity(applyFilters ? 1.0 : 0.0)
                
                Button {
                    showFilters.toggle()
                } label: {
                    Label("Filter", systemImage: applyFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                }
            }
        }
    }
    
    private var filters: some View {
        FiltersView(
            firstFilterDate: $startFilterDate,
            secondFilterDate: $endFilterDate,
            categories: $filterCategories,
            applyFilters: $applyFilters
        )
    }
    
    private var noResults: some View {
        HStack {
            Spacer()
            Text("No results")
                .font(.body.bold())
                .padding()
            Spacer()
        }
    }
}

extension StatsView {
    init(search: Binding<String>) {
        self._search = search
    }
    
    private func getListData() -> StatsListData {
        var result: StatsListData = cdm.operationsForList()
        
        result = searchFunc(result)
        
        result = filterFunc(result)
        
        return result
    }
    
    private func searchFunc(_ data: StatsListData) -> StatsListData {
        if !search.isEmpty {
            let trimmedSearch = search.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let result = data.mapValues { entities in
                entities.filter { entity in
                    entity.place?.localizedCaseInsensitiveContains(trimmedSearch) ?? false
                    ||
                    entity.comment?.localizedCaseInsensitiveContains(trimmedSearch) ?? false
                }
            }
            .filter { !$0.value.isEmpty }
            
            return result
        } else {
            return data
        }
    }
    
    private func filterFunc(_ data: StatsListData) -> StatsListData {
        if applyFilters {
            let result = data.mapValues { entities in
                entities.filter { entity in
                    var filter: Bool = true
                    
                    if !filterCategories.isEmpty, let category = entity.category {
                        filter = filterCategories.contains(category)
                    }
                    
                    if filter {
                        filter = entity.wrappedDate >= startFilterDate && entity.wrappedDate <= endFilterDate
                    }
                    
                    return filter
                }
            }
            .filter { !$0.value.isEmpty }
            
            return result
        } else {
            return data
        }
    }
    
    private func keySort(_ value1: String, _ value2: String) -> Bool {
        func dateFormatter(_ value: String) -> Date {
            if value == NSLocalizedString("Today", comment: "") {
                return .now
            } else if value == NSLocalizedString("Yesterday", comment: "") {
                return .now.previousDay
            } else {
                let formatter = DateFormatter()
                formatter.dateStyle = .long
                formatter.timeStyle = .none
                return formatter.date(from: value) ?? .distantPast
            }
        }
        
        return dateFormatter(value1) > dateFormatter(value2)
    }
    
    private func onChangeFunc(_ value: Int) {
        if value == 0 {
            if filterCategories.isEmpty {
                applyFilters = false
            }
            startFilterDate = .now.getFirstDayOfMonth()
            endFilterDate = .now
        } else {
            startFilterDate = .now.getFirstDayOfMonth(value)
            endFilterDate = .now.getFirstDayOfMonth(value + 1)
            applyFilters = true
        }
        
        HapticManager.shared.impact(.soft)
    }
    
    private func clearFilters() {
        withAnimation {
            applyFilters = false
            startFilterDate = .now.getFirstDayOfMonth()
            endFilterDate = .now
            filterCategories = []
        }
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView(search: .constant(""))
            .environmentObject(CoreDataModel())
    }
}
