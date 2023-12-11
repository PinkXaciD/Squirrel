//
//  BarChartGenerator.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/27.
//

import SwiftUI

struct BarChartGenerator: View {
    @EnvironmentObject var cdm: CoreDataModel
    @EnvironmentObject private var rvm: RatesViewModel
    @AppStorage("defaultCurrency") var defaultCurrency: String = "USD"

    @State private var itemSelected: Int = -1
    
    var body: some View {
        let chartData = BarChartData(data: cdm.savedSpendings, usdRates: rvm.rates)
        let data = chartData.sortData(true)
        
        VStack(alignment: .center) {
            BarChart(itemSelected: $itemSelected, data: data)
            
            Divider()
                .padding(.vertical, 5)
            
            legend
        }
        .onDisappear {
            itemSelected = -1
        }
    }
    
    var legend: some View {
        let chartData = BarChartData(data: cdm.savedSpendings, usdRates: rvm.rates)
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
        var dateFormatter: DateFormatter {
            let formatter: DateFormatter = .init()
            formatter.timeStyle = .none
            formatter.dateStyle = .long
            return formatter
        }
        
        if let key = data?[index].key {
            date = dateFormatter.string(from: key)
        } else {
            date = "Past 7 days"
        }
        
        var amount: String = ""
        if 
            let value = data?[index].value
        {
            amount = value.formatted(.currency(code: defaultCurrency))
        } else {
            amount = String(cdm.operationsSumWeek(rvm.rates[defaultCurrency] ?? 1).formatted(.currency(code: defaultCurrency)))
        }
        
        return VStack {
            Text(LocalizedStringKey(date))
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
