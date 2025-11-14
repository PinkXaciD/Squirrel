//
//  PieChartLegendRowView.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/02/09.
//

import SwiftUI

struct PieChartLegendRowView: View {
    @AppStorage(UDKey.defaultCurrency.rawValue)
    private var defaultCurrency: String = Locale.current.currencyCode ?? "USD"
    @EnvironmentObject
    private var cdm: CoreDataModel
    @EnvironmentObject
    private var pcvm: PieChartViewModel
    @EnvironmentObject
    private var fvm: FiltersViewModel
    
    let category: any SuitableForChart
    
    var body: some View {
        if #available(iOS 26.0, *) {
            newButton
        } else {
            oldButton
        }
    }
    
    var oldButton: some View {
        Button {
            buttonAction()
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
                
                Text(category.sum.formatted(.currency(code: defaultCurrency)))
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
        .hoverEffect()
    }
    
    @available(iOS 26.0, *)
    private var newButton: some View {
        Button {
            buttonAction()
        } label: {
            HStack {
                Text(category.name)
                    .font(.system(size: 14).bold())
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 6)
                    .foregroundColor(.white)
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color[category.color])
                    }
                
                Text(category.sum.formatted(.currency(code: defaultCurrency)))
                    .foregroundStyle(Color.primary)
            }
            .padding(.vertical, 3)
            .padding(.trailing, 12)
            .padding(.leading, 3)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.tint(Color[category.color].opacity(0.3)).interactive(), in: RoundedRectangle(cornerRadius: 19))
        .tint(Color[category.color])
        .hoverEffect()
    }
    
    private func buttonAction() {
        if !pcvm.showOther, category.isOther {
            DispatchQueue.main.async {
                pcvm.showOther = true
            }
        } else if !category.isPlace, let trueCategory = category as? ChartCategory {
            if pcvm.selectedCategory == nil {
                pcvm.selectedCategory = trueCategory
            }
        } else {
            pcvm.selectedCategory = nil
        }
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
