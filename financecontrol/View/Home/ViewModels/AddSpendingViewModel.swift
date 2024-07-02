//
//  AddSpendingViewModel.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/11/22.
//

import SwiftUI
import Combine
#if DEBUG
import OSLog
#endif

final class AddSpendingViewModel: ViewModel {
    @ObservedObject 
    internal var cdm: CoreDataModel
    @ObservedObject
    private var rvm: RatesViewModel
    
    @Published 
    var amount: String
    @Published
    var currency: String
    @Published
    var date: Date
    @Published
    var categoryHasChanged: Bool
    @Published
    var categoryId: UUID
    @Published
    var place: String
    @Published
    var comment: String
    @Published
    var popularCategories: [CategoryEntity] = []
    
    #if DEBUG
    let vmStateLogger: Logger
    #endif
    
    var cancellables = Set<AnyCancellable>()
    
    init(ratesViewModel rvm: RatesViewModel, coreDataModel cdm: CoreDataModel, shortcut: AddSpendingShortcut? = nil) {
        if let shortcut {
            var formatter: NumberFormatter {
                let formatter = NumberFormatter()
                formatter.maximumFractionDigits = 2
                formatter.minimumFractionDigits = 0
                formatter.decimalSeparator = Locale.current.decimalSeparator ?? "."
                return formatter
            }
            
            if let shortcutAmount = shortcut.amount {
                self.amount = formatter.string(from: shortcutAmount as NSNumber) ?? ""
            } else {
                self.amount = ""
            }
            
            self.currency = shortcut.currency ?? UserDefaults.standard.string(forKey: UDKeys.defaultSelectedCurrency.rawValue) ?? UserDefaults.standard.string(forKey: UDKeys.defaultCurrency.rawValue) ?? Locale.current.currencyCode ?? "USD"
            self.date = Date()
            
            if let categoryID = shortcut.categoryID {
                self.categoryId = categoryID
                self.categoryHasChanged = true
            } else {
                self.categoryId = .init()
                self.categoryHasChanged = false
            }
            
            self.place = shortcut.place ?? ""
            self.comment = shortcut.comment ?? ""
        } else {
            self.amount = ""
            self.currency = UserDefaults.standard.string(forKey: UDKeys.defaultSelectedCurrency.rawValue) ?? UserDefaults.standard.string(forKey: UDKeys.defaultCurrency.rawValue) ?? Locale.current.currencyCode ?? "USD"
            self.date = .now
            self.categoryId = .init()
            self.categoryHasChanged = false
            self.place = ""
            self.comment = ""
        }
        
        self.rvm = rvm
        self.cdm = cdm
        
        #if DEBUG
        self.vmStateLogger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
        vmStateLogger.debug("\(#function) called")
        #endif
        
        countPopularCategories()
        subscribeToId()
    }
    
    deinit {
        #if DEBUG
        vmStateLogger.debug("\(#function) called")
        #endif
        
        cancellables.cancelAll()
    }
    
    private func countPopularCategories() {
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            
            let sortedCategories = self.cdm.savedCategories.sorted { $0.spendings?.allObjects.count ?? 0 > $1.spendings?.allObjects.count ?? 0 }
            let range = 0..<(sortedCategories.count > 5 ? 5 : sortedCategories.count)
            withAnimation {
                self.popularCategories = Array(sortedCategories[range])
            }
        }
    }
    
    func done() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self else { return }
            
            guard self.cdm.findCategory(categoryId) != nil else { return }
            
            let formatter = NumberFormatter()
            
            if let number = formatter.number(from: amount) {
                let doubleAmount = Double(truncating: number)
                
                var spending: SpendingEntityLocal = .init(
                    amount: doubleAmount,
                    currency: currency,
                    date: date,
                    place: place.trimmingCharacters(in: .whitespacesAndNewlines),
                    categoryId: categoryId,
                    comment: comment
                )
                
                if currency == "USD" {
                    spending.amountUSD = doubleAmount
                    cdm.addSpending(spending: spending)
                    #if DEBUG
                    let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
                    logger.log("Currency is USD, skipping rates fetching...")
                    #endif
                    return
                }
                
                if Calendar.current.isDateInToday(date) {
                    spending.amountUSD = doubleAmount / (rvm.rates[currency] ?? 1)
                    
                    cdm.addSpending(spending: spending)
                } else {
                    Task {
                        let oldRates = try? await self.rvm.getRates(self.date).rates
                        await MainActor.run {
                            if let oldRates = oldRates {
                                spending.amountUSD = doubleAmount / (oldRates[self.currency] ?? 1)
                            } else {
                                spending.amountUSD = doubleAmount / (self.rvm.rates[self.currency] ?? 1)
                            }
                            
                            self.cdm.addSpending(spending: spending)
                        }
                    }
                }
            } else {
                ErrorType(
                    errorDescription: "Failed to add expence",
                    failureReason: "Cannot convert amount to number",
                    recoverySuggestion: "Try again"
                )
                .publish()
            }
        }
    }
    
    private func subscribeToId() {
        self.$categoryId
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] _ in
                if self?.categoryHasChanged != true {
                    self?.categoryHasChanged = true
                }
            }
            .store(in: &cancellables)
    }
}
