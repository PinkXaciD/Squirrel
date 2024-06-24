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
    @ObservedObject
    var cdm: CoreDataModel
    @ObservedObject
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
//        guard let doubleAmount = Double(amount.replacingOccurrences(of: ",", with: ".")) else {
//            ErrorType(
//                errorDescription: "Failed to edit expence",
//                failureReason: "Cannot convert amount to number",
//                recoverySuggestion: "Try again"
//            )
//            .publish()
//            
//            return
//        }
//        
//        var spending: SpendingEntityLocal = .init(
//            amountUSD: 0,
//            amount: doubleAmount,
//            amountWithReturns: 0,
//            amountUSDWithReturns: 0,
//            comment: comment,
//            currency: currency,
//            date: date,
//            place: place,
//            categoryId: categoryId
//        )
//        
//        if currency == "USD" {
//            spending.amountUSD = doubleAmount
//            cdm.editSpending(spending: entity, newSpending: spending)
//            #if DEBUG
//            let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
//            logger.log("Currency is USD, skipping rates fetching...")
//            #endif
//            return
//        }
//        
//        if !Calendar.current.isDateInToday(date) {
//            Task {
//                let oldRates = try? await rvm.getRates(date).rates
//                await MainActor.run {
//                    if let oldRates = oldRates {
//                        spending.amountUSD = doubleAmount / (oldRates[currency] ?? 1)
//                    } else {
//                        spending.amountUSD = doubleAmount / (rvm.rates[currency] ?? 1)
//                    }
//                    
//                    cdm.editSpending(spending: entity, newSpending: spending)
//                }
//            }
//        } else {
//            spending.amountUSD = doubleAmount / (rvm.rates[currency] ?? 1)
//            
//            cdm.editSpending(spending: entity, newSpending: spending)
//        }
        
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self else { self?.clear(); return }
            
            guard self.cdm.findCategory(self.categoryId) != nil else { return }
            
            let formatter = NumberFormatter()
            
            guard let number = formatter.number(from: amount) else {
                ErrorType(
                    errorDescription: "Failed to edit expence",
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
                #if DEBUG
                let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
                logger.log("Currency is USD, skipping rates fetching...")
                #endif
                return
            }
            
            if !Calendar.current.isDateInToday(date) {
                Task {
                    let oldRates = try? await self.rvm.getRates(self.date).rates
                    await MainActor.run {
                        if let oldRates = oldRates {
                            spending.amountUSD = doubleAmount / (oldRates[self.currency] ?? 1)
                        } else {
                            spending.amountUSD = doubleAmount / (self.rvm.rates[self.currency] ?? 1)
                        }
                        
                        self.cdm.editSpending(spending: self.entity, newSpending: spending)
                        self.clear()
                    }
                }
            } else {
                spending.amountUSD = doubleAmount / (rvm.rates[currency] ?? 1)
                
                cdm.editSpending(spending: entity, newSpending: spending)
                DispatchQueue.main.async {
                    self.clear()
                }
            }
        }
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
