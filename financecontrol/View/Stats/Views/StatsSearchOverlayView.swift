//
//  StatsSearchOverlayView.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/05/14.
//

import SwiftUI

//struct StatsSearchOverlayView: View {
//    @EnvironmentObject private var cdm: CoreDataModel
//    @EnvironmentObject private var fvm: FiltersViewModel
//    @EnvironmentObject private var vm: StatsListViewModel
//    @EnvironmentObject private var pcvm: PieChartViewModel
//    @EnvironmentObject private var searchModel: StatsSearchViewModel
//    @Environment(\.isSearching) private var isSearching
//    
//    @Binding var entityToEdit: SpendingEntity?
//    @Binding var entityToAddReturn: SpendingEntity?
//    @Binding var edit: Bool
//    
//    @State private var hasResults: Bool = false
    
//    var body: some View {
//        if !vm.defaultData.isEmpty && hasResults {
//            list
//        } else {
//            noResults
//                .listRowBackground(Color.clear)
//                .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 0))
//                .frame(maxWidth: .infinity, alignment: .center)
//        }
//    }
    
//    private var list: some View {
//        Group {
//            Text("\(vm.selection)")
//            ForEach(getSectionKeys(), id: \.self) { sectionKey in
//                if let sectionData = vm.defaultData[sectionKey]?.filter({ checkSectionData($0) }), !sectionData.isEmpty {
//                    Section {
//                        ForEach(sectionData) { spending in
//                            if let entity = try? spending.unsafeObject(in: cdm.context) {
//                                StatsRow(
//                                    entity: entity,
//                                    entityToEdit: $entityToEdit,
//                                    entityToAddReturn: $entityToAddReturn,
//                                    edit: $edit
//                                )
//                                .normalizePadding()
//                                .swipeActions(edge: .trailing) {
//                                    getDeleteButton(entity, sectionKey)
//                                    
//                                    getReturnButton(entity)
//                                }
//                                .swipeActions(edge: .leading) {
//                                    getEditButton(entity)
//                                }
//                                .contextMenu {
//                                    getEditButton(entity)
//                                    
//                                    getReturnButton(entity)
//                                    
//                                    getDeleteButton(entity, sectionKey)
//                                }
//                            }
//                        }
//                    } header: {
//                        dateFormatForList(sectionKey)
//                            .textCase(nil)
//                            .font(.subheadline.bold())
//                    }
//                }
//            }
//        }
//    }
    
//    private var noResults: some View {
//        if !vm.showedSearch.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//            CustomContentUnavailableView.search(vm.showedSearch.trimmingCharacters(in: .whitespacesAndNewlines))
//        } else {
//            CustomContentUnavailableView("No results for these filters", imageName: "tray.fill")
//        }
//    }
//    
//    private func getEditButton(_ spending: SpendingEntity) -> some View {
//        Button {
//            edit.toggle()
//            entityToEdit = spending
//        } label: {
//            Label {
//                Text("Edit")
//            } icon: {
//                Image(systemName: "pencil")
//            }
//        }
//        .tint(.accentColor)
//    }
//    
//    private func getDeleteButton(_ spending: SpendingEntity, _ key: Date) -> some View {
//        Button(role: .destructive) {
//            withAnimation {
//                vm.data[key]?.removeAll(where: { $0.id == spending.id })
//                cdm.deleteSpending(spending)
//            }
//        } label: {
//            Label {
//                Text("Delete")
//            } icon: {
//                Image(systemName: "trash.fill")
//            }
//        }
//        .tint(.red)
//    }
//    
//    private func getReturnButton(_ spending: SpendingEntity) -> some View {
//        Button {
//            entityToAddReturn = spending
//        } label: {
//            Label("Add return", systemImage: "arrow.uturn.backward")
//        }
//        .tint(.yellow)
//        .disabled(spending.amountWithReturns.isZero)
//    }
//    
//    private func checkSectionKey(_ date: Date) -> Bool {
//        print("\(#function) called")
//        print("\(date)")
//        print("\(pcvm.selection)")
//        print("Selection date1: \(Date().getFirstDayOfMonth(-pcvm.selection - 1)), selection date 2: \(Date().getFirstDayOfMonth(-pcvm.selection))")
//        print("Selection date1: \(date >= Date().getFirstDayOfMonth(-pcvm.selection - 1)), selection date 2: \(date <= Date().getFirstDayOfMonth(-pcvm.selection))")
        
//        if fvm.applyFilters {
//            print("Apply filters") // TODO: Remove
//            return date > fvm.startFilterDate && date <= fvm.endFilterDate
//        }
//        
//        if vm.selection == 0 {
//            return true
//        }
//        
//        return date >= Date().getFirstDayOfMonth(-vm.selection) && date < Date().getFirstDayOfMonth(-vm.selection + 1)
//    }
//    
//    private func getSectionKeys() -> [Date] {
//        let keysArr: [Date] = Array(vm.defaultData.keys).filter({ checkSectionKey($0) }).sorted(by: >)
//        return keysArr
//    }
//    
//    private func checkSectionData(_ entity: TSSpendingEntity) -> Bool {
//        if let selectedID = pcvm.selectedCategory?.id {
//            return selectedID == entity.categoryID
//        }
//        
//        var result: Bool = true
//        
//        if fvm.applyFilters, !fvm.filterCategories.isEmpty {
//            result = fvm.filterCategories.contains(entity.wrappedId)
//        }
//        
//        let trimmedSearch = searchModel.search.trimmingCharacters(in: .whitespacesAndNewlines)
//        
//        if !trimmedSearch.isEmpty {
//            result = (entity.comment ?? "").contains(trimmedSearch) || (entity.place ?? "").contains(trimmedSearch)
//        }
//        
//        return result
//    }
//    
//    private func dateFormatForList(_ date: Date) -> Text {
//        self.hasResults = true
//        
//        if Calendar.current.isDateInToday(date) {
//            return Text("Today")
//        } else if Calendar.current.isDateInYesterday(date) {
//            return Text("Yesterday")
//        } else if Calendar.current.isDateInTomorrow(date) {
//            return Text("Tomorrow")
//        } else if Calendar.current.isDate(date, equalTo: Date(), toGranularity: .year) {
//            return Text(date, format: .dateTime.day().month(.wide))
//        } else {
//            return Text(date, format: .dateTime.day().month(.wide).year())
//        }
//    }
//}
//
