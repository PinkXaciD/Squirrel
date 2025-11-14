//
//  ShadowedCategoriesView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/30.
//

import SwiftUI

struct ShadowedCategoriesView: View {
//    @EnvironmentObject var cdm: CoreDataModel
    
    let categories: FetchedResults<CategoryEntity>
    
    var body: some View {
        Group {
            List {
                if !categories.isEmpty {
                    Section {
                        ForEach(categories) { category in
                            ShadowedCategoriesRow(category: category, safeCategory: category.safeObject())
                        }
                    } footer: {
                        Text("Swipe from left to restore, swipe from right to delete")
                    }
                }
            }
            .overlay {
                if categories.isEmpty {
                    ZStack {
                        Color(uiColor: .systemGroupedBackground)
                        
                        CustomContentUnavailableView(
                            "No Archived Categories",
                            imageName: "archivebox.fill",
                            description: "You can archive categories in settings, they will be hidden from selection when you add new expenses, but all old expenses will be saved."
                        )
                    }
                    .ignoresSafeArea()
                }
            }
            .navigationTitle("Archived Categories")
        }
        .animation(.default, value: categories.count)
    }
}

struct ShadowedCategoriesView_Previews: PreviewProvider {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], predicate: NSPredicate(format: "isShadowed == true"), animation: .default)
    static private var categories: FetchedResults<CategoryEntity>
    
    static var previews: some View {
        ShadowedCategoriesView(categories: categories)
            .environmentObject(CoreDataModel())
    }
}
