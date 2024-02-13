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
        )
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
}
