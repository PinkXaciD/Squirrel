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
                APChart(
                    data.categoriesDict[selectedCategory.id]?.places ?? [],
                    separators: 0.3,
                    innerRadius: 0.73,
                    animation: .default
                ) { element in
                    APChartSector(element.sum, color: Color[element.color], id: element.id)
                }
            } else {
                APChart(
                    categories(),
                    separators: 0.3,
                    innerRadius: 0.73,
                    animation: .default
                ) { element in
                    APChartSector(element.sum, color: Color[element.color], id: element.id)
                }
            }
            
            CenterChartView(
                selectedMonth: data.date,
                width: size,
                operationsInMonth: vm.selectedCategory == nil ? data.sum : data.categoriesDict[vm.selectedCategory?.id ?? .init()]?.sum ?? 0
            )
        }
    }
    
    private func categories() -> [ChartCategory] {
        if vm.showOther {
            return data.categories + data.otherCategories
        }
        
        if let otherCategory = data.otherCategory {
            var result = data.categories
            result.append(otherCategory)
            return result
        }
        
        return data.categories
    }
}
