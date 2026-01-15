//
//  AddSpendingViewModel.swift
//  Squirrel
//
//  Created by PinkXaciD on 2022/11/22.
//

import SwiftUI
import Combine
#if DEBUG
import OSLog
#endif

final class AddSpendingViewModel: ViewModel {
    
    var cdm: CoreDataModel
    
    private var rvm: RatesViewModel
    
    private let places: [String: Place]
    
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
    @Published
    var filteredSuggestions: [String] = .init()
    @Published
    var placeFieldPosition: CGFloat = 0
    
    #if DEBUG
    let vmStateLogger: Logger
    #endif
    
    private var subscription: AnyCancellable?
    
    init(ratesViewModel rvm: RatesViewModel, coreDataModel cdm: CoreDataModel, shortcut: AddSpendingShortcut? = nil, places: [String: Place]) {
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
        self.places = places
        
        #if DEBUG
        self.vmStateLogger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
        vmStateLogger.debug("\(#function) called")
        #endif
        
        self.subscription = subscribeToInput()
    }
    
    deinit {
        #if DEBUG
        vmStateLogger.debug("\(#function) called")
        #endif
        
        subscription?.cancel()
    }
    
    private func dismissAction() {
        DispatchQueue.main.async {
            self.dismiss = true
        }
    }
    
    private func subscribeToInput() -> AnyCancellable {
        return self.$place
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.filteredSuggestions = self?.filterSuggestions(userInput: value.trimmingCharacters(in: .whitespacesAndNewlines)) ?? []
            }
    }
    
    private func filterSuggestions(userInput: String) -> [String] {
        var result = [String]()
        var count = 0

        for p in places.values.sorted() {
            if match(source: userInput.normalize(), target: p.normalized) {
                #if DEBUG
                result.append(p.weight.formatted() + " | " + p.place)
                #else
                result.append(p.place)
                #endif
                count += 1
                
                if count >= 5 {
                    break
                }
            }
        }
        
        return result
    }
    
    private func match(source: String, target: String) -> Bool {
        let lenDiff: Int = target.count - source.count

        if lenDiff < 0 {
            return false
        }

        if lenDiff == 0 && source == target {
            return true
        }

        var target: String = target
        
        outerLoop: for char1 in source {
            for (i, char2) in target.enumerated() {
                if char1 == char2 {
                    target = String(target.suffix(target.count - (i + 1)))
                    continue outerLoop
                }
            }

            return false
        }

        return true
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
