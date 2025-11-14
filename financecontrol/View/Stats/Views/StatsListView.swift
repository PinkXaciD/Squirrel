//
//  StatsListView.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/02/16.
//

import SwiftUI

struct StatsListView: View {
    @EnvironmentObject private var fvm: FiltersViewModel
    @EnvironmentObject private var vm: StatsListViewModel
    @EnvironmentObject private var searchModel: StatsSearchViewModel
    @EnvironmentObject private var statsViewModel: StatsViewModel
    
    @StateObject
    private var rowVM = StatsRowViewModel()
    
    @GestureState
    private var draggingRow: UUID? = nil
    
    @Binding
    var spendingToDelete: SpendingEntity?
    @Binding
    var presentDeleteDialog: Bool
    
    private var headerFont: Font {
        if #available(iOS 26.0, *) {
            return .body.bold()
        }
        
        return .subheadline.bold()
    }
    
    var body: some View {
        if !vm.data.isEmpty {
            list
        } else {
            noResults
                .padding(.vertical)
        }
    }
    
    private var list: some View {
        ForEach(vm.data, id: \.key) { section in
            VStack(alignment: .leading) {
                dateFormatForList(section.key)
                    .textCase(nil)
                    .font(headerFont)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .padding(.top)
                
                VStack(spacing: 0) {
                    ForEach(section.value) { spending in
                        StatsRow(state: $draggingRow, data: spending, spendingToDelete: $spendingToDelete, presentDeleteDialog: $presentDeleteDialog)
                            .environmentObject(rowVM)
                        
                        if spending.id != section.value.last?.id {
                            Divider()
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: Self.listCornerRadius))
            }
        }
    }
    
    private var noResults: some View {
        if !searchModel.search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            CustomContentUnavailableView.search(searchModel.search.trimmingCharacters(in: .whitespacesAndNewlines))
        } else if fvm.applyFilters {
            CustomContentUnavailableView("No Results for These Filters", imageName: "tray.fill")
        } else if vm.selection != 0 {
            CustomContentUnavailableView("No Expenses in This Month", imageName: "list.bullet", description: "You can add expenses from home screen.")
        } else {
            CustomContentUnavailableView("No Expenses", imageName: "list.bullet", description: "You can add expenses from home screen.")
        }
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
