//
//  AddSpendingViewModel.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/11/22.
//

import SwiftUI
import OSLog

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
    
    let vmStateLogger: Logger
    
    init(ratesViewModel rvm: RatesViewModel, coreDataModel cdm: CoreDataModel) {
        self.amount = ""
        self.currency = UserDefaults.standard.string(forKey: "defaultCurrency") ?? "USD"
        self.date = .now
        self.categoryName = "Select Category"
        self.categoryId = .init()
        self.place = ""
        self.comment = ""
        self.rvm = rvm
        self.cdm = cdm
        self.vmStateLogger = Logger(subsystem: Bundle.mainIdentifier, category: "ViewModel state")
        vmStateLogger.notice("AddSpendingViewModel init called")
    }
    
    deinit {
        vmStateLogger.notice("AddSpendingViewModel deinit called")
    }
    
    func done() {
        if let doubleAmount = Double(amount) {
            var spending: SpendingEntityLocal = .init(
                amount: doubleAmount,
                currency: currency,
                date: date,
                place: place,
                categoryId: categoryId,
                comment: comment
            )
            
            if !Calendar.current.isDateInToday(date) {
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
            } else {
                spending.amountUSD = doubleAmount / (rvm.rates[currency] ?? 1)
                
                cdm.addSpending(spending: spending)
            }
            
            HapticManager.shared.notification(.success)
        } else {
            HapticManager.shared.notification(.error)
            
            ErrorType(
                errorDescription: "Failed to add expence",
                failureReason: "Cannot convert amount to number",
                recoverySuggestion: "Try again"
            )
            .publish()
        }
    }
}
