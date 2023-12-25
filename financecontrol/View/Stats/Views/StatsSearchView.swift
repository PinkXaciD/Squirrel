//
//  StatsSearchView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/12/07.
//

import SwiftUI

struct StatsSearchView: View {
    @State
    private var searchText: String = ""
    @EnvironmentObject
    private var cdm: CoreDataModel
    
    var body: some View {
        StatsView(search: $searchText, cdm: cdm)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Search by place or comment")
    }
}
