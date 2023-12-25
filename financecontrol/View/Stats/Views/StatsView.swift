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
    private var startFilterDate: Date
    @State
    private var endFilterDate: Date = .now
    @State
    fileprivate var filterCategories: [CategoryEntity] = []
    @State
    fileprivate var excludeCategories: Bool = false
    @State
    private var applyFilters: Bool = false
    @Binding
    var search: String
    
    var oldestSpendingDate: Date
    
    private var sheetFraction: CGFloat = 0.7
    
    private var size: CGFloat {
        let currentScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let width = currentScene?.windows.first(where: { $0.isKeyWindow })?.bounds.width ?? UIScreen.main.bounds.width
        let height = currentScene?.windows.first(where: { $0.isKeyWindow })?.bounds.height ?? UIScreen.main.bounds.height
        return width > height ? (height / 1.7) : (width / 1.7)
    }
    
    var body: some View {
        let listData: [String: [SpendingEntity]] = getListData()
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
                                    StatsRow(entity: spending, entityToEdit: $entityToEdit, entityToAddReturn: $entityToAddReturn, edit: $edit)
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
            excludeCategories: $excludeCategories,
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
    init(search: Binding<String>, cdm: CoreDataModel) {
        self._search = search
        let date = cdm.savedSpendings.last?.wrappedDate ?? .now.getFirstDayOfMonth()
        self.oldestSpendingDate = date
        self._startFilterDate = State(initialValue: date)
    }
    
    private func getListData() -> [String: [SpendingEntity]] {
        var result: [String: [SpendingEntity]]
        if search.isEmpty {
            result = cdm.operationsForList()
        } else {
            result = cdm.operationsForList().mapValues { values in
                values.filter { entity in
                    entity.place?.localizedCaseInsensitiveContains(search.trimmingCharacters(in: .whitespaces)) ?? false
                    ||
                    entity.comment?.localizedCaseInsensitiveContains(search.trimmingCharacters(in: .whitespaces)) ?? false
                }
            }
            .filter { !$0.value.isEmpty }
        }
        
        if applyFilters {
            result = result.mapValues { values in
                values.filter { entity in
                    var categoryFilter: Bool = false
                    var dateFilter: Bool = false
                    
                    if !filterCategories.isEmpty, let category = entity.category {
                        categoryFilter = excludeCategories ? !filterCategories.contains(category) : filterCategories.contains(category)
                    } else {
                        categoryFilter = true
                    }
                    
                    dateFilter = entity.wrappedDate >= startFilterDate && entity.wrappedDate <= endFilterDate
                    
                    return categoryFilter && dateFilter
                }
            }
            .filter { !$0.value.isEmpty }
        }
        return result
    }
    
    private func keySort(_ value1: String, _ value2: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        
        guard
            let date1 = formatter.date(from: value1),
            let date2 = formatter.date(from: value2)
        else {
            return false
        }
        
        return date1 > date2
    }
    
    private func onChangeFunc(_ value: Int) {
        if value == 0 {
            if filterCategories.isEmpty {
                applyFilters = false
            }
            startFilterDate = oldestSpendingDate
            endFilterDate = .now
        } else {
            startFilterDate = .now.getFirstDayOfMonth(value)
            endFilterDate = .now.getFirstDayOfMonth(value + 1)
            applyFilters = true
        }
        
        HapticManager.shared.impact(.soft)
    }
    
    private func clearFilters() {
        DispatchQueue.main.async {
            withAnimation {
                applyFilters = false
                startFilterDate = cdm.savedSpendings.last?.wrappedDate ?? .init(timeIntervalSinceReferenceDate: 0)
                endFilterDate = .now
                filterCategories = []
                excludeCategories = false
            }
        }
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView(search: .constant(""), cdm: .init())
            .environmentObject(CoreDataModel())
    }
}
