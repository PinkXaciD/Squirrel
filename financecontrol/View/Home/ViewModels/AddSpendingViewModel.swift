//
//  AddSpendingViewModel.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/11/22.
//

import SwiftUI
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
    
    init(ratesViewModel rvm: RatesViewModel, coreDataModel cdm: CoreDataModel) {
        self.amount = ""
        self.currency = UserDefaults.standard.string(forKey: "defaultCurrency") ?? Locale.current.currencyCode ?? "USD"
        self.date = .now
        self.categoryName = "Select Category"
        self.categoryId = .init()
        self.place = ""
        self.comment = ""
        self.rvm = rvm
        self.cdm = cdm
        
        #if DEBUG
        self.vmStateLogger = Logger(subsystem: Bundle.mainIdentifier, category: "ViewModel state")
        vmStateLogger.notice("AddSpendingViewModel init called")
        #endif
    }
    
    #if DEBUG
    deinit {
        vmStateLogger.notice("AddSpendingViewModel deinit called")
    }
    #endif
    
    func done() {
        if let doubleAmount = Double(amount.replacingOccurrences(of: ",", with: ".")) {
            var spending: SpendingEntityLocal = .init(
                amount: doubleAmount,
                currency: currency,
                date: date,
                place: place,
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
                    let oldRates = try? await rvm.getRates(date).rates
                    await MainActor.run {
                        if let oldRates = oldRates {
                            spending.amountUSD = doubleAmount / (oldRates[currency] ?? 1)
                        } else {
                            spending.amountUSD = doubleAmount / (rvm.rates[currency] ?? 1)
                        }
                        
                        cdm.addSpending(spending: spending)
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
