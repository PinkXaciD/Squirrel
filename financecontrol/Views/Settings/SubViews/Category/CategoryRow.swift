//
//  CategoryRow.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/10/16.
//

import SwiftUI

struct CategoryRow: View {
    
    @EnvironmentObject private var cdm: CoreDataModel
    
    let category: CategoryEntity
    
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
            deleteButton
        }
        .contextMenu {
            favoriteButton
            
            deleteButton
        }
    }
    
    private var navLinkLabel: some View {
        let spendingsCount: Int = category.spendings?.count ?? 0
        
        return HStack {
            Image(systemName: category.isFavorite ? "star.circle.fill" : "circle.fill")
                .font(.title)
                .foregroundStyle(.tertiary)
            
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
        .foregroundStyle(Color.primary, Color.secondary, Color[category.color ?? "nil"])
        .padding(.vertical, 1) /// Strange behavior without padding
    }
    
    private var favoriteButton: some View {
        Button {
            withAnimation {
                cdm.changeFavoriteStateOfCategory(category)
            }
        } label: {
            Label(
                category.isFavorite ? "Remove from favorites" : "Add to favorites", 
                systemImage: category.isFavorite ? "star.slash.fill" : "star.fill"
            )
        }
        .tint(.yellow)
    }
    
    private var deleteButton: some View {
        Button(role: .destructive) {
            cdm.changeShadowStateOfCategory(category)
        } label: {
            Label("Archive", systemImage: "archivebox.fill")
        }
        .tint(.gray)
    }
}

//#Preview {
//    CategoryRow()
//}
