//
//  ShadowedCategoriesView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/30.
//

import SwiftUI

struct ShadowedCategoriesView: View {
    @EnvironmentObject var vm: CoreDataViewModel
    
    @State private var alertIsShowing: Bool = false
    
    var body: some View {
        if !vm.shadowedCategories.isEmpty {
            List {
                ForEach(vm.shadowedCategories) { category in
                    ShadowedCategoriesRow(category: category)
                }
            }
            .navigationTitle("Archived categories")
            
        } else {
            Text("No archived categories")
                .font(.system(.title2, weight: .semibold))
                .navigationTitle("Archived categories")
        }
    }
}

struct ShadowedCategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        ShadowedCategoriesView()
            .environmentObject(CoreDataViewModel())
    }
}
