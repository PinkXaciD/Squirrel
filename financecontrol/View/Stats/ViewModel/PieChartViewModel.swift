//
//  PieChartLazyPageViewViewModel.swift
//  financecontrol
//
//  Created by PinkXaciD on R 6/02/03.
//

import SwiftUI
import ApplePie

final class PieChartViewModel: ViewModel {
    @AppStorage("defaultCurrency") private var defaultCurrency: String = Locale.current.currencyCode ?? "USD"
    @ObservedObject private var cdm: CoreDataModel
    @Published var selection: Int = 0
    @Published var content: [PieChartCompleteView<CenterChartView>] = []
    @Published var selectedCategory: CategoryEntity? = nil
    let size: CGFloat
    
    init(selection: Int = 0, contentSize size: CGFloat, cdm: CoreDataModel) {
        self._cdm = .init(initialValue: cdm)
        self.size = size
        
        let chartData = cdm.getChartData()
        
        var data: [PieChartCompleteView<CenterChartView>] = []
        var count = 0
        for element in chartData {
            data.append(
                .init(
                    chart: APChart(
                        separators: 0.15,
                        innerRadius: 0.73,
                        data: setData(element.categories)
                    ),
                    center: CenterChartView(
                        selectedMonth: element.date,
                        width: size,
                        operationsInMonth: element.categories
                    ),
                    count: count,
                    size: size
                )
            )
            
            count += 1
        }
        
        self.content = data
    }
    
    func updateData() {
        let chartData: [ChartData] = cdm.getChartData(categoryName: selectedCategory?.name)
        
        var data: [PieChartCompleteView<CenterChartView>] = []
        var count = 0
        
//        if let selectedCategory = selectedCategory {
//            var places: [String:Double] = [:]
//            
//            for element in chartData {
//                guard 
//                    let index = element.categories.firstIndex(where: { $0.name == selectedCategory.name })
//                else {
//                    continue
//                }
//                
//                for spending in element.categories[index].spendings {
//                    let spendingName = spending.place.isEmpty ? "Unknown" : spending.place
//                    print(spendingName)
//                    
//                    if let existing = places[spendingName] {
//                        places.updateValue(existing + spending.amountUSDWithReturns, forKey: spendingName)
//                    } else {
//                        places.updateValue(spending.amountUSDWithReturns, forKey: spendingName)
//                    }
//                }
//            }
//            
//            print(places)
//        }
            
        for element in chartData {
            data.append(
                .init(
                    chart: APChart(
                        separators: 0.15,
                        innerRadius: 0.73,
                        data: setData(element.categories)
                    ),
                    center: CenterChartView(
                        selectedMonth: element.date,
                        width: size,
                        operationsInMonth: element.categories
                    ),
                    count: count,
                    size: size
                )
            )
            
            count += 1
        }
        
        self.content = data
    }
    
    private func setData(_ operations: [CategoryEntityLocal]) -> [APChartSectorData] {
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
}
