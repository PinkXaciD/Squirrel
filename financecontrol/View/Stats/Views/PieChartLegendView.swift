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
    
    private var verticalPadding: CGFloat {
        if #available(iOS 26, *) {
            return 14
        }
        
        return 10
    }
    
    var body: some View {
        let data = pcvm.data[(selection >= pcvm.data.count || selection < 0) ? 0 : selection]
        
        if !data.categories.isEmpty, pcvm.selectedCategory == nil {
            Divider()
        }
        
        if let selectedCategory = pcvm.selectedCategory, !(data.categoriesDict[selectedCategory.id]?.places ?? []).isEmpty {
            Divider()
        }
        
        Group {
            if minimize {
                ScrollView(.horizontal, showsIndicators: false) {
                    WrappedGlassEffectContainer {
                        HStack(spacing: 10) {
                            content
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, verticalPadding)
                    }
                }
                .transaction { transaction in
                    transaction.animation = nil
                }
                .transition(.opacity)
            } else {
                HStack(spacing: 0) {
                    WrappedGlassEffectContainer {
                        VStack(alignment: .leading, spacing: 10) {
                            content
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, verticalPadding)
                .transaction { transaction in
                    transaction.animation = nil
                }
                .transition(.opacity)
            }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        let data = pcvm.data[(selection >= pcvm.data.count || selection < 0) ? 0 : selection]
        
        if let selectedCategory = pcvm.selectedCategory {
            let places = data.categoriesDict[selectedCategory.id]?.places ?? []
            
            ForEach(places) { place in
                PieChartLegendRowView(category: place)
                    .fixedSize(horizontal: minimize, vertical: false)
            }
        } else {
            ForEach(data.categories) { category in
                PieChartLegendRowView(category: category)
                    .fixedSize(horizontal: minimize, vertical: false)
            }
            
            if let otherCategory = data.otherCategory, !pcvm.showOther {
                PieChartLegendRowView(category: otherCategory)
                    .fixedSize(horizontal: minimize, vertical: false)
            }
            
            if pcvm.showOther {
                ForEach(data.otherCategories) { category in
                    PieChartLegendRowView(category: category)
                        .fixedSize(horizontal: minimize, vertical: false)
                }
            }
        }
    }
}

fileprivate struct WrappedGlassEffectContainer<Content>: View where Content: View {
    let content: () -> Content
    
    var body: some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer {
                content()
            }
        } else {
            content()
        }
    }
}
