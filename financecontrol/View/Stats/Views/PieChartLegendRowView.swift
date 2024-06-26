//
//  PieChartLegendRowView.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/02/09.
//

import SwiftUI

struct PieChartLegendRowView: View {
    @AppStorage(UDKeys.defaultCurrency.rawValue)
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
            guard !pcvm.isScrollDisabled else {
                return
            }
            
            if let catId = category.id, let category = cdm.findCategory(catId) {
                if pcvm.selectedCategory == nil {
                    pcvm.selectedCategory = category
                }
                
                pcvm.updateData()
            } else if !pcvm.showOther, category.name == NSLocalizedString("category-name-other", comment: "") {
                pcvm.showOther = true
                
                pcvm.showAllCategories()
            } else {
                pcvm.selectedCategory = nil
                
                pcvm.updateData()
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
