//
//  PieChartCompleteView.swift
//  Squirrel
//
//  Created by PinkXaciD on 2024/02/03.
//

import SwiftUI
import ApplePie

struct PieChartCompleteView: View {
    @Environment(\.colorScheme)
    private var colorScheme
    @Environment(\.colorSchemeContrast)
    private var colorSchemeContrast
    @Environment(\.layoutDirection)
    private var layoutDirection
    
    @EnvironmentObject
    private var vm: PieChartViewModel
    
    let data: ChartData
    let size: CGFloat
    let spendingsCount: Int
    
    @State
    private var id: UUID = .init()
    
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
                .id(id)
            } else {
                APChart(
                    categories(),
                    separators: 0.3,
                    innerRadius: 0.73,
                    animation: .default
                ) { element in
                    APChartSector(element.sum, color: element.resolveColor(colorScheme: colorScheme, increaseContrast: colorSchemeContrast), id: element.id)
                }
                .id(id)
            }
            
            CenterChartView(
                selectedMonth: data.date,
                width: size,
                operationsInMonth: vm.selectedCategory == nil ? data.sum : data.categoriesDict[vm.selectedCategory?.id ?? .init()]?.sum ?? 0,
                spendingsCount: spendingsCount
            )
        }
        .onChange(of: colorScheme) { _ in
            id = .init() // Force chart update on color scheme change
        }
        .onChange(of: data) { _ in
            id = .init() // Force chart update on data change
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
