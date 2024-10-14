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
    @Binding var selectedCategory: CategoryEntity?
    
    @State private var editCategories: Bool = false
    @State private var showOther: Bool = false
    
    var body: some View {
        
        let favorites = cdm.savedCategories.filter { $0.isFavorite }
        
        Menu {
            if favorites.isEmpty {
                if #available(iOS 16.0, *) { // This type of styling is supported from iOS 16
                    Button {} label: {
                        Text("Your favorite categories will be shown here")
                        
                        Text("You can add category to favorites from settings.")
                    }
                } else {
                    Text("No favorite categories. You can add them from settings.")
                }
            } else {
                Picker("Favorite categories", selection: $selectedCategory) {
                    ForEach(favorites) { category in
                        Text(category.name ?? "Error")
                            .tag(category)
                    }
                }
            }
                
            if !cdm.savedCategories.isEmpty {
                Divider()
                
                showOtherButton
            }
            
            Divider()
            
            addNewButton
        } label: {
            Spacer()
            
            Text(selectedCategory?.name ?? "Select Category")
        }
        .background {
            Group {
                NavigationLink(isActive: $editCategories) {
                    AddCategoryView(selectedCategory: $selectedCategory, insert: true)
                } label: {
                    EmptyView()
                }
                
                NavigationLink(isActive: $showOther) {
                    OtherCategorySelector(selectedCategory: $selectedCategory)
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

fileprivate struct OtherCategorySelector: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var cdm: CoreDataModel
    @Binding var selectedCategory: CategoryEntity?
    
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
                AddCategoryView(selectedCategory: $selectedCategory, insert: true)
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
            self.selectedCategory = category
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
                    .opacity(self.selectedCategory?.id == category.id ? 1 : 0)
            }
        }
    }
}

//struct CategorySelector_Previews: PreviewProvider {
//    static var previews: some View {
//        @State var category: UUID = UUID()
//        CategorySelector(selectedCategory: $category)
//            .environmentObject(CoreDataModel())
//    }
//}
