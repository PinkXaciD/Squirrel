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
    
    @SectionedFetchRequest
    var spendings: SectionedFetchResults<Date, SpendingEntity>
    
    var body: some View {
        list
    }
    
    private var list: some View {
        Group {
            if !spendings.isEmpty {
                ForEach(spendings) { section in
                    Section {
                        ForEach(section) { spending in
                            StatsRow(entity: spending)
                        }
                    } header: {
                        dateFormatForList(section.id)
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
        if !searchModel.search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            CustomContentUnavailableView.search(searchModel.search.trimmingCharacters(in: .whitespacesAndNewlines))
        } else if fvm.applyFilters {
            CustomContentUnavailableView("No results for these filters", imageName: "tray.fill")
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
