//
//  CategoryRow.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/10/16.
//

import SwiftUI
import Beige

struct CategoryRow: View {
//    @EnvironmentObject private var cdm: CoreDataModel
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    
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
                .labelStyle(.iconOnly)
        }
        .swipeActions(edge: .trailing) {
            getDeleteButton(isSwipeAction: true)
                .labelStyle(.iconOnly)
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
                .foregroundStyle(category.resolveColor(colorScheme: colorScheme, increaseContrast: colorSchemeContrast))
            
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
        .padding(.vertical, 1) /// Strange behavior without padding
    }
    
    private var favoriteButton: some View {
        Button {
            category.isFavorite.toggle()
            try? viewContext.save()
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
