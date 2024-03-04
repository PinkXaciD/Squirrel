//
//  StatsSearchView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/12/07.
//

import SwiftUI
#if DEBUG
import OSLog
#endif

struct StatsSearchView: View {
    @EnvironmentObject
    private var svm: StatsSearchViewModel
    
    var body: some View {
        StatsView()
            .searchable(text: $svm.search, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Search by place or comment")
    }
}
