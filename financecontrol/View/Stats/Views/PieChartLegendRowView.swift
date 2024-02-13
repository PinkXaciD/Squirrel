//
//  PieChartLegendRowView.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/02/09.
//

import SwiftUI

struct PieChartLegendRowView: View {
    @AppStorage("defaultCurrency")
    private var defaultCurrency: String = Locale.current.currencyCode ?? "USD"
    @EnvironmentObject
    private var cdm: CoreDataModel
    @EnvironmentObject
    private var pcvm: PieChartViewModel
    
    @Binding
    var filterCategories: [CategoryEntity]
    @Binding
    var applyFilters: Bool
    
    let category: CategoryEntityLocal
    
    var isActive: Bool = true
    
    var body: some View {
        Button {
            if let category = cdm.findCategory(isActive ? category.id : .init()) {
                if filterCategories.isEmpty {
                    withAnimation {
                        addToFilter(category)
                    }
                }
                
                if pcvm.selectedCategory == nil {
                    withAnimation {
                        pcvm.selectedCategory = category
                    }
                }
                
                pcvm.updateData()
            } else {
                withAnimation {
                    pcvm.selectedCategory = nil
                    pcvm.updateData()
                }
                
                if filterCategories.count == 1 {
                    withAnimation {
                        filterCategories.removeAll()
                    }
                    
                    if pcvm.selection == 0 {
                        withAnimation {
                            applyFilters = false
                        }
                    }
                }
            }
        } label: {
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
                
                Text(category.sumWithReturns.formatted(.currency(code: defaultCurrency)))
            }
            .padding(.vertical, 3)
            .padding(.trailing, 6)
            .padding(.leading, 3)
            .background {
                RoundedRectangle(cornerRadius: 7)
                    .fill(Color[category.color])
                    .opacity(0.3)
            }
        }
        .buttonStyle(.plain)
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
            if filterCategories.isEmpty && pcvm.selection == 0 {
                applyFilters = false
            }
        }
    }
}
