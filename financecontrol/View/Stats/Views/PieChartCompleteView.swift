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
            APChart(separators: 0.15, innerRadius: 0.73) {
                setData(localData.categories)
            }
//            .frame(width: size, height: size)
//            .rotationEffect(layoutDirection == .rightToLeft ? Angle(degrees: 180) : Angle(degrees: 0))
            
            CenterChartView(
                selectedMonth: localData.date,
                width: size,
                operationsInMonth: localData.categories
            )
            #if DEBUG
            .onTapGesture {
                withAnimation {
                    vm.selection = 0
                }
            }
            #endif
        }
    }
    
    private func setData(_ operations: [TSCategoryEntity]) -> [APChartSectorData] {
        let result = operations.map { element in
            APChartSectorData(
                element.sumUSDWithReturns,
                Color[element.color ?? ""],
                id: element.id
            )
        }
        
        return result.filter { $0.value != 0 }
    }
}
