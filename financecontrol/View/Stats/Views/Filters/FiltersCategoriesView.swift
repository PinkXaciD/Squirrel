//
//  FiltersCategoriesView.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/06/12.
//

import SwiftUI

struct FiltersCategoriesView: View {
    @Environment(\.dismiss)
    private var dismiss
    
    @Binding
    var categories: [UUID]
    @Binding
    var applyFilters: Bool
    
//    let listData: [CategoryEntity]
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)])
    private var fetchedCategories: FetchedResults<CategoryEntity>
    
    var body: some View {
        List {
            Section {
                ForEach(fetchedCategories) { category in
                    Button {
                        categoryButtonAction(category)
                    } label: {
                        categoryRowLabel(category)
                    }
                }
            }
            
            if !fetchedCategories.isEmpty {
                Section {
                    Button("Select All") {
                        categories = fetchedCategories.map { $0.id ?? .init() }
                    }
                    .disabled(categories.count == fetchedCategories.count)
                    
                    Button("Clear Selection", role: .destructive) {
                        categories.removeAll()
                    }
                    .disabled(categories.isEmpty)
                    .animation(.default.speed(2), value: categories)
                }
            }
        }
        .navigationTitle("Categories")
        .toolbar {
            trailingToolbar
        }
        .overlay {
            if fetchedCategories.isEmpty {
                CustomContentUnavailableView("No Categories", imageName: "list.bullet", description: "You can add categories in settings.")
            }
        }
    }
    
    private var trailingToolbar: ToolbarItem<Void, some View> {
        ToolbarItem {
            Button("Done") {
                dismiss()
            }
            .font(.body.bold())
        }
    }
    
    private func categoryButtonAction(_ category: CategoryEntity) {
        guard let id = category.id else {
            return
        }
        
        if categories.contains(id) {
            let index: Int = categories.firstIndex(of: id) ?? 0
            categories.remove(at: index)
        } else {
            categories.append(id)
        }
    }
    
    private func categoryRowLabel(_ category: CategoryEntity) -> some View {
        return HStack {
            Image(systemName: "circle.fill")
                .foregroundColor(Color[category.color ?? ""])
                .font(.title)
                
            Text(category.name ?? "Error")
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "checkmark")
                .font(.body.bold())
                .opacity(categories.contains(category.id ?? .init()) ? 1 : 0)
                .animation(.default.speed(3), value: categories)
        }
    }
}
