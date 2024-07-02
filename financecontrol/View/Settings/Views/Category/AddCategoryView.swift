//
//  AddCategoryView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/19.
//

import SwiftUI

struct AddCategoryView: View {
    @EnvironmentObject private var cdm: CoreDataModel
    
    @Binding var id: UUID
    let insert: Bool
    
    @State private var name: String = ""
    @State private var colorSelectedDescription: String = ""
    @State private var triedToSave: Bool = false
    
    @FocusState private var isFocused: Bool
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            nameSection
            
            colorSection
        }
        .navigationTitle("New Category")
        .toolbar {
            keyboardToolbar
            
            trailingToolbar
        }
    }
    
    private var nameSection: some View {
        Section {
            TextField("Enter name", text: $name)
                .focused($isFocused)
                .onAppear(perform: fieldFocus)
        } footer: {
            if triedToSave && name.isEmpty {
                Text("Required")
                    .foregroundColor(.red)
            }
        }
    }
    
    private var colorSection: some View {
        Section {
            CustomColorSelector(colorSelectedDescription: $colorSelectedDescription)
                .padding(.vertical, 10)
        } footer: {
            if triedToSave && colorSelectedDescription.isEmpty {
                Text("Required")
                    .foregroundColor(.red)
            }
        }
    }
    
    private var keyboardToolbar: ToolbarItemGroup<some View> {
        hideKeyboardToolbar {
            clearFocus()
        }
    }
    
    private var trailingToolbar: ToolbarItem<Void, some View> {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Save") {
                if name.isEmpty || colorSelectedDescription.isEmpty {
                    triedToSave = true
                    HapticManager.shared.notification(.warning)
                } else {
                    if insert {
                        id = cdm.addCategory(name: name, color: colorSelectedDescription)
                    } else {
                        _ = cdm.addCategory(name: name, color: colorSelectedDescription)
                    }
                    
                    HapticManager.shared.notification(.success)
                    dismiss()
                }
            }
            .font(.body.bold())
            .foregroundColor(name.isEmpty || colorSelectedDescription.isEmpty ? .secondary.opacity(0.7) : .accentColor)
        }
    }
    
    func clearFocus() {
        isFocused = false
    }
    
    func fieldFocus() {
        isFocused = true
    }
}

struct NewCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        @State var id = UUID()
        
        AddCategoryView(id: $id, insert: false)
            .environmentObject(CoreDataModel())
    }
}
