//
//  CategoriesEditView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/27.
//

import SwiftUI

struct CategoriesEditView: View {
    @EnvironmentObject var vm: CoreDataViewModel
    
    @State private var id: UUID = UUID()
    
    var body: some View {
        List {
            ForEach(vm.savedCategories) { entity in
                
                let spendingsCount = spendingsCount(entity.spendings?.count ?? 0)
                
                NavigationLink {
                    
                    CategoryEditView(category: entity)
                    
                } label: {
                    HStack {
                        
                        Image(systemName: "circle.fill")
                            .foregroundColor(Color[entity.color ?? ""])
                        
                        Text(entity.name ?? "Error")
                        
                        Spacer()
                        
                        Text(spendingsCount)
                            .foregroundColor(Color.secondary)
                    }
                }
                .swipeActions(edge: .trailing) {
                    
                    Button(role: .destructive) {
                        vm.changeShadowStateOfCategory(entity)
                    } label: {
                        Label("Delete", systemImage: "trash.fill")
                    }
                    .tint(Color.red)
                }
                .contextMenu {
                    Button(role: .destructive) {
                        vm.changeShadowStateOfCategory(entity)
                    } label: {
                        Text("Delete")
                    }
                }
            }
            
            Section {
                NavigationLink {
                    
                    NewCategoryView(id: $id, insert: false)
                    
                } label: {
                    
                    Text("Add New")
                    
                }
                
                NavigationLink {
                    
                    ShadowedCategoriesView()
                    
                } label: {
                    
                    Text("Deleted categories")
                    
                }
            }
        }
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            
            ToolbarItem {
                NavigationLink {
                    
                    NewCategoryView(id: $id, insert: false)
                    
                } label: {
                    
                    Label("Add new category", systemImage: "plus")
                    
                }
            }
        }
    }
    
    private func spendingsCount(_ spendingsCount: Int) -> String {
        
        if spendingsCount == 1 {
            return "1 spending"
        } else if spendingsCount > 1 {
            return "\(spendingsCount) spendings"
        } else {
            return "No spendings"
        }
    }
}

struct CategoriesEditView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesEditView()
    }
}
