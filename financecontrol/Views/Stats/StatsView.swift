//
//  StatsView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/06.
//

import SwiftUI
import ApplePie

struct StatsView: View {
    @EnvironmentObject private var vm: CoreDataViewModel
    
    var body: some View {
        
        let listData = getListData()
        
        NavigationView {
            List {
                PieChartGenerator()
                
                ForEach(0..<listData.count, id: \.self) { index in
                    Section(header: Text(listData[index].key)) {
                        ForEach(listData[index].value) { entity in
                            StatsRow(entity: entity)
                        }
                    }
                }
            }
            .navigationTitle("Stats")
        }
        .navigationViewStyle(.stack)
    }
    
    private func getListData() -> [Dictionary<String, [SpendingEntity]>.Element] {
        
        vm.operationsSortByMonth()
    }
}


struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
            .environmentObject(CoreDataViewModel())
    }
}
