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
    
    @Binding
    var minimize: Bool
    @Binding
    var selection: Int
    
    let forceExpand: Bool
    
    var body: some View {
        let data = pcvm.data[(selection >= pcvm.data.count || selection < 0) ? 0 : selection]
        
        Group {
            if minimize, !forceExpand {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        if let selectedCategory = pcvm.selectedCategory {
                            ForEach(data.categoriesDict[selectedCategory.id]?.places ?? []) { place in
                                PieChartLegendRowView(category: place)
                            }
                        } else {
                            ForEach(data.categories) { category in
                                PieChartLegendRowView(category: category)
                            }
                            
                            if let otherCategory = data.otherCategory, !pcvm.showOther {
                                PieChartLegendRowView(category: otherCategory)
                            }
                            
                            if pcvm.showOther {
                                ForEach(data.otherCategories) { category in
                                    PieChartLegendRowView(category: category)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 2)
                }
                .font(.system(size: 14))
                .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 0))
                .transaction { transaction in
                    transaction.animation = nil
                }
            } else {
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 10) {
                        if let selectedCategory = pcvm.selectedCategory {
                            ForEach(data.categoriesDict[selectedCategory.id]?.places ?? []) { place in
                                PieChartLegendRowView(category: place)
                            }
                        } else {
                            ForEach(data.categories) { category in
                                PieChartLegendRowView(category: category)
                            }
                            
                            if let otherCategory = data.otherCategory, !pcvm.showOther {
                                PieChartLegendRowView(category: otherCategory)
                            }
                            
                            if pcvm.showOther {
                                ForEach(data.otherCategories) { category in
                                    PieChartLegendRowView(category: category)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .font(.system(size: 14))
                .padding(.horizontal)
                .transaction { transaction in
                    transaction.animation = nil
                }
            }
        }
    }
}
