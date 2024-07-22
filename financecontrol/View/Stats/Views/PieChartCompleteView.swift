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
    let data: ChartData
    let size: CGFloat
    @State private var update: Bool = false
    
    var body: some View {
        ZStack {
            if let selectedCategory = vm.selectedCategory {
                if update {
                    APChart(separators: 0.15, innerRadius: 0.73) {
                        setPlaces(data.categoriesDict[selectedCategory.id]?.places ?? [])
                    }
                } else {
                    APChart(separators: 0.15, innerRadius: 0.73) {
                        setPlaces(data.categoriesDict[selectedCategory.id]?.places ?? [])
                    }
                }
            } else {
                if update {
                    APChart(separators: 0.15, innerRadius: 0.73) {
                        setData(vm.showOther ? (data.categories + data.otherCategories) : (data.categories), otherCategory: vm.showOther ? nil : data.otherCategory)
                    }
                } else {
                    APChart(separators: 0.15, innerRadius: 0.73) {
                        setData(vm.showOther ? (data.categories + data.otherCategories) : (data.categories), otherCategory: vm.showOther ? nil : data.otherCategory)
                    }
                }
            }
            
            CenterChartView(
                selectedMonth: data.date,
                width: size,
                operationsInMonth: vm.selectedCategory == nil ? data.sum : data.categoriesDict[vm.selectedCategory?.id ?? .init()]?.sum ?? 0
            )
        }
        .onChange(of: data) { _ in
            DispatchQueue.main.async {
                update.toggle()
            }
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
