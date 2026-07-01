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
    private let unfilteredPlaces: [Suggestion]
    
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
    var filteredSuggestions: [Suggestion] = .init()
    @Published
    var placeFieldPosition: CGFloat = 0
    @Published
    var isSuggestionSelected: Bool = false
    @Published
    var selectedSuggestion: String? = nil
    
    #if DEBUG
    let vmStateLogger: Logger
    #endif
    
    private var subscription: AnyCancellable?
    private let id: UUID = .init()
    
    struct Suggestion: Identifiable, Hashable {
        let value: String
        let id: UUID
    }
    
    init(
        ratesViewModel rvm: RatesViewModel,
        coreDataModel cdm: CoreDataModel,
        places: [String: Place]
    ) {
        self.amount = ""
        self.currency = UserDefaults.standard.string(forKey: UDKey.defaultSelectedCurrency.rawValue) ?? UserDefaults.standard.string(forKey: UDKey.defaultCurrency.rawValue) ?? Locale.current.currencyCode ?? "USD"
        self.date = .now
        self.selectedCategory = nil
        self.place = ""
        self.comment = ""
        
        self.rvm = rvm
        self.cdm = cdm
        self.places = places
        
        #if DEBUG
        self.vmStateLogger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
        vmStateLogger.debug("\(#function) called")
        #endif
        
        self.unfilteredPlaces = places.values.sorted().prefix(5).map({ Suggestion(value: $0.place, id: UUID()) })
        self.subscription = subscribeToInput()
    }
    
    deinit {
        #if DEBUG
        vmStateLogger.debug("\(#function) called")
        #endif
        
        subscription?.cancel()
    }
    
    private func dismissAction() {
        self.dismiss = true
    }
    
    func updateSuggestions(_ value: String) {
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if self.selectedSuggestion == trimmedValue {
            self.isSuggestionSelected = true
        } else if self.isSuggestionSelected == true {
            self.isSuggestionSelected = false
            self.selectedSuggestion = nil
        }
        
        self.filteredSuggestions = self.filterSuggestions(userInput: trimmedValue)
    }
    
    private func subscribeToInput() -> AnyCancellable {
        return self.$place
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.updateSuggestions(value)
            }
    }
    
    private func filterSuggestions(userInput: String) -> [Suggestion] {
        #if DEBUG
        logger.debug("\(#function)")
        #endif
        
        if userInput.isEmpty {
            return unfilteredPlaces
        }
        
        var result = [Suggestion]()
        var count = 0

        for p in places.values.sorted() {
            if match(source: userInput.normalize(), target: p.normalized) {
                let value = p.place
                
                let suggestion = Suggestion(value: value, id: UUID())
                result.append(suggestion)
                
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
        
        Task { [weak self, catID] in
            guard let self else { return }
            
            let formatter = NumberFormatter.standard
            
            guard let number = formatter.number(from: amount) else {
                await MainActor.run {
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
                
                await MainActor.run { [self] in
                    self.dismissAction()
                }
                
                #if DEBUG
                let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
                logger.log("Currency is USD, skipping rates fetching...")
                #endif
                
                return
            }
            
            spending.amountUSD = doubleAmount / (rvm.rates[currency] ?? 1)
            
            var addToFetchQueue: Bool {
                !Calendar.gmt.isDateInToday(date) || !Calendar.gmt.isDateInToday(rvm.updateTime)
            }
            
            cdm.addSpending(spending: spending, timeZoneIdentifier: self.timeZoneIdentifier, addToFetchQueue: addToFetchQueue)
            
            await MainActor.run { [self] in
                self.dismissAction()
            }
        }
    }
}
