//
//  CategorySelector.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/13.
//

import SwiftUI

struct CategorySelector: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var cdm: CoreDataModel
    @Binding var category: UUID
    
    @State private var editCategories: Bool = false
    @State private var showOther: Bool = false
    
    var body: some View {
        
        let favorites = cdm.savedCategories.filter { $0.isFavorite }
        
        Menu {
            if favorites.isEmpty {
                CategoryPicker(selectedCategory: $category, onlyFavorites: false)
                
                addNewButton
                
            } else if cdm.savedCategories.isEmpty {
                addNewButton
            } else {
                CategoryPicker(selectedCategory: $category, onlyFavorites: true)
                
//                Menu("Other") {
//                    CategoryPicker(selectedCategory: $category, onlyFavorites: false)
//                }
                
                Section {
                    showOtherButton
                }
                
                Section {
                    addNewButton
                }
            }
        } label: {
            Spacer()
            Text(cdm.findCategory(category)?.name ?? "Select Category")
        }
        .background {
            Group {
                NavigationLink(isActive: $editCategories) {
                    AddCategoryView(id: $category, insert: true)
                } label: {
                    EmptyView()
                }
                
                NavigationLink(isActive: $showOther) {
                    OtherCategorySelector(category: $category)
                } label: {
                    EmptyView()
                }

            }
            .disabled(true)
            .opacity(0)
        }
    }
    
    private var showOtherButton: some View {
        Button {
            showOther.toggle()
        } label: {
            HStack {
                Text("Other")
                Spacer()
                Image(systemName: "chevron.forward")
            }
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
    @EnvironmentObject private var cdm: CoreDataModel
    
    @Binding var selectedCategory: UUID
    let onlyFavorites: Bool
    
    var body: some View {
        let categories = onlyFavorites ? cdm.savedCategories.filter({ $0.isFavorite }) : cdm.savedCategories
        
        Picker("All categories", selection: $selectedCategory) {
            ForEach(categories) { category in
                if let name = category.name, let tag = category.id {
                    Text(name)
                        .tag(tag)
                }
            }
        }
        .pickerStyle(.inline)
        .labelsHidden()
    }
}

fileprivate struct OtherCategorySelector: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var cdm: CoreDataModel
    @Binding var category: UUID
    
    @State private var search: String = ""
    
    var body: some View {
        Group {
            let searchResult = searchFunc(search)
            if searchResult.isEmpty {
                CustomContentUnavailableView.search(search.trimmingCharacters(in: .whitespacesAndNewlines))
            } else {
                List {
                    ForEach(searchFunc(search)) { category in
                        makeButton(category)
                    }
                    
                    addNewSection
                }
            }
        }
        .searchable(text: $search, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search by name")
        .navigationTitle("Other")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var addNewSection: some View {
        Section {
            NavigationLink {
                AddCategoryView(id: $category, insert: true)
            } label: {
                Text("Add new")
            }

        }
    }
    
    private func searchFunc(_ searchString: String) -> [CategoryEntity] {
        let trimmedSearch = searchString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedSearch.isEmpty {
            return cdm.savedCategories
        }
        
        return cdm.savedCategories.filter { category in
            category.name?.localizedCaseInsensitiveContains(trimmedSearch) ?? false
        }
    }
    
    private func makeButton(_ category: CategoryEntity) -> some View {
        Button {
            self.category = category.id ?? .init()
            dismiss()
        } label: {
            HStack {
                Image(systemName: "circle.fill")
                    .font(.title)
                    .foregroundColor(Color[category.color ?? "nil"])
                
                Text(category.name ?? "Error")
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "checkmark")
                    .font(.body.bold())
                    .opacity(self.category == category.id ? 1 : 0)
            }
        }
    }
}

struct CategorySelector_Previews: PreviewProvider {
    static var previews: some View {
        @State var category: UUID = UUID()
        CategorySelector(category: $category)
            .environmentObject(CoreDataModel())
    }
}
