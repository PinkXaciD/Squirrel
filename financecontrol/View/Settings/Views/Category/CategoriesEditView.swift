//
//  CategoriesEditView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/27.
//

import SwiftUI

struct CategoriesEditView: View {
    @EnvironmentObject var cdm: CoreDataModel
    
    var body: some View {
        List {
            if !cdm.savedCategories.isEmpty {
                Section {
                    ForEach(cdm.savedCategories) { entity in
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
        .toolbar {
            ToolbarItem {
                shadowedCategoriesToolbarButton
            }

            ToolbarItem {
                addNewToolbarButton
            }
        }
        .animation(.default, value: cdm.savedCategories)
    }
    
    private var manageCategoriesSection: some View {
        Section {
            NavigationLink("Add new") {
                AddCategoryView(id: .constant(.init()), insert: false)
            }
            
            NavigationLink {
                ShadowedCategoriesView()
            } label: {
                HStack {
                    Text("Archived categories")
                    Spacer()
                    Text(cdm.shadowedCategories.count.formatted())
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private var addNewToolbarButton: some View {
        NavigationLink {
            AddCategoryView(id: .constant(.init()), insert: false)
        } label: {
            Label("Add new category", systemImage: "plus")
        }
    }
    
    private var shadowedCategoriesToolbarButton: some View {
        NavigationLink {
            ShadowedCategoriesView()
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
