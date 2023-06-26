//
//  PieChartData.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/28.
//

import SwiftUI

class PieChartData {
    init(_ viewModel: CoreDataViewModel) {
        vm = viewModel
    }
    var vm: CoreDataViewModel
    private var currentDegree: Double = 0
    private var previousDegree: Double = 0
    
    func degrees() -> [(Double, Double)] {
        let percentage = getPercentage()
        var degrees: [(Double, Double)] = []
        for item in percentage {
            previousDegree = currentDegree
            currentDegree += item.value/100*360
            degrees.append((previousDegree, currentDegree))
        }
        return degrees
    }
    
    func getPercentage() -> [Dictionary<UUID, Double>.Element] {
        var categories: [UUID:Double] = [:]
        let operationSum: Double = vm.operationsSum()
        for entity in vm.savedSpendings {
            let categorySum = categories[entity.category?.id ?? UUID()] ?? 0.0
            categories.updateValue(categorySum + entity.amountUSD*100/operationSum, forKey: entity.category?.id ?? UUID())
        }
        return categories.sorted(by: { $0.1 > $1.1 })
    }
}
