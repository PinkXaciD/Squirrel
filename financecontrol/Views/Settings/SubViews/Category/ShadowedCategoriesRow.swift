//
//  ShadowedCatedoryRow.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/10/18.
//

import SwiftUI

struct ShadowedCategoriesRow: View {
    
    @EnvironmentObject private var vm: CoreDataViewModel
    
    @State private var alertIsPresented: Bool = false
    
    let category: CategoryEntity
    
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
                        vm.deleteCategory(category)
                    }
                }
                
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You will not be able to undo this action.\nAll expenses in this category will be permanently deleted")
            }

    }
    
    private var categoryInfo: some View {
        HStack {
            Image(systemName: "circle.fill")
                .font(.title)
                .foregroundStyle(.tertiary)
            
            VStack(alignment: .leading) {
                Text(category.name ?? "Deleted")
                    .foregroundStyle(.primary)
                
                Text("Swipe left to restore, swipe right to delete")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
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
                vm.changeShadowStateOfCategory(category)
            }
        } label: {
            Label("Restore", systemImage: "arrow.uturn.backward")
        }
        .tint(Color.green)
    }
}
