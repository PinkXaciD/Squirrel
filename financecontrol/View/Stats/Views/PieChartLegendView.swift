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
    
    @AppStorage(UDKeys.defaultCurrency)
    private var defaultCurrency: String = Locale.current.currencyCode ?? "USD"
    
    @Binding
    var minimize: Bool
    
//    let operationsInMonthSorted: [CategoryEntityLocal]
    
    var body: some View {
        let data = pcvm.data[(pcvm.selection >= pcvm.data.count || pcvm.selection < 0) ? 0 : pcvm.selection]
        
        if minimize {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(data.categories.sorted(by: >)) { category in
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
                    ForEach(data.categories.sorted(by: >)) { category in
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
