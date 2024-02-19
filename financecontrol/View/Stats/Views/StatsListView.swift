//
//  StatsListView.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/02/16.
//

import SwiftUI

struct StatsListView: View {
    @EnvironmentObject private var cdm: CoreDataModel
    
    @Binding var entityToEdit: SpendingEntity?
    @Binding var entityToAddReturn: SpendingEntity?
    @Binding var edit: Bool
    
    @Binding var search: String
    @Binding var applyFilters: Bool
    @Binding var startFilterDate: Date
    @Binding var endFilterDate: Date
    @Binding var filterCategories: [CategoryEntity]
    
    var body: some View {
        let listData: StatsListData = getListData()
        
        if !listData.isEmpty {
            ForEach(Array(listData.keys).sorted(by: >), id: \.self) { sectionKey in
                if let sectionData = listData[sectionKey] {
                    Section {
                        ForEach(sectionData) { spending in
                            StatsRow(
                                entity: spending,
                                entityToEdit: $entityToEdit,
                                entityToAddReturn: $entityToAddReturn,
                                edit: $edit
                            )
                            .normalizePadding()
                        }
                    } header: {
                        Text(dateFormatForList(sectionKey))
                            .textCase(nil)
                            .font(.subheadline.bold())
                    }
                }
            }
        } else {
            noResults
        }
    }
    
    private var noResults: some View {
        Section {
            HStack {
                Spacer()
                Text("No results")
                    .font(.body.bold())
                    .padding()
                Spacer()
            }
        }
    }
    
    private func dateFormatForList(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return NSLocalizedString("Today", comment: "")
        } else if Calendar.current.isDateInYesterday(date) {
            return NSLocalizedString("Yesterday", comment: "")
        } else if Calendar.current.isDate(date, equalTo: Date(), toGranularity: .year) {
            let dateFormatter: DateFormatter = .init()
            dateFormatter.locale = .current
            dateFormatter.setLocalizedDateFormatFromTemplate("MMMMd")
            
            return dateFormatter.string(from: date)
        } else {
            let dateFormatter: DateFormatter = .init()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .none
            
            return dateFormatter.string(from: date)
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
}

