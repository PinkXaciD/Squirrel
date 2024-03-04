//
//  PieChartLegendView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 6/02/03.
//

import SwiftUI

struct PieChartLegendView: View {
    init(minimize: Binding<Bool>, cdm: CoreDataModel, pcvm: PieChartViewModel) {
        self._minimize = minimize
        
        self.operationsInMonthSorted = cdm.operationsInMonth(
            startDate: .now.getFirstDayOfMonth(-pcvm.selection),
            endDate: .now.getFirstDayOfMonth(-pcvm.selection + 1),
            categoryName: pcvm.selectedCategory?.name
        )
    }
    
    @EnvironmentObject
    private var pcvm: PieChartViewModel
    
    @AppStorage("defaultCurrency")
    private var defaultCurrency: String = Locale.current.currencyCode ?? "USD"
    
    @Binding
    var minimize: Bool
    
    let operationsInMonthSorted: [CategoryEntityLocal]
    
    var body: some View {
        if minimize {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(operationsInMonthSorted) { category in
                        PieChartLegendRowView(category: category)
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
                        PieChartLegendRowView(category: category)
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
