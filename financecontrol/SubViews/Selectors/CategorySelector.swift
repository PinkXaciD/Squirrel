//
//  CategorySelector.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/13.
//

import SwiftUI

struct CategorySelector: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: CoreDataViewModel
    @Binding var category: UUID
    
    @State var editCategories: Bool = false
    
    var body: some View {
        
        let favorites = vm.savedCategories.filter({ $0.isFavorite })
        
        Menu {
            if favorites.isEmpty {
                CategoryPicker(selectedCategory: $category, onlyFavorites: false)
                
                addNewButton
                
            } else if vm.savedCategories.isEmpty {
                addNewButton
            } else {
                CategoryPicker(selectedCategory: $category, onlyFavorites: true)
                
                Menu("Other") {
                    CategoryPicker(selectedCategory: $category, onlyFavorites: false)
                }
                
                Section {
                    addNewButton
                }
            }
        } label: {
            Spacer()
            Text(vm.findCategory(category)?.name ?? "Select Category")
//            Text(category.uuidString)
        }
        .background {
            NavigationLink(isActive: $editCategories) {
                AddCategoryView(id: $category, insert: true)
            } label: {
                EmptyView()
            }
            .disabled(true)
            .opacity(0)
        }
    }
    
    private var addNewButton: some View {
        Button {
            editCategories.toggle()
        } label: {
            HStack {
                Text("Add new")
                Spacer()
                Image(systemName: "chevron.forward")
            }
        }
    }
}

struct CategoryPicker: View {
    
    @EnvironmentObject private var vm: CoreDataViewModel
    
    @Binding var selectedCategory: UUID
    let onlyFavorites: Bool
    
    var body: some View {
        let categories = onlyFavorites ? vm.savedCategories.filter({ $0.isFavorite }) : vm.savedCategories
        
        Picker("All categories", selection: $selectedCategory) {
            ForEach(categories) { category in
                if let name = category.name, let tag = category.id {
                    Text(name).tag(tag)
                }
            }
        }
        .pickerStyle(.inline)
        .labelsHidden()
    }
}

struct CategorySelector_Previews: PreviewProvider {
    static var previews: some View {
        @State var category: UUID = UUID()
        CategorySelector(category: $category)
            .environmentObject(CoreDataViewModel())
    }
}
