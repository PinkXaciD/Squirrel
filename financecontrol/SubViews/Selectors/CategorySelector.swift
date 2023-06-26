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
        Menu {
            Picker("Category selection", selection: $category) {
                ForEach(vm.savedCategories) { category in
                    Text(category.name ?? "Error").tag(category.id ?? UUID())
                }
            }
            .pickerStyle(.inline)

            Button {
                editCategories.toggle()
            } label: {
                HStack {
                    Text("Add new")
                    Spacer()
                    Image(systemName: "chevron.forward")
                }
            }
        } label: {
            Spacer()
            Text(vm.findCategory(category)?.name ?? "Select Category")
//            Text(category.uuidString)
        }
        .background {
            NavigationLink(isActive: $editCategories) {
                NewCategoryView(id: $category, insert: true)
            } label: {
                EmptyView()
            }
            .disabled(true)
            .opacity(0)
        }
    }
}

struct CategorySelector_Previews: PreviewProvider {
    static var previews: some View {
        @State var category: UUID = UUID()
        CategorySelector(category: $category)
            .environmentObject(CoreDataViewModel())
    }
}
