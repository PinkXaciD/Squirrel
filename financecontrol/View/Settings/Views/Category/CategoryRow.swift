//
//  CategoryRow.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/10/16.
//

import SwiftUI

struct CategoryRow: View {
    
//    @EnvironmentObject private var cdm: CoreDataModel
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject
    var category: CategoryEntity
    
    var body: some View {
        
        NavigationLink {
            CategoryEditView(category: category)
        } label: {
            navLinkLabel
        }
        .swipeActions(edge: .leading) {
            favoriteButton
        }
        .swipeActions(edge: .trailing) {
            getDeleteButton(isSwipeAction: true)
        }
        .contextMenu {
            favoriteButton
            
            getDeleteButton(isSwipeAction: false)
        }
        .normalizePadding()
        .animation(.default, value: category.isFavorite)
    }
    
    private var navLinkLabel: some View {
        let spendingsCount: Int = category.spendings?.count ?? 0
        
        return HStack {
            Image(systemName: category.isFavorite ? "star.circle.fill" : "circle.fill")
                .font(.title)
                .foregroundStyle(Color[category.color ?? "nil"])
            
            VStack(alignment: .leading) {
                Text(category.name ?? "Error")
                    .foregroundStyle(.primary)
                
                Text("\(spendingsCount) expenses")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text("Edit")
                .foregroundStyle(.secondary)
        }
//        .foregroundStyle(Color.primary, Color.secondary, Color[category.color ?? "nil"])
        .padding(.vertical, 1) /// Strange behavior without padding
    }
    
    private var favoriteButton: some View {
        Button {
//            withAnimation {
                category.isFavorite.toggle()
                try? viewContext.save()
//                cdm.changeFavoriteStateOfCategory(category)
//            }
        } label: {
            Label(
                category.isFavorite ? "Remove from favorites" : "Add to favorites", 
                systemImage: category.isFavorite ? "star.slash.fill" : "star.fill"
            )
        }
        .tint(.yellow)
    }
    
    private func getDeleteButton(isSwipeAction: Bool) -> some View {
        Button(role: isSwipeAction ? .destructive : nil) {
            withAnimation {
                category.isShadowed.toggle()
                try? viewContext.save()
//                cdm.changeShadowStateOfCategory(category)
            }
        } label: {
            Label("Archive", systemImage: "archivebox.fill")
        }
        .tint(.gray)
    }
}

//#Preview {
//    CategoryRow()
//}
