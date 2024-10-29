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
    @AppStorage(UDKey.defaultCurrency.rawValue) var defaultCurrency: String = Locale.current.currencyCode ?? "USD"

    @State private var itemSelected: Int = -1
    @State private var showAverage: Bool = false
    
    var body: some View {
        VStack(alignment: .center) {
            BarChart(itemSelected: $itemSelected, showAverage: $showAverage)
            
            Divider()
                .padding(.vertical, 5)
            
            Button {
                if itemSelected == -1 {
                    withAnimation(.default.speed(3)) {
                        showAverage.toggle()
                    }
                } else {
                    withAnimation(.default.speed(3)) {
                        itemSelected = -1
                    }
                }
            } label: {
                legend
            }
            .buttonStyle(.plain)
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
            date = showAverage ? NSLocalizedString("average-home-barchart", comment: "") : NSLocalizedString("past-7-days-home", comment: "")
        }
        
        var amount: Double = 0
        
        if let value = data?[index].value {
            amount = value
        } else {
            amount = showAverage ? (cdm.barChartData.sum / 7) : cdm.barChartData.sum
        }
        
        return VStack {
            Text(date)
            
            if cdm.lastFetchDate == nil {
                Text(verbatim: " ")
                    .amountStyle()
                    .padding(-3)
                    .transition(.opacity)
            } else {
                Text(Locale.autoupdatingCurrent.currencyNarrowFormat(amount, currency: defaultCurrency, showCurrencySymbol: true) ?? amount.formatted(.currency(code: defaultCurrency)))
                    .amountStyle()
                    .padding(-3)
                    .transition(.opacity)
            }
        }
        .animation(.easeOut, value: cdm.lastFetchDate)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter: DateFormatter = .init()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        return formatter
    }
    
    private func dateFormat(_ date: Date) -> String {
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
