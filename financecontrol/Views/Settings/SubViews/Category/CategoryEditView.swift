//
//  CategorySpendingsView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/09/11.
//

import SwiftUI

struct CategoryEditView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var toDismiss: Bool = false
    
    let category: CategoryEntity
    
    var body: some View {
        
        CategoryEditSubView(category: category, dismiss: $toDismiss)
            .onChange(of: toDismiss) { _ in
                dismiss()
            }
            .navigationTitle("Edit")
    }
}

struct CategoryEditSubView: View {
        
    let category: CategoryEntity
    @Binding var dismiss: Bool
    
    @EnvironmentObject private var vm: CoreDataViewModel
    
    @State private var name: String
    @State private var colorSelected: Color
    @State private var colorSelectedDescription: String
        
    init(category: CategoryEntity, dismiss: Binding<Bool>) {
        self.category = category
        self.name = category.name ?? "Error"
        self.colorSelectedDescription = category.color ?? "Error"
        self.colorSelected = Color[category.color ?? "nil"]
        self._dismiss = dismiss
    }
    
    var body: some View {
                
        Form {
            
            Section {
                
                TextField("Enter name", text: $name)
            }
            
            Section {
                
                CustomColorSelector(colorSelected: $colorSelected, colorSelectedDescription: $colorSelectedDescription)
            }
            
            Section {
                
                Button("Done") {
                    vm.editCategory(category, name: name, color: colorSelectedDescription)
                    dismiss.toggle()
                }
                .bold()
                .disabled(name.isEmpty || colorSelectedDescription.isEmpty)
            }
        }
    }
}
