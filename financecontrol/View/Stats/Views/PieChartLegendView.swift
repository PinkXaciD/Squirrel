//
//  PieChartLegendView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 6/02/03.
//

import SwiftUI

struct PieChartLegendView: View {
    internal init(
        filterCategories: Binding<[CategoryEntity]>,
        applyFilters: Binding<Bool>,
        minimize: Binding<Bool>,
        cdm: CoreDataModel,
        pcvm: PieChartViewModel
    ) {
        self._filterCategories = filterCategories
        self._applyFilters = applyFilters
        self._minimize = minimize
        
        self.operationsInMonthSorted = cdm.operationsInMonth(
            startDate: .now.getFirstDayOfMonth(-pcvm.selection),
            endDate: .now.getFirstDayOfMonth(-pcvm.selection + 1),
            categoryName: pcvm.selectedCategory?.name
        ).sorted { first, second in
            return first.spendings.map { $0.amountUSD }.reduce(0, +) > second.spendings.map { $0.amountUSD }.reduce(0, +)
        }
    }
    
    @EnvironmentObject
    private var pcvm: PieChartViewModel
    @EnvironmentObject
    private var cdm: CoreDataModel
    @EnvironmentObject
    private var rvm: RatesViewModel
    
    @AppStorage("defaultCurrency")
    private var defaultCurrency: String = Locale.current.currencyCode ?? "USD"
    
    
    @Binding
    var filterCategories: [CategoryEntity]
    @Binding
    var applyFilters: Bool
    @Binding
    var minimize: Bool
    
    let operationsInMonthSorted: [CategoryEntityLocal]
    
    var body: some View {
        if minimize {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(operationsInMonthSorted) { category in
                        PieChartLegendRowView(
                            filterCategories: $filterCategories,
                            applyFilters: $applyFilters,
                            amount: countCategorySpendings(category),
                            category: category
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
            .font(.system(size: 14))
            .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 0))
            .transaction { transaction in
                transaction.animation = nil
            }
        } else {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(operationsInMonthSorted) { category in
                        PieChartLegendRowView(
                            filterCategories: $filterCategories,
                            applyFilters: $applyFilters,
                            amount: countCategorySpendings(category),
                            category: category
                        )
                    }
                }
                
                Spacer()
            }
            .font(.system(size: 14))
            .transaction { transaction in
                transaction.animation = nil
            }
        }
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
}
