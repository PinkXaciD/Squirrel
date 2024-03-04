//
//  ShadowedCategoriesView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/30.
//

import SwiftUI

struct ShadowedCategoriesView: View {
    @EnvironmentObject var cdm: CoreDataModel
    
    @State private var alertIsShowing: Bool = false
    
    var body: some View {
        if !cdm.shadowedCategories.isEmpty {
            List {
                Section {
                    ForEach(cdm.shadowedCategories) { category in
                        ShadowedCategoriesRow(category: category)
                    }
                } footer: {
                    Text("Swipe left to restore, swipe right to delete")
                }
            }
        } else {
            CustomContentUnavailableView(
                NSLocalizedString("No Archived Categories", comment: ""),
                imageName: "archivebox.fill",
                description: NSLocalizedString("You can archive categories in settings, they will be hidden from selection when you add new expenses, but all old expenses will be saved", comment: "")
            )
        }
    }
}

struct ShadowedCategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        ShadowedCategoriesView()
            .environmentObject(CoreDataModel())
    }
}
