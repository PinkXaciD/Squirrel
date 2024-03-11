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
    @EnvironmentObject
    private var fvm: FiltersViewModel
    
    let category: TSCategoryEntity
    
//    var isActive: Bool = true
    
    var body: some View {
        Button {
            if let category = cdm.findCategory(category.id ?? .init()) {
                if fvm.filterCategories.isEmpty {
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
                
                withAnimation {
                    fvm.updateList = true
                }
            } else {
                withAnimation {
                    pcvm.selectedCategory = nil
                    pcvm.updateData()
                }
                
                if fvm.filterCategories.count == 1 {
                    withAnimation {
                        fvm.clearFilters()
                    }
                }
                
                withAnimation {
                    fvm.updateList = true
                }
            }
        } label: {
            HStack {
                Text(category.name ?? "Error")
                    .font(.system(size: 14).bold())
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .foregroundColor(.white)
                    .background {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color[category.color ?? ""])
                    }
                
                Text(category.sumWithReturns.formatted(.currency(code: defaultCurrency)))
            }
            .padding(.vertical, 3)
            .padding(.trailing, 6)
            .padding(.leading, 3)
            .background {
                RoundedRectangle(cornerRadius: 7)
                    .fill(Color[category.color ?? ""])
                    .opacity(0.3)
            }
        }
        .buttonStyle(.plain)
    }
    
    
    private func addToFilter(_ category: CategoryEntity) {
        if let id = category.id, !fvm.filterCategories.contains(id) {
            fvm.filterCategories.append(id)
            fvm.startFilterDate = Date().getFirstDayOfMonth(-pcvm.selection)
            fvm.endFilterDate = Date().getFirstDayOfMonth(-pcvm.selection + 1)
            fvm.applyFilters = true
        } else {
            guard
                let id = category.id,
                let index: Int = fvm.filterCategories.firstIndex(of: id)
            else {
                return
            }
            fvm.filterCategories.remove(at: index)
            if fvm.filterCategories.isEmpty /*&& pcvm.selection == 0*/ {
                fvm.clearFilters()
            }
        }
    }
}
