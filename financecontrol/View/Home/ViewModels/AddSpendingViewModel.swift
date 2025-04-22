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
    
    var cdm: CoreDataModel
    
    private var rvm: RatesViewModel
    
    @Published 
    var amount: String
    @Published
    var currency: String
    @Published
    var date: Date
    @Published
    var selectedCategory: CategoryEntity?
    @Published
    var place: String
    @Published
    var comment: String
    @Published
    var dismiss: Bool = false
    @Published
    var timeZoneIdentifier: String = TimeZone.autoupdatingCurrent.identifier
    
    #if DEBUG
    let vmStateLogger: Logger
    #endif
    
    var cancellables = Set<AnyCancellable>()
    
    init(ratesViewModel rvm: RatesViewModel, coreDataModel cdm: CoreDataModel, shortcut: AddSpendingShortcut? = nil) {
//        if let shortcut {
//            var formatter: NumberFormatter {
//                let formatter = NumberFormatter()
//                formatter.maximumFractionDigits = 2
//                formatter.minimumFractionDigits = 0
//                formatter.decimalSeparator = Locale.current.decimalSeparator ?? "."
//                return formatter
//            }
//            
//            if let shortcutAmount = shortcut.amount {
//                self.amount = formatter.string(from: shortcutAmount as NSNumber) ?? ""
//            } else {
//                self.amount = ""
//            }
//            
//            self.currency = shortcut.currency ?? UserDefaults.standard.string(forKey: UDKeys.defaultSelectedCurrency.rawValue) ?? UserDefaults.standard.string(forKey: UDKeys.defaultCurrency.rawValue) ?? Locale.current.currencyCode ?? "USD"
//            self.date = Date()
//            
//            if let categoryID = shortcut.categoryID {
//                self.selectedCategory = nil
//                self.categoryHasChanged = true
//            } else {
//                self.selectedCategory = nil
//                self.categoryHasChanged = false
//            }
//            
//            self.place = shortcut.place ?? ""
//            self.comment = shortcut.comment ?? ""
//        } else {
            self.amount = ""
            self.currency = UserDefaults.standard.string(forKey: UDKey.defaultSelectedCurrency.rawValue) ?? UserDefaults.standard.string(forKey: UDKey.defaultCurrency.rawValue) ?? Locale.current.currencyCode ?? "USD"
            self.date = .now
            self.selectedCategory = nil
            self.place = ""
            self.comment = ""
//        }
        
        self.rvm = rvm
        self.cdm = cdm
        
        #if DEBUG
        self.vmStateLogger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
        vmStateLogger.debug("\(#function) called")
        #endif
    }
    
    deinit {
        #if DEBUG
        vmStateLogger.debug("\(#function) called")
        #endif
        
        cancellables.cancelAll()
    }
    
    private func dismissAction() {
        DispatchQueue.main.async {
            self.dismiss = true
        }
    }
    
    func done() {
        guard let catID = self.selectedCategory?.id else { return }
        
        DispatchQueue.global(qos: .utility).async { [weak self, catID] in
            guard let self else { return }
            
            let formatter = NumberFormatter.standard
            
            guard let number = formatter.number(from: amount) else {
                DispatchQueue.main.async {
                    ErrorType(
                        errorDescription: "Failed to add expense",
                        failureReason: "Cannot convert amount to number",
                        recoverySuggestion: "Try again"
                    )
                    .publish()
                }
                
                return
            }
        
            let doubleAmount = Double(truncating: number)
            
            var spending: SpendingEntityLocal = .init(
                amount: doubleAmount,
                currency: currency,
                date: date,
                place: place.trimmingCharacters(in: .whitespacesAndNewlines),
                categoryId: catID,
                comment: comment
            )
            
            if self.currency == "USD" {
                spending.amountUSD = doubleAmount
                cdm.addSpending(spending: spending, timeZoneIdentifier: self.timeZoneIdentifier)
                DispatchQueue.main.async {
                    self.dismiss = true
                }
                #if DEBUG
                let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
                logger.log("Currency is USD, skipping rates fetching...")
                #endif
                return
            }
            
            if Calendar.gmt.isDateInToday(date) {
                spending.amountUSD = doubleAmount / (rvm.rates[currency] ?? 1)
                
                cdm.addSpending(spending: spending, timeZoneIdentifier: self.timeZoneIdentifier)
                DispatchQueue.main.async {
                    self.dismiss = true
                }
            } else {
                Task { [spending, self] in
                    let oldRates = try? await self.rvm.getRates(self.date).rates.rates
                    
                    await MainActor.run { [spending, self] in
                        let isHistoricalRatesUnvailable: Bool = oldRates == nil
                        var spendingCopy = spending
                        
                        if let oldRates = oldRates {
                            spendingCopy.amountUSD = doubleAmount / (oldRates[self.currency] ?? 1)
                        } else {
                            spendingCopy.amountUSD = doubleAmount / (self.rvm.rates[self.currency] ?? 1)
                        }
                        
                        self.cdm.addSpending(spending: spendingCopy, timeZoneIdentifier: self.timeZoneIdentifier, addToFetchQueue: isHistoricalRatesUnvailable)
                        
                        self.dismissAction()
                    }
                }
            }
        }
    }
}
