//
//  StatsView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/06.
//

import SwiftUI

struct StatsView: View {
    @EnvironmentObject
    private var vm: CoreDataViewModel
    
    @State
    private var selectedMonth: Int = 0
    @State
    private var showFilters: Bool = false
    @State
    private var seachIsActive: Bool = false
    
    @State
    var firstFilterDate: Date = .now.getFirstDayOfMonth()
    @State
    var secondFilterDate: Date = .now
    @State
    var applyFilters: Bool = false
    @State
    var filterText: String = ""
    
    var body: some View {
        let listData: [String: [SpendingEntity]] = getListData()
        let operationsInMonth: [CategoryEntityLocal] = vm.operationsInMonth(.now.getFirstDayOfMonth(selectedMonth))
        let newChartData: [ChartData] = vm.getChartData()
        
        NavigationView {
            List {
                if filterText.isEmpty {
                    PieChartView(selectedMonth: $selectedMonth, size: UIScreen.main.bounds.width / 1.7, operationsInMonth: operationsInMonth, chartData: newChartData)
                }
                
                if !listData.isEmpty {
                    ForEach(Array(listData.keys).sorted { keySort($0, $1) }, id: \.self) { sectionKey in
                        if let sectionData = listData[sectionKey] {
                            Section {
                                ForEach(sectionData) { spending in
                                    StatsRow(entity: spending)
                                }
                            } header: {
                                Text(sectionKey)
                                    .textCase(nil)
                                    .font(.subheadline.bold())
                            }
                        }
                    }
                } else {
                    HStack {
                        Spacer()
                        Text("No results")
                            .font(.body.bold())
                            .padding()
                        Spacer()
                    }
                }
            }
            .searchable(
                text: $filterText,
                placement: .navigationBarDrawer(displayMode: .automatic),
                prompt: "Search by place, category or comment"
            )
            .onChange(of: selectedMonth) { newValue in
                onChangeFunc(newValue)
            }
            .toolbar {
                toolbar
            }
            .sheet(isPresented: $showFilters) {
                if #available(iOS 16.0, *) {
                    sheet
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.hidden)
                } else {
                    sheet
                }
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
    
    private var sheet: some View {
        FiltersView(
            firstFilterDate: $firstFilterDate,
            secondFilterDate: $secondFilterDate,
            applyFilters: $applyFilters
        )
    }
}

extension StatsView {
    private func getListData() -> [String: [SpendingEntity]] {
        var result: [String: [SpendingEntity]]
        if filterText.isEmpty {
            result = vm.operationsForList()
        } else {
            result = vm.operationsForList().mapValues { $0.filter { entity in
                entity.place?.localizedCaseInsensitiveContains(filterText.trimmingCharacters(in: .whitespaces)) ?? false
                ||
                entity.categoryName.localizedCaseInsensitiveContains(filterText.trimmingCharacters(in: .whitespaces))
                ||
                entity.comment?.localizedCaseInsensitiveContains(filterText.trimmingCharacters(in: .whitespaces)) ?? false
            } }.filter { !$0.value.isEmpty }
        }
        
        if applyFilters {
            result = result.mapValues { $0.filter { entity in
                entity.wrappedDate > firstFilterDate && entity.wrappedDate < secondFilterDate
            } }.filter { !$0.value.isEmpty }
        }
        return result
    }
    
    private func keySort(_ value1: String, _ value2: String) -> Bool {
        let formatter = DateFormatter()
        switch Calendar.current.identifier {
        case .japanese:
            formatter.dateFormat = "MMMM dd, GGGG y"
        default:
            formatter.dateFormat = "MMMM dd, y"
        }
        
        if let date1 = formatter.date(from: value1),
           let date2 = formatter.date(from: value2)
        {
            return date1 > date2
        } else {
            return false
        }
    }
    
    private func onChangeFunc(_ value: Int) {
        if value == 0 {
            applyFilters = false
            firstFilterDate = .now.getFirstDayOfMonth()
            secondFilterDate = .now
        } else {
            firstFilterDate = .now.getFirstDayOfMonth(value)
            secondFilterDate = .now.getFirstDayOfMonth(value + 1)
            applyFilters = true
        }
        
        HapticManager.shared.impact(.soft)
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
            .environmentObject(CoreDataViewModel())
    }
}
