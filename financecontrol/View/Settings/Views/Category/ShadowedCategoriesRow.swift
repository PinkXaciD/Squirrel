//
//  ShadowedCatedoryRow.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/10/18.
//

import SwiftUI

struct ShadowedCategoriesRow: View {
    
//    @EnvironmentObject private var cdm: CoreDataModel
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var alertIsPresented: Bool = false
    
    let category: CategoryEntity
    let safeCategory: TSCategoryEntity
    
    var body: some View {
        categoryInfo
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                getDeleteButton(isSwipeAction: true)
                    .labelStyle(.iconOnly)
            }
            .swipeActions(edge: .leading) {
                getRestoreButton(isSwipeAction: true)
                    .labelStyle(.iconOnly)
            }
            .contextMenu {
                getRestoreButton(isSwipeAction: false)
                
                getDeleteButton(isSwipeAction: false)
            }
            .alert("Delete this category?", isPresented: $alertIsPresented) {
                Button("Delete", role: .destructive) {
                    withAnimation {
                        viewContext.delete(category)
                        try? viewContext.save()
//                        cdm.deleteCategory(category)
                    }
                }
                
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You can't undo this action.\nAll expenses from this category will be deleted")
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
    
    private func getDeleteButton(isSwipeAction: Bool) -> some View {
        Button(role: isSwipeAction ? nil : .destructive) {
            alertIsPresented.toggle()
        } label: {
            Label("Delete", systemImage: "trash.fill")
        }
        .tint(Color.red)
    }
    
    private func getRestoreButton(isSwipeAction: Bool) -> some View {
        Button(role: isSwipeAction ? .destructive : nil) {
            withAnimation {
                category.isShadowed.toggle()
                try? viewContext.save()
//                cdm.changeShadowStateOfCategory(category)
            }
        } label: {
            Label("Restore", systemImage: "arrow.uturn.backward")
        }
        .tint(Color.green)
    }
}
