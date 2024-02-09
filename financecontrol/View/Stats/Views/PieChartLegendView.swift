//
//  PieChartLegendView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 6/02/03.
//

import SwiftUI

struct PieChartLegendView: View {
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
    
    var body: some View {
        let operationsInMonthSorted: [CategoryEntityLocal] = cdm.operationsInMonth(
            .now.getFirstDayOfMonth(
                -pcvm.selection
            ),
            categoryName: pcvm.selectedCategory?.name
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
        
        if minimize {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 10) {
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
            .id(UUID())
            .font(.system(size: 14))
            .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 0))
        } else {
            HStack {
                LazyVStack (alignment: .leading, spacing: 10) {
                    ForEach(operationsInMonthSorted) { category in
                        PieChartLegendRowView(
                            filterCategories: $filterCategories,
                            applyFilters: $applyFilters,
                            amount: countCategorySpendings(category),
                            category: category
                        )
                        .id(UUID())
                        .transition(.identity.animation(.none))
                    }
                }
                
                Spacer()
            }
            .font(.system(size: 14))
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
