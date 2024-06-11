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
    @AppStorage(UDKeys.defaultCurrency.rawValue) var defaultCurrency: String = Locale.current.currencyCode ?? "USD"

    @State private var itemSelected: Int = -1
    
    var body: some View {
        VStack(alignment: .center) {
            BarChart(itemSelected: $itemSelected)
            
            Divider()
                .padding(.vertical, 5)
            
            legend
        }
        .onDisappear {
            itemSelected = -1
        }
    }
    
    var legend: some View {
        switch itemSelected {
        case 0...6:
            return legendGenerator(data: cdm.barChartData.bars.sorted(by: { $0.key > $1.key }), index: itemSelected)
        default:
            return legendGenerator(data: nil, index: 0)
        }
    }
    
    private func legendGenerator(data: [(key: Date, value: Double)]?, index: Int) -> some View {
        var date: String = ""
        
        if let key = data?[index].key {
            date = dateFormat(key)
        } else {
            date = NSLocalizedString("past-7-days-home", comment: "")
        }
        
        var amount: String = ""
        if let value = data?[index].value {
            amount = value.formatted(.currency(code: defaultCurrency))
        } else {
            amount = cdm.barChartData.sum.formatted(.currency(code: defaultCurrency))
        }
        
        return VStack {
            Text(date)
            Text(amount)
                .amountStyle()
                .padding(-3)
            
//            Text(itemSelected == -1 ? "Average: \((cdm.barChartData.sum/7).formatted(.currency(code: defaultCurrency))) a day" : countAnalytics(data?[index].value ?? 0))
        }
    }
    
    private func dateFormat(_ date: Date) -> String {
        var dateFormatter: DateFormatter {
            let formatter: DateFormatter = .init()
            formatter.timeStyle = .none
            formatter.dateStyle = .medium
            return formatter
        }
        
        if Calendar.current.isDateInToday(date) {
            return NSLocalizedString("Today", comment: "")
        } else if Calendar.current.isDateInYesterday(date) {
            return NSLocalizedString("Yesterday", comment: "")
        } else {
            return dateFormatter.string(from: date)
        }
    }
}

struct BarChartGenerator_Previews: PreviewProvider {
    static var previews: some View {
        BarChartGenerator()
    }
}
