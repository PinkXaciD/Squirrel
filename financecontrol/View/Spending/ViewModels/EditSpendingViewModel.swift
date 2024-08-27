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

final class EditSpendingViewModel: SpendingViewModel {
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
    var categoryName: String
    @Published
    var categoryId: UUID
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
        var formatter: NumberFormatter {
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = 0
            formatter.decimalSeparator = Locale.current.decimalSeparator ?? "."
            return formatter
        }
        
        self.cdm = cdm
        self.rvm = rvm
        self.entity = entity
        self.amount = formatter.string(from: entity.amount as NSNumber) ?? "\(entity.amount)".replacingOccurrences(of: ".", with: Locale.current.decimalSeparator ?? ".")
        self.currency = entity.wrappedCurrency
        self.date = entity.wrappedDate
        self.categoryName = entity.categoryName
        self.categoryId = entity.category?.id ?? .init()
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
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self else { return }
            
            guard self.cdm.findCategory(self.categoryId) != nil else { return }
            
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
                comment: self.comment,
                currency: self.currency,
                date: self.date,
                place: self.place.trimmingCharacters(in: .whitespaces),
                categoryId: self.categoryId
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
                    self.cdm.editSpending(spending: self.entity, newSpending: spending)
                    self.end()
                    return
                }
            }
            
            if !Calendar.gmt.isDateInToday(date) {
                Task { [spending] in
                    let oldRates = try? await self.rvm.getRates(self.date).rates
                    await MainActor.run { [spending] in
                        let isHistoricalRatesUnavailable: Bool = oldRates == nil
                        var spendingCopy = spending
                        if let oldRates = oldRates {
                            spendingCopy.amountUSD = doubleAmount / (oldRates[self.currency] ?? 1)
                        } else {
                            spendingCopy.amountUSD = doubleAmount / (self.rvm.rates[self.currency] ?? 1)
                        }
                        
                        self.cdm.editSpending(spending: self.entity, newSpending: spendingCopy, addToFetchQueue: isHistoricalRatesUnavailable)
                        self.end()
                    }
                }
            } else {
                spending.amountUSD = doubleAmount / (rvm.rates[currency] ?? 1)
                
                cdm.editSpending(spending: entity, newSpending: spending)
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
        var formatter: NumberFormatter {
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = 0
            formatter.decimalSeparator = Locale.current.decimalSeparator ?? "."
            return formatter
        }
        
        self.amount = formatter.string(from: entity.amount as NSNumber) ?? "\(entity.amount)".replacingOccurrences(of: ".", with: Locale.current.decimalSeparator ?? ".")
        self.currency = entity.wrappedCurrency
        self.date = entity.wrappedDate
        self.categoryName = entity.categoryName
        self.categoryId = entity.category?.id ?? .init()
        self.place = entity.place ?? ""
        self.comment = entity.comment ?? ""
    }
    
    func removeReturn(_ returnEntity: ReturnEntity) {
        entity.removeFromReturns(returnEntity)
        cdm.manager.save()
    }
}
