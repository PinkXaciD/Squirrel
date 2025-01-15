//
//  BarChart.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/08.
//

import SwiftUI
import CoreData

struct BarChart: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    @ObservedObject var vm: BarChartViewModel
    
    @Binding var itemSelected: Int
    @Binding var showAverage: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // MARK: Avg dashed line
                if !vm.data.sum.isZero {
                    Line()
                        .stroke(style: StrokeStyle(lineWidth: (showAverage ? 1.5 : 1), dash: [5]))
                        .frame(height: 2)
                        .offset(y: -(10 + countAvgBarHeight()))
                        .foregroundColor(.secondary.opacity(showAverage ? 0.7 : 0.3))
                }
                
                VStack {
                    HStack(alignment: .bottom, spacing: 18) {
                        ForEach(vm.data.bars.sorted(by: { $0.key < $1.key }), id: \.key) { data in
                            BarChartBar(
                                index: countIndex(data.key),
                                data: (key: data.key, value: countBarHeight(maxHeight: geometry.size.height - 25, value: data.value)),
                                isActive: isActive(index: countIndex(data.key)),
                                maxHeight: geometry.size.height - 25
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 5.01)) // Doesn't work with cornerRadius of 5
                            .onTapGesture {
                                tapActions(index: countIndex(data.key))
                            }
                            .foregroundStyle(isActive(index: countIndex(data.key)) ? Color.accentColor : Color.secondary, Color.secondary)
                        }
                    }
                    
                    HStack(spacing: 18) {
                        ForEach(vm.data.bars.keys.sorted(by: <), id: \.self) { date in
                            Text(date, format: weekdayFormat)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .animation(.smooth, value: vm.data)
            .padding(.horizontal, 10)
        }
        .frame(height: max(UIScreen.main.bounds.height, UIScreen.main.bounds.width) / 5 + 25)
    }
    
    private var weekdayFormat: Date.FormatStyle {
        if horizontalSizeClass == .compact {
            return dynamicTypeSize > .large ? .dateTime.weekday(.narrow) : .dateTime.weekday(.abbreviated)
        } else {
            return dynamicTypeSize > .accessibility1 ? .dateTime.weekday(.abbreviated) : .dateTime.weekday(.wide)
        }
        
    }
    
    private func tapActions(index: Int) {
        if itemSelected == index {
            withAnimation(.linear(duration: 0.1)) {
                itemSelected = -1
            }
        } else {
            withAnimation(.linear(duration: 0.1)) {
                itemSelected = index
            }
        }
    }
    
    private func countBarHeight(maxHeight: CGFloat, value: Double) -> Double {
        let max = vm.data.max
        let height = maxHeight
        
        if max == 0 {
            return 0
        }
        
        return height / max * value
    }
    
    private func isActive(index: Int) -> Bool {
        if itemSelected != -1 {
            return index == itemSelected
        }
        
        return true
    }
    
    private func countIndex(_ date: Date) -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        return Calendar.current.dateComponents([.day], from: date, to: today).day ?? 0
    }
    
    private func countAvgBarHeight() -> Double {
        let avg = vm.data.sum/7
        let height = max(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
        return (height / 5 + 10) / vm.data.max * avg
    }
}

//struct BarChart_Previews: PreviewProvider {
//    static var previews: some View {
//        @State var itemSelected = -1
//        @State var showAverage = false
//        
//        BarChart(vm: .init(context: <#T##NSManagedObjectContext#>), itemSelected: $itemSelected, showAverage: $showAverage)
//            .environmentObject(CoreDataModel())
//    }
//}

final class BarChartViewModel: ViewModel {
    let context: NSManagedObjectContext
    
    @Published
    private(set) var data: NewBarChartData = NewBarChartData()
    @Published
    private(set) var lastFetchDate: Date? = nil
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: NSNotification.Name("UpdatePieChart"), object: nil)
        
        updateData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("UpdatePieChart"), object: nil)
    }
    
    @objc
    private func updateData() {
        context.perform { [weak self] in
            guard let self else { return }
            
            let weekAgo = Calendar.autoupdatingCurrent.startOfDay(for: Date()).addingTimeInterval(.day * -7)
            let defaultCurrency = UserDefaults.standard.string(forKey: UDKey.defaultCurrency.rawValue) ?? "USD"
            let defaultRate = UserDefaults.standard.getRates()?[defaultCurrency] ?? 1
            
            let request = SpendingEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \SpendingEntity.date, ascending: false)]
            request.predicate = NSPredicate(format: "date > %@", weekAgo as CVarArg)
            
            var data = NewBarChartData().bars
            var sum: Double = 0
            
            do {
                let spendings = try context.fetch(request)
                
                for spending in spendings {
                    let startOfDay = Calendar.autoupdatingCurrent.startOfDay(for: spending.wrappedDate)
                    
                    let spendingSum = defaultCurrency == spending.wrappedCurrency ? spending.amountWithReturns : (spending.amountUSDWithReturns * defaultRate)
                    
                    data.updateValue((data[startOfDay] ?? 0) + spendingSum, forKey: startOfDay)
                    
                    sum += spendingSum
                }
                
                self.data = NewBarChartData(sum: sum, bars: data)
                self.lastFetchDate = Date()
            } catch {
                ErrorType(error: error).publish()
            }
        }
    }
}
