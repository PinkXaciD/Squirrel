//
//  BarChartGenerator.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/27.
//

import SwiftUI

struct BarChartGenerator: View {
    @EnvironmentObject var vm: CoreDataViewModel
    @EnvironmentObject private var rvm: RatesViewModel
    @AppStorage("defaultCurrency") var defaultCurrency: String = "USD"

    @State private var itemSelected: Int = -1
    
    var body: some View {
        let chartData = BarChartData(data: vm.savedSpendings)
        let data = chartData.sortData(true)
        
        VStack(alignment: .center) {
            BarChart(itemSelected: $itemSelected, data: data)
            
            Divider()
                .padding(.vertical, 5)
            
            legend
        }
    }
    
    var legend: some View {
        let chartData = BarChartData(data: vm.savedSpendings)
        let data = chartData.sortData(false)
        
        switch itemSelected {
        case 0...6:
            return legendGenerator(data: data, index: itemSelected)
        default:
            return legendGenerator(data: nil, index: 0)
        }
    }
    
    private func legendGenerator(data: [(key: Date, value: Double)]?, index: Int) -> some View {
        var date: String = ""
        if data?[index].key != nil {
            date = dateFormat(date: data?[index].key ?? Date.distantPast, time: false)
        } else {
            date = "Spendings this week"
        }
        
        var amount: String = ""
        if data?[index].value != nil {
            amount = ((data?[index].value ?? 0) * (rvm.rates[defaultCurrency.lowercased()] ?? 1))
                .formatted(.currency(code: defaultCurrency)
                )
        } else {
//            amount = lastWeekOperations(vm: vm, currency: defaultCurrency)
            amount = String((vm.operationsSumWeek() * (rvm.rates[defaultCurrency.lowercased()] ?? 1)).formatted(.currency(code: defaultCurrency)))
        }
        
        return VStack {
            Text(date)
            Text(amount)
                .amountStyle()
                .padding(-3)
        }
    }
}

struct BarChartGenerator_Previews: PreviewProvider {
    static var previews: some View {
        BarChartGenerator()
    }
}
