//
//  PieChartCompleteView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 6/02/03.
//

import SwiftUI
import ApplePie

struct PieChartCompleteView: View {
    @Environment(\.layoutDirection) private var layoutDirection
    @EnvironmentObject private var vm: PieChartViewModel
    let count: Int
    let size: CGFloat
    
    var body: some View {
        let localData = {
            if !vm.data.isEmpty {
                vm.data[count > vm.data.count - 1 ? 0 : count]
            } else {
                ChartData.getEmpty()
            }
        }()
        
        ZStack {
            if let selectedCategory = vm.selectedCategory {
                APChart(separators: 0.15, innerRadius: 0.73) {
                    setPlaces(localData.categoriesDict[selectedCategory.id]?.places ?? [])
                }
            } else {
                APChart(separators: 0.15, innerRadius: 0.73) {
                    setData(vm.showOther ? (localData.categories + localData.otherCategories) : (localData.categories), otherCategory: vm.showOther ? nil : localData.otherCategory)
                }
            }
            
            CenterChartView(
                selectedMonth: localData.date,
                width: size,
                operationsInMonth: vm.selectedCategory == nil ? localData.sum : localData.categoriesDict[vm.selectedCategory?.id ?? .init()]?.sum ?? 0
            )
//            #if DEBUG
//            .onTapGesture {
//                withAnimation {
//                    vm.selection = 0
//                }
//            }
//            #endif
        }
    }
    
    private func setData(_ operations: [ChartCategory], otherCategory: ChartCategory? = nil) -> [APChartSectorData] {
        var mutableOperations = operations
        if let otherCategory {
            mutableOperations.append(otherCategory)
        }
        
        let result = mutableOperations.map { element in
            APChartSectorData(
                element.sum,
                Color[element.color],
                id: element.id
            )
        }
        
        return result.filter { $0.value != 0 }
    }
    
    private func setPlaces(_ places: [ChartPlace]) -> [APChartSectorData] {
        places.map { place in
            APChartSectorData(place.sum, Color[place.color], id: place.id)
        }
    }
}
