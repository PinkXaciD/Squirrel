//
//  CategoriesEditView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/27.
//

import SwiftUI

struct CategoriesEditView: View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], predicate: NSPredicate(format: "isShadowed == false"), animation: .default)
    private var categories: FetchedResults<CategoryEntity>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], predicate: NSPredicate(format: "isShadowed == true"), animation: .default)
    private var shadowedCategories: FetchedResults<CategoryEntity>
    
    var body: some View {
        if #available(iOS 26.0, *) {
            content
                .toolbar {
                    ToolbarItem {
                        shadowedCategoriesToolbarButton
                    }
                    
                    ToolbarSpacer(.fixed)

                    ToolbarItem {
                        addNewToolbarButton
                    }
                }
        } else {
            content
                .toolbar {
                    ToolbarItem {
                        shadowedCategoriesToolbarButton
                    }

                    ToolbarItem {
                        addNewToolbarButton
                    }
                }
        }
    }
    
    private var content: some View {
        List {
            if !categories.isEmpty {
                Section {
                    ForEach(categories) { entity in
                        CategoryRow(category: entity)
                    }
                }
            } else {
                CustomContentUnavailableView(
                    "No Categories",
                    imageName: "list.bullet",
                    description: "You can add categories below."
                )
                .listRowInsets(.init(top: 20, leading: 0, bottom: 20, trailing: 0))
                .frame(maxWidth: .infinity)
                .listRowBackground(EmptyView())
            }
            
            manageCategoriesSection
        }
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var manageCategoriesSection: some View {
        Section {
            NavigationLink("Add New") {
                AddCategoryView(selectedCategory: .constant(.init()), insert: false)
            }
            
            NavigationLink {
                ShadowedCategoriesView(categories: shadowedCategories)
            } label: {
                HStack {
                    Text("Archived Categories")
                    Spacer()
                    Text(shadowedCategories.count.formatted())
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private var addNewToolbarButton: some View {
        NavigationLink {
            AddCategoryView(selectedCategory: .constant(.init()), insert: false)
        } label: {
            Label("Add new category", systemImage: "plus")
        }
    }
    
    private var shadowedCategoriesToolbarButton: some View {
        NavigationLink {
            ShadowedCategoriesView(categories: shadowedCategories)
        } label: {
            Label("Archived categories", systemImage: "archivebox")
        }
    }
}

struct CategoriesEditView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesEditView()
            .environmentObject(CoreDataModel())
    }
}
