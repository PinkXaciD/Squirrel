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
        self.cdm = cdm
        self.rvm = rvm
        self.entity = entity
        self.amount = "\(entity.amount)".replacingOccurrences(of: ".", with: Locale.current.decimalSeparator ?? ".")
        self.currency = entity.wrappedCurrency
        self.date = entity.wrappedDate
        self.categoryName = entity.categoryName
        self.categoryId = entity.category?.id ?? .init()
        self.place = entity.place ?? ""
        self.comment = entity.comment ?? ""
        
        #if DEBUG
        self.vmStateLogger = Logger(subsystem: Bundle.mainIdentifier, category: "ViewModel state")
        vmStateLogger.notice("EditSpendingViewModel init called")
        #endif
    }
    
    #if DEBUG
    deinit {
        vmStateLogger.notice("EditSpendingViewModel deinit called")
    }
    #endif
    
    func done() {
        guard let doubleAmount = Double(amount.replacingOccurrences(of: ",", with: ".")) else {
            ErrorType(
                errorDescription: "Failed to edit expence",
                failureReason: "Cannot convert amount to number",
                recoverySuggestion: "Try again"
            )
            .publish()
            
            return
        }
        
        var spending: SpendingEntityLocal = .init(
            amountUSD: 0,
            amount: doubleAmount,
            amountWithReturns: 0,
            amountUSDWithReturns: 0,
            comment: comment,
            currency: currency,
            date: date,
            place: place,
            categoryId: categoryId
        )
        
        if currency == "USD" {
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
                let oldRates = try? await rvm.getRates(date).rates
                await MainActor.run {
                    if let oldRates = oldRates {
                        spending.amountUSD = doubleAmount / (oldRates[currency] ?? 1)
                    } else {
                        spending.amountUSD = doubleAmount / (rvm.rates[currency] ?? 1)
                    }
                    
                    cdm.editSpending(spending: entity, newSpending: spending)
                }
            }
        } else {
            spending.amountUSD = doubleAmount / (rvm.rates[currency] ?? 1)
            
            cdm.editSpending(spending: entity, newSpending: spending)
        }
    }
    
    func removeReturn(_ returnEntity: ReturnEntity) {
        entity.removeFromReturns(returnEntity)
        cdm.manager.save()
    }
}
