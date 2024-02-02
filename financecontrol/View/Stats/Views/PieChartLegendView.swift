//
//  PieChartLegendView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 6/02/03.
//

import SwiftUI

struct PieChartLegendView: View {
    @EnvironmentObject
    private var lpvvm: PieChartLazyPageViewViewModel
    @EnvironmentObject
    private var cdm: CoreDataModel
    @EnvironmentObject
    private var rvm: RatesViewModel
    
    @AppStorage("defaultCurrency")
    private var defaultCurrency: String = Locale.current.currencySymbol ?? "USD"
    
    
    @Binding
    var filterCategories: [CategoryEntity]
    @Binding
    var applyFilters: Bool
    
    var body: some View {
        let operationsInMonthSorted = cdm.operationsInMonth(
            .now.getFirstDayOfMonth(
                -lpvvm.selection
            )
        ).sorted { first, second in
            var firstSum: Double = 0
            var secondSum: Double = 0
            for spending in first.spendings {
                firstSum += spending.amountUSDWithReturns
            }
            for spending in second.spendings {
                secondSum += spending.amountUSDWithReturns
            }
            return firstSum > secondSum
        }
        
        return HStack {
            LazyVStack (alignment: .leading, spacing: 10) {
                ForEach(operationsInMonthSorted) { category in
                    let amount: Double = countCategorySpendings(category)
                    
                    HStack {
                        Text(category.name)
                            .font(.system(size: 14).bold())
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .foregroundColor(.white)
                            .background {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color[category.color])
                            }
                        
                        Text(amount.formatted(.currency(code: defaultCurrency)))
                    }
                    .padding(.vertical, 3)
                    .padding(.trailing, 6)
                    .padding(.leading, 3)
                    .background {
                        RoundedRectangle(cornerRadius: 7)
                            .fill(Color[category.color])
                            .opacity(0.3)
                    }
                    .id(UUID())
                    .onTapGesture {
                        if let category = cdm.findCategory(category.id) {
                            withAnimation {
                                addToFilter(category)
                            }
                        }
                    }
                    .grayscale((isFiltered(category) || filterCategories.isEmpty) ? 0 : 1)
                }
            }
            Spacer()
        }
        .font(.system(size: 14))
    }
    
    private func countCategorySpendings(_ category: CategoryEntityLocal) -> Double {
        let defaultCurrencyValue = rvm.rates[defaultCurrency] ?? 1
        var result: Double = 0
        for spending in category.spendings {
            if spending.currency == defaultCurrency {
                result += spending.amountWithReturns
            } else {
                result += (spending.amountUSDWithReturns * defaultCurrencyValue)
            }
        }
        return result
    }
    
    private func addToFilter(_ category: CategoryEntity) {
        if !filterCategories.contains(category) {
            filterCategories.append(category)
            applyFilters = true
        } else {
            guard let index: Int = filterCategories.firstIndex(of: category) else {
                return
            }
            filterCategories.remove(at: index)
            if filterCategories.isEmpty && lpvvm.selection == 0 {
                applyFilters = false
            }
        }
    }
    
    private func isFiltered(_ localCategory: CategoryEntityLocal) -> Bool {
        if let category = cdm.findCategory(localCategory.id) {
            return filterCategories.contains(category)
        } else {
            return false
        }
    }
}
