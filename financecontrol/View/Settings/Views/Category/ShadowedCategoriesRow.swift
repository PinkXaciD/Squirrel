//
//  ShadowedCatedoryRow.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/10/18.
//

import SwiftUI

struct ShadowedCategoriesRow: View {
    
    @EnvironmentObject private var cdm: CoreDataModel
    
    @State private var alertIsPresented: Bool = false
    
    let category: CategoryEntity
    let safeCategory: TSCategoryEntity
    
    var body: some View {
        categoryInfo
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                deleteButton
            }
            .swipeActions(edge: .leading) {
                restoreButton
            }
            .contextMenu {
                restoreButton
                
                deleteButton
            }
            .alert("Delete this category?", isPresented: $alertIsPresented) {
                Button("Delete", role: .destructive) {
                    withAnimation {
                        cdm.deleteCategory(category)
                    }
                }
                
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You will not be able to undo this action.\nAll expenses in this category will be permanently deleted")
            }
            .normalizePadding()
    }
    
    private var categoryInfo: some View {
        HStack {
            Image(systemName: "circle.fill")
                .font(.title)
                .foregroundStyle(.tertiary)
            
            VStack(alignment: .leading) {
                Text(safeCategory.name ?? "Error")
                    .foregroundStyle(.primary)
            }
        }
        .padding(.vertical, 1) /// Strange behavior without padding
        .foregroundStyle(Color.primary, Color.secondary, Color[category.color ?? "nil"])
    }
    
    private var deleteButton: some View {
        Button {
            alertIsPresented.toggle()
        } label: {
            Label("Delete", systemImage: "trash.fill")
        }
        .tint(Color.red)
    }
    
    private var restoreButton: some View {
        Button {
            withAnimation {
                cdm.changeShadowStateOfCategory(category)
            }
        } label: {
            Label("Restore", systemImage: "arrow.uturn.backward")
        }
        .tint(Color.green)
    }
    
    init(category: CategoryEntity) {
        self.category = category
        self.safeCategory = category.safeObject()
    }
}
