//
//  PieChartLazyPageViewViewModel.swift
//  financecontrol
//
//  Created by PinkXaciD on R 6/02/03.
//

import SwiftUI
import ApplePie

final class PieChartLazyPageViewViewModel: ViewModel {
    @ObservedObject private var cdm: CoreDataModel
    @Published var selection: Int = 0
    @Published var content: [PieChartCompleteView<CenterChartView>]
    let size: CGFloat
    
    init(selection: Int = 0, contentSize size: CGFloat, cdm: CoreDataModel) {
        
        let chartData = cdm.getChartData()
        
        func setData(_ operations: [CategoryEntityLocal]) -> [APChartSectorData] {
            let result = operations.map { element in
                let value = element.spendings.map { $0.amountUSDWithReturns }.reduce(0, +)
                return APChartSectorData(
                    value,
                    Color[element.color],
                    id: element.id
                )
            }
            
            return result.compactMap { $0 }.filter { $0.value != 0 }.sorted(by: >)
        }
        
        var data: [PieChartCompleteView<CenterChartView>] = []
        var count = 0
        for element in chartData {
            data.append(
                .init(
                    chart: APChart(
                        size: .init(width: size, height: size),
                        separators: 0.3,
                        innerRadius: 0.73,
                        data: setData(element.categories)
                    ),
                    center: CenterChartView(
                        selectedMonth: element.date,
                        width: size,
                        operationsInMonth: element.categories
                    ),
                    count: count
                )
            )
            
            count += 1
        }
        
        self.content = data
        self.size = size
        self._cdm = .init(initialValue: cdm)
    }
    
    func updateData() {
        let chartData = cdm.getChartData()
        
        func setData(_ operations: [CategoryEntityLocal]) -> [APChartSectorData] {
            let result = operations.map { element in
                let value = element.spendings.map { $0.amountUSDWithReturns }.reduce(0, +)
                return APChartSectorData(
                    value,
                    Color[element.color],
                    id: element.id
                )
            }
            
            return result.compactMap { $0 }.filter { $0.value != 0 }.sorted(by: >)
        }
        
        var data: [PieChartCompleteView<CenterChartView>] = []
        var count = 0
        for element in chartData {
            data.append(
                .init(
                    chart: APChart(
                        size: .init(width: size, height: size),
                        separators: 0.3,
                        innerRadius: 0.73,
                        data: setData(element.categories)
                    ),
                    center: CenterChartView(
                        selectedMonth: element.date,
                        width: size,
                        operationsInMonth: element.categories
                    ),
                    count: count
                )
            )
            
            count += 1
        }
        
        self.content = data
    }
}
