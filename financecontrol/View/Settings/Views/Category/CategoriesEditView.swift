//
//  CategoriesEditView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/27.
//

import SwiftUI

struct CategoriesEditView: View {
    @EnvironmentObject var cdm: CoreDataModel
    
    @State private var id: UUID = .init()
    
    var body: some View {
        List {
            ForEach(cdm.savedCategories) { entity in
                CategoryRow(category: entity)
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
    }
    
    private var manageCategoriesSection: some View {
        Section {
            NavigationLink("Add new") {
                AddCategoryView(id: $id, insert: false)
            }
            
            NavigationLink {
                ShadowedCategoriesView()
            } label: {
                HStack {
                    Text("Archived categories")
                    Spacer()
                    Text("\(cdm.shadowedCategories.count)")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private var addNewToolbarButton: some View {
        NavigationLink {
            AddCategoryView(id: $id, insert: false)
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
