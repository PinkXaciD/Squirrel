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
    @EnvironmentObject private var searchModel: StatsSearchViewModel
    @EnvironmentObject private var statsViewModel: StatsViewModel
    
    var body: some View {
        list
    }
    
    private var list: some View {
        let data = getList()
        
        return Group {
            if !data.isEmpty {
                ForEach(data, id: \.key) { key, value in
                    Section {
                        ForEach(value) { spending in
                            StatsRow(entity: spending)
                        }
                    } header: {
                        dateFormatForList(key)
                            .textCase(nil)
                            .font(.subheadline.bold())
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
    
    private func getList() -> [(key: Date, value: [TSSpendingEntity])] {
        var result = [(key: Date, value: [TSSpendingEntity])]()
        
        for key in cdm.statsListData.keys.sorted(by: >) {
            guard let value = cdm.statsListData[key] else { continue }
            
            guard checkSectionKey(key) else { continue }
            
            var newValue = [TSSpendingEntity]()
            
            for spending in value {
                if checkSectionData(spending) {
                    newValue.append(spending)
                }
            }
            
            if !newValue.isEmpty {
                result.append((key, newValue))
            }
        }
        
        return result
    }
    
    private func checkSectionKey(_ date: Date) -> Bool {
//        print("\(#function) called")
//        print("\(date)")
//        print("\(pcvm.selection)")
//        print("Selection date1: \(Date().getFirstDayOfMonth(-pcvm.selection - 1)), selection date 2: \(Date().getFirstDayOfMonth(-pcvm.selection))")
//        print("Selection date1: \(date >= Date().getFirstDayOfMonth(-pcvm.selection - 1)), selection date 2: \(date <= Date().getFirstDayOfMonth(-pcvm.selection))")
        
        if fvm.applyFilters {
            return date >= fvm.startFilterDate && date <= fvm.endFilterDate
        }
        
        if vm.selection == 0 {
            return true
        }
        
        return date >= Date().getFirstDayOfMonth(-vm.selection) && date < Date().getFirstDayOfMonth(-vm.selection + 1)
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
                result = !entity.returns.isEmpty == withReturns
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
