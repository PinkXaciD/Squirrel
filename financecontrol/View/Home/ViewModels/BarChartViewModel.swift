//
//  BarChartViewModel.swift
//  Squirrel
//
//  Created by PinkXaciD on 2025/01/21.
//

import CoreData

final class BarChartViewModel: ViewModel {
    let context: NSManagedObjectContext
    
    @Published
    private(set) var data: NewBarChartData = NewBarChartData()
    @Published
    private(set) var lastFetchDate: Date? = nil
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: .UpdatePieChart, object: nil)
        
        updateData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .UpdatePieChart, object: nil)
    }
    
    @objc
    private func updateData() {
        context.perform { [weak self] in
            guard let self else { return }
            
            let weekAgo = Calendar.autoupdatingCurrent.startOfDay(for: Date()).addingTimeInterval(.day * -6)
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
