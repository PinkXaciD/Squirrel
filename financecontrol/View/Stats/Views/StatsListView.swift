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
    @Environment(\.isSearching) private var isSearching
    
    @Binding var entityToEdit: SpendingEntity?
    @Binding var entityToAddReturn: SpendingEntity?
    @Binding var edit: Bool
    
    @StateObject var vm: StatsListViewModel
    
    var body: some View {
        if !vm.data.isEmpty {
            list
        } else {
            noResults
        }
    }
    
    private var list: some View {
        ForEach(Array(vm.data.keys).sorted(by: >), id: \.self) { sectionKey in
            if let sectionData = vm.data[sectionKey] {
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
    }
    
    private var noResults: some View {
//        Section {
//            HStack {
//                Spacer()
//                
//                VStack(spacing: 10) {
//                    Image(systemName: "tray.fill")
//                        .font(.largeTitle.bold())
//                        .opacity(0.7)
//                    
//                    Text("No results")
//                        .font(.body.bold())
//                }
//                .padding()
//                
//                Spacer()
//            }
//            .padding(.horizontal, isSearching ? 10 : 0)
//        }
        
        HStack {
            Spacer()
            
            CustomContentUnavailableView(
                vm.showedSearch.isEmpty ? NSLocalizedString("No Results for These Filters", comment: "") : NSLocalizedString("No Results for \"\(vm.showedSearch)\"", comment: ""),
                imageName: vm.showedSearch.isEmpty ? "tray.fill" : "magnifyingglass",
                description: vm.showedSearch.isEmpty ? nil : NSLocalizedString("Try another search.", comment: "")
            )
            
            Spacer()
        }
        .listRowBackground(Color.clear)
        .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 0))
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
                vm.data[key]?.removeAll(where: { $0.id == spending.id })
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
        .disabled(spending.amountWithReturns == 0)
    }
    
    private func dateFormatForList(_ date: Date) -> Text {
        if Calendar.current.isDateInToday(date) {
            return Text("Today")
        } else if Calendar.current.isDateInYesterday(date) {
            return Text("Yesterday")
        } else if Calendar.current.isDate(date, equalTo: Date(), toGranularity: .year) {
            return Text(date, format: .dateTime.day().month(.wide))
        } else {
            return Text(date, format: .dateTime.day().month(.wide).year())
        }
    }
}
