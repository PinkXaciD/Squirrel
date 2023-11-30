//
//  PieChartView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/26.
//

import SwiftUI
import ApplePie

struct PieChartView: View {
    @EnvironmentObject 
    private var cdm: CoreDataModel
    @EnvironmentObject
    private var rvm: RatesViewModel
    
    @Binding
    var selectedMonth: Int
    @Binding
    var search: String
    
    let size: CGFloat
    let operationsInMonth: [CategoryEntityLocal]
    var chartData: [ChartData]
    
    @AppStorage("defaultCurrency")
    var defaultCurrency: String = "USD"
    
    @State
    private var showLegend: Bool = true
    
    var body: some View {
        Section {
            chart
            
            if !operationsInMonth.isEmpty && showLegend {
                legend
            }
        } footer: {
            if !operationsInMonth.isEmpty {
                expandButton
            }
        }
    }
    
    private var chart: some View {
        HStack {
            Text(verbatim: "")
            
            previousButton
            
            Spacer()

            ZStack {
                APChart(
                    size: .init(width: size, height: size),
                    separators: 0.3,
                    innerRadius: 0.73,
                    data: setData(operationsInMonth)
                )
                .padding(.horizontal)
                
                CenterChartView(
                    selectedMonth: Calendar.current.date(byAdding: .month, value: selectedMonth, to: .now) ?? .now,
                    width: size,
                    operationsInMonth: operationsInMonth
                )
            }
            .frame(height: size * 1.1)
            
            Spacer()
            
            nextButton
            
            Text(verbatim: "")
        }
        .gesture(
            DragGesture().onEnded { value in
                if value.translation.width > 0 && selectedMonth > ((chartData.count - 1) * -1) {
                    decreaseMonth()
                } else if value.translation.width < 0 && selectedMonth < 0 {
                    increaseMonth()
                }
            }
        )
    }
    
    private var previousButton: some View {
        Button {
            decreaseMonth()
        } label: {
            Label("Previous month", systemImage: "chevron.backward")
                .foregroundColor(.accentColor)
                .labelStyle(.iconOnly)
                .font(.title)
        }
        .buttonStyle(.plain)
        .disabled(selectedMonth <= ((chartData.count * -1) + 1))
    }
    
    private var nextButton: some View {
        Button {
            increaseMonth()
        } label: {
            Label("Next month", systemImage: "chevron.forward")
                .foregroundColor(.accentColor)
                .labelStyle(.iconOnly)
                .font(.title)
        }
        .buttonStyle(.plain)
        .disabled(selectedMonth >= 0)
    }
    
    private var legend: some View {
        let operationsInMonthSorted = operationsInMonth.sorted { first, second in
            var firstSum: Double = 0
            var secondSum: Double = 0
            for spending in first.spendings {
                firstSum += spending.amountUSD
            }
            for spending in second.spendings {
                secondSum += spending.amountUSD
            }
            return firstSum > secondSum
        }
        
        return HStack {
            LazyVStack (alignment: .leading, spacing: 10) {
                ForEach(operationsInMonthSorted) { category in
                    let amount: Double = countCategorySpendings(category)
                    
                    HStack {
                        Text(category.name)
                            .font(.system(size: 14).bold())
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .foregroundColor(.white)
                            .background {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color[category.color])
                            }
                        
                        Text(amount.formatted(.currency(code: defaultCurrency)))
                    }
                    .padding(.vertical, 3)
                    .padding(.trailing, 6)
                    .padding(.leading, 3)
                    .background {
                        RoundedRectangle(cornerRadius: 7)
                            .fill(Color[category.color])
                            .opacity(0.3)
                    }
                    .id(UUID())
                    .onTapGesture {
                        withAnimation {
                            search.append("\(category.name) ")
                        }
                    }
                }
            }
            Spacer()
        }
        .font(.system(size: 14))
    }
    
    private var expandButton: some View {
        HStack {
            Spacer()
            
            Image(systemName: "chevron.down")
                .rotationEffect(showLegend ? .degrees(180) : .zero)
                .foregroundColor(.accentColor)
            
            Button(showLegend ? "Minimize" : "Expand") {
                withAnimation {
                    showLegend.toggle()
                }
            }
        }
    }
}

extension PieChartView {
    internal init(selectedMonth: Binding<Int>, search: Binding<String>, size: CGFloat, operationsInMonth: [CategoryEntityLocal], chartData: [ChartData]) {
        self._selectedMonth = selectedMonth
        self._search = search
        self.size = size
        self.operationsInMonth = operationsInMonth
        self.chartData = chartData
    }
    
    private func setData(_ operations: [CategoryEntityLocal]) -> [APChartSectorData] {
        let result = operations.map { element in
            let value = element.spendings.map { $0.amountUSD }.reduce(0, +)
            return APChartSectorData(
                value,
                Color[element.color],
                id: element.id
            )
        }
        
        return result.compactMap { $0 }.sorted(by: >)
    }
    
    private func countCategorySpendings(_ category: CategoryEntityLocal) -> Double {
        let defaultCurrencyValue = rvm.rates[defaultCurrency] ?? 1
        var result: Double = 0
        for spending in category.spendings {
            if spending.currency == defaultCurrency {
                result += spending.amount
            } else {
                result += (spending.amountUSD * defaultCurrencyValue)
            }
        }
        return result
    }
    
    private func increaseMonth() -> Void {
        withAnimation {
            selectedMonth += 1
        }
    }
    
    private func decreaseMonth() -> Void {
        withAnimation {
            selectedMonth -= 1
        }
    }
}

//struct PieChart_Previews: PreviewProvider {
//    static var previews: some View {
//        @StateObject var cdm: CoreDataModel = CoreDataModel()
//        let operationsInMonth = cdm.operationsInMonth((Calendar.current.date(byAdding: .month, value: 0, to: .now) ?? .distantPast))
//
//        PieChartView(selectedMonth: .constant(0), size: 200, operationsInMonth: operationsInMonth)
//            .environmentObject(CoreDataModel())
//    }
//}
