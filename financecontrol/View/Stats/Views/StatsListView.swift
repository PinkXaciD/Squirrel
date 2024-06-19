//
//  StatsListView.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/02/16.
//

import SwiftUI

struct StatsListView: View {
    @EnvironmentObject private var cdm: CoreDataModel
    @EnvironmentObject private var fvm: FiltersViewModel
    @EnvironmentObject private var vm: StatsListViewModel
//    @EnvironmentObject private var pcvm: PieChartViewModel // TODO: Remove
    @EnvironmentObject private var searchModel: StatsSearchViewModel
    @Environment(\.isSearching) private var isSearching
    
    @Binding var entityToEdit: SpendingEntity?
    @Binding var entityToAddReturn: SpendingEntity?
    @Binding var edit: Bool
    
//    @State private var hasResults: Bool = false
    
    var body: some View {
        list
    }
    
    private var list: some View {
        let data = getList()
        
        return Group {
//            Text("\(vm.selection)")
            
            if !data.isEmpty {
                ForEach(Array(data.keys).sorted(by: >), id: \.self) { sectionKey in
                    if let sectionData = data[sectionKey], !sectionData.isEmpty {
                        Section {
                            ForEach(sectionData) { spending in
                                if let entity = try? spending.unsafeObject(in: cdm.context) {
                                    StatsRow(
                                        entity: entity,
                                        entityToEdit: $entityToEdit,
                                        entityToAddReturn: $entityToAddReturn,
                                        edit: $edit
                                    )
                                    .normalizePadding()
                                    .swipeActions(edge: .trailing) {
                                        getDeleteButton(entity, sectionKey)
                                        
                                        getReturnButton(entity)
                                    }
                                    .swipeActions(edge: .leading) {
                                        getEditButton(entity)
                                    }
                                    .contextMenu {
                                        getEditButton(entity)
                                        
                                        getReturnButton(entity)
                                        
                                        getDeleteButton(entity, sectionKey)
                                    }
                                }
                            }
                        } header: {
                            dateFormatForList(sectionKey)
                                .textCase(nil)
                                .font(.subheadline.bold())
                        }
                    }
                }
            } else {
                noResults
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(EmptyView())
                    .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 0))
            }
        }
    }
    
    private var noResults: some View {
        if cdm.savedSpendings.isEmpty {
            CustomContentUnavailableView("No expenses", imageName: "list.bullet", description: "You can add expenses from home screen.")
        } else if !searchModel.search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            CustomContentUnavailableView.search(searchModel.search.trimmingCharacters(in: .whitespacesAndNewlines))
        } else {
            CustomContentUnavailableView("No results for these filters", imageName: "tray.fill")
        }
    }
    
    private func getEditButton(_ spending: SpendingEntity) -> some View {
        Button {
            edit.toggle()
            entityToEdit = spending
        } label: {
            Label {
                Text("Edit")
            } icon: {
                Image(systemName: "pencil")
            }
        }
        .tint(.accentColor)
    }
    
    private func getDeleteButton(_ spending: SpendingEntity, _ key: Date) -> some View {
        Button(role: .destructive) {
            withAnimation {
//                vm.data[key]?.removeAll(where: { $0.id == spending.id })
                cdm.deleteSpending(spending)
            }
        } label: {
            Label {
                Text("Delete")
            } icon: {
                Image(systemName: "trash.fill")
            }
        }
        .tint(.red)
    }
    
    private func getReturnButton(_ spending: SpendingEntity) -> some View {
        Button {
            entityToAddReturn = spending
        } label: {
            Label("Add return", systemImage: "arrow.uturn.backward")
        }
        .tint(.yellow)
        .disabled(spending.amountWithReturns.isZero)
    }
    
    private func getList() -> StatsListData {
        var data = StatsListData()
        
        data = cdm.statsListData.filter { section in
//            if checkSectionKey(section.key) {
//                let newValue = section.value.filter { spending in
//                    checkSectionData(spending)
//                }
//                
//                if !newValue.isEmpty {
//                    for spending in newValue {
//                        print(spending.place)
//                    }
//                }
//                
//                if newValue.isEmpty {
//                    return false
//                } else {
//                    data[section.key] = newValue
//                }
//                
//                print(data[section.key])
//                
//                return true
//            } else {
//                return false
//            }
            checkSectionKey(section.key)
        }
        
        data = data.mapValues { spendings in
            var arr = [TSSpendingEntity]()
            for spending in spendings {
                if checkSectionData(spending) {
                    arr.append(spending)
                }
            }
            return arr
        }
        
//        data = data.mapValues { spendings in
//            spendings.filter { spending in
//                checkSectionData(spending)
//            }
//        }
        
        return data.filter { !$0.value.isEmpty }
    }
    
    private func checkSectionKey(_ date: Date) -> Bool {
//        print("\(#function) called")
//        print("\(date)")
//        print("\(pcvm.selection)")
//        print("Selection date1: \(Date().getFirstDayOfMonth(-pcvm.selection - 1)), selection date 2: \(Date().getFirstDayOfMonth(-pcvm.selection))")
//        print("Selection date1: \(date >= Date().getFirstDayOfMonth(-pcvm.selection - 1)), selection date 2: \(date <= Date().getFirstDayOfMonth(-pcvm.selection))")
        
        if fvm.applyFilters {
//            print("Apply filters") // TODO: Remove
            return date >= fvm.startFilterDate && date <= fvm.endFilterDate
        }
        
        if vm.selection == 0 {
            return true
        }
        
        return date >= Date().getFirstDayOfMonth(-vm.selection) && date < Date().getFirstDayOfMonth(-vm.selection + 1)
    }
    
    private func getSectionKeys() -> [Date] {
        let keysArr: [Date] = Array(vm.defaultData.keys).filter({ checkSectionKey($0) }).sorted(by: >)
        return keysArr
    }
    
    private func checkSectionData(_ entity: TSSpendingEntity) -> Bool {
        if let selectedID = vm.selectedCategoryId {
            return selectedID == entity.categoryID
        }
        
        var result: Bool = true
        
        if fvm.applyFilters, let spendingCategoryID = entity.categoryID {
            if !fvm.filterCategories.isEmpty {
                result = fvm.filterCategories.contains(spendingCategoryID)
            }
            
            if let withReturns = fvm.withReturns, result {
                result = !entity.returnsArr.isEmpty == withReturns
            }
            
            if !fvm.currencies.isEmpty, result {
                result = fvm.currencies.contains(entity.wrappedCurrency)
            }
        }
        
        let trimmedSearch = searchModel.search.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !trimmedSearch.isEmpty && result {
            result = (entity.comment ?? "").localizedCaseInsensitiveContains(trimmedSearch) || (entity.place ?? "").localizedCaseInsensitiveContains(trimmedSearch)
//            print("\n")
//            print(entity.date)
//            print(entity.place, " ", entity.comment)
//            print(result)
        }
        
        return result
    }
    
    private func dateFormatForList(_ date: Date) -> Text {
        if Calendar.current.isDateInToday(date) {
            return Text("Today")
        } else if Calendar.current.isDateInYesterday(date) {
            return Text("Yesterday")
        } else if Calendar.current.isDateInTomorrow(date) {
            return Text("Tomorrow")
        } else if Calendar.current.isDate(date, equalTo: Date(), toGranularity: .year) {
            return Text(date, format: .dateTime.day().month(.wide))
        } else {
            return Text(date, format: .dateTime.day().month(.wide).year())
        }
    }
}
