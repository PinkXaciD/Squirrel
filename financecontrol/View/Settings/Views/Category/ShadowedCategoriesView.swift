//
//  ShadowedCategoriesView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/30.
//

import SwiftUI

struct ShadowedCategoriesView: View {
    @EnvironmentObject var cdm: CoreDataModel
    
    var body: some View {
        if !cdm.shadowedCategories.isEmpty {
            List {
                Section {
                    ForEach(cdm.shadowedCategories) { category in
                        ShadowedCategoriesRow(category: category, safeCategory: category.safeObject())
                    }
                } footer: {
                    Text("Swipe from left to restore, swipe from right to delete")
                }
            }
            .navigationTitle("Archived categories")
        } else {
            CustomContentUnavailableView(
                "No Archived Categories",
                imageName: "archivebox.fill",
                description: "You can archive categories in settings, they will be hidden from selection when you add new expenses, but all old expenses will be saved."
            )
            .navigationTitle("Archived categories")
        }
    }
}

struct ShadowedCategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        ShadowedCategoriesView()
            .environmentObject(CoreDataModel())
    }
}
