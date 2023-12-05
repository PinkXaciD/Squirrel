//
//  StatsView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/06.
//

import SwiftUI

struct StatsView: View {
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
    
    @State
    private var selectedMonth: Int = 0
    @State
    private var showFilters: Bool = false
    
    @State
    var startFilterDate: Date = .now.getFirstDayOfMonth()
    @State
    var endFilterDate: Date = .now
    @State
    var applyFilters: Bool = false
    @State
    var search: String = ""
    
    private var sheetFraction: CGFloat = 0.7
    
    var body: some View {
        let listData: [String: [SpendingEntity]] = getListData()
        let operationsInMonth: [CategoryEntityLocal] = cdm.operationsInMonth(.now.getFirstDayOfMonth(selectedMonth))
        let newChartData: [ChartData] = cdm.getChartData()
        
        NavigationView {
            List {
                if search.isEmpty {
                    PieChartView(
                        selectedMonth: $selectedMonth,
                        search: $search,
                        size: UIScreen.main.bounds.width / 1.7,
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
            .searchable(
                text: $search,
                placement: .navigationBarDrawer(displayMode: .automatic),
                prompt: "Search by place, category or comment"
            )
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
                    .smallSheet()
            }
            .sheet(item: $entityToAddReturn) { entity in
                AddReturnView(spending: entity, cdm: cdm, rvm: rvm)
            }
            .navigationTitle("Stats")
        }
        .navigationViewStyle(.stack)
    }
    
    private var toolbar: ToolbarItem<Void, some View> {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showFilters.toggle()
            } label: {
                Label("Filter", systemImage: applyFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
            }
        }
    }
    
    private var filters: some View {
        FiltersView(
            firstFilterDate: $startFilterDate,
            secondFilterDate: $endFilterDate,
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
    private func getListData() -> [String: [SpendingEntity]] {
        var result: [String: [SpendingEntity]]
        if search.isEmpty {
            result = cdm.operationsForList()
        } else {
            result = cdm.operationsForList().mapValues {
                $0.filter { entity in
                    entity.place?.localizedCaseInsensitiveContains(search.trimmingCharacters(in: .whitespaces)) ?? false
                    ||
                    entity.categoryName.localizedCaseInsensitiveContains(search.trimmingCharacters(in: .whitespaces))
                    ||
                    entity.comment?.localizedCaseInsensitiveContains(search.trimmingCharacters(in: .whitespaces)) ?? false
                }
            }
            .filter { !$0.value.isEmpty }
        }
        
        if applyFilters {
            result = result.mapValues {
                $0.filter { entity in
                    entity.wrappedDate > startFilterDate && entity.wrappedDate < endFilterDate
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
            applyFilters = false
            startFilterDate = .now.getFirstDayOfMonth()
            endFilterDate = .now
        } else {
            startFilterDate = .now.getFirstDayOfMonth(value)
            endFilterDate = .now.getFirstDayOfMonth(value + 1)
            applyFilters = true
        }
        
        HapticManager.shared.impact(.soft)
    }
    
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
            .environmentObject(CoreDataModel())
    }
}
