//
//  EditSpendingViewModel.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/11/23.
//

import SwiftUI
#if DEBUG
import OSLog
#endif

final class EditSpendingViewModel: ViewModel {
    var cdm: CoreDataModel
    var rvm: RatesViewModel
    var entity: SpendingEntity
    
    @Published 
    var amount: String
    @Published
    var currency: String
    @Published
    var date: Date
    @Published
    var category: CategoryEntity?
    @Published
    var place: String
    @Published
    var comment: String
    
    @Published
    var isLoading: Bool = false
    
    #if DEBUG
    let vmStateLogger: Logger
    #endif
    
    init(ratesViewModel rvm: RatesViewModel, coreDataModel cdm: CoreDataModel, entity: SpendingEntity) {
        let formatter = NumberFormatter.currency
        
        self.cdm = cdm
        self.rvm = rvm
        self.entity = entity
        self.amount = formatter.string(from: entity.amount as NSNumber) ?? "\(entity.amount)".replacingOccurrences(of: ".", with: Locale.current.decimalSeparator ?? ".")
        self.currency = entity.wrappedCurrency
        self.date = entity.wrappedDate
        self.category = entity.category
        self.place = entity.place ?? ""
        self.comment = entity.comment ?? ""
        
        #if DEBUG
        self.vmStateLogger = Logger(subsystem: Bundle.mainIdentifier, category: "ViewModel state")
        vmStateLogger.debug("EditSpendingViewModel init called")
        #endif
    }
    
    deinit {
        #if DEBUG
        vmStateLogger.debug("EditSpendingViewModel deinit called")
        #endif
    }
    
    func done() {
        guard let catID = self.category?.id else { return }
        
        DispatchQueue.global(qos: .utility).async { [weak self, catID] in
            guard let self else { return }
            
            let formatter = NumberFormatter()
            
            guard let number = formatter.number(from: amount) else {
                ErrorType(
                    errorDescription: "Failed to edit expense",
                    failureReason: "Cannot convert amount to number",
                    recoverySuggestion: "Try again"
                )
                .publish()
                
                return
            }
            
            let doubleAmount = Double(truncating: number)
            
            var spending: SpendingEntityLocal = .init(
                amountUSD: 0,
                amount: doubleAmount,
                amountWithReturns: 0,
                amountUSDWithReturns: 0,
                comment: self.comment.trimmingCharacters(in: .whitespacesAndNewlines),
                currency: self.currency,
                date: self.date,
                place: self.place.trimmingCharacters(in: .whitespacesAndNewlines),
                categoryId: catID
            )
            
            if self.currency == "USD" {
                spending.amountUSD = doubleAmount
                cdm.editSpending(spending: entity, newSpending: spending)
                DispatchQueue.main.async {
                    self.end()
                }
                
                #if DEBUG
                let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
                logger.log("Currency is USD, skipping rates fetching...")
                #endif
                
                return
            }
            
            DispatchQueue.main.async {
                if Calendar.gmt.isDate(self.entity.wrappedDate, inSameDayAs: self.date), self.entity.wrappedCurrency == self.currency {
                    spending.amountUSD = (spending.amount / self.entity.amount) * self.entity.amountUSD
                    self.cdm.editSpending(spending: self.entity, newSpending: spending, exchangeRate: spending.amount / self.entity.amount)
                    self.end()
                    return
                }
            }
            
            if !Calendar.gmt.isDateInToday(date) {
                Task { [spending] in
                    let oldRates = try? await self.rvm.getRates(self.date).rates.rates
                    
                    await MainActor.run { [spending] in
                        let isHistoricalRatesUnavailable: Bool = oldRates == nil
                        var spendingCopy = spending
                        if let oldRates = oldRates {
                            spendingCopy.amountUSD = doubleAmount / (oldRates[self.currency] ?? 1)
                        } else {
                            spendingCopy.amountUSD = doubleAmount / (self.rvm.rates[self.currency] ?? 1)
                        }
                        
                        self.cdm.editSpending(spending: self.entity, newSpending: spendingCopy, addToFetchQueue: isHistoricalRatesUnavailable, exchangeRate: oldRates?[self.currency] ?? 1)
                        self.end()
                    }
                }
            } else {
                spending.amountUSD = doubleAmount / (rvm.rates[currency] ?? 1)
                
                cdm.editSpending(spending: entity, newSpending: spending, exchangeRate: (rvm.rates[currency] ?? 1))
                DispatchQueue.main.async {
                    self.end()
                }
            }
        }
    }
    
    private func end() {
        self.isLoading = false
        
        NotificationCenter.default.post(name: NSNotification.Name("DismissEditSpendingView"), object: nil)
    }
    
    func clear() {
        let formatter = NumberFormatter.currency
        
        self.amount = formatter.string(from: entity.amount as NSNumber) ?? "\(entity.amount)".replacingOccurrences(of: ".", with: Locale.current.decimalSeparator ?? ".")
        self.currency = entity.wrappedCurrency
        self.date = entity.wrappedDate
        self.category = entity.category
        self.place = entity.place ?? ""
        self.comment = entity.comment ?? ""
    }
    
    func removeReturn(_ returnEntity: ReturnEntity) {
        entity.removeFromReturns(returnEntity)
        cdm.manager.save()
    }
}
