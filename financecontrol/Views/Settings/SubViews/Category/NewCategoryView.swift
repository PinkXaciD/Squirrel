//
//  NewCategoryView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/19.
//

import SwiftUI

struct NewCategoryView: View {
    @EnvironmentObject private var vm: CoreDataViewModel
    
    @Binding var id: UUID
    let insert: Bool
    
    @State private var input: String = ""
    @State private var colorSelected: Color = Color.clear
    @State private var colorSelectedDescription: String = ""
    
    @FocusState private var isFocused: Bool
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        
        
        List {
            Section {
                TextField("Enter name", text: $input)
                    .focused($isFocused)
                    .onAppear(perform: fieldFocus)
            } header: {
                Text("name")
            }
            
            Section {
                CustomColorSelector(colorSelected: $colorSelected, colorSelectedDescription: $colorSelectedDescription)
                .padding(.vertical, 10)
                
            } header: {
                
                Text("color")
                
            }
            
            Button {
                if insert {
                    id = vm.addCategory(name: input, color: colorSelectedDescription)
                } else {
                    _ = vm.addCategory(name: input, color: colorSelectedDescription)
                }
                
                dismiss()
            } label: {
                Text("Save")
                    .fontWeight(.semibold)
            }
            .disabled(input == "" || colorSelectedDescription == "")
            .toolbar {
                keyboardToolbar
            }
        }
        .navigationTitle("New Category")
    }
    
    var keyboardToolbar: ToolbarItemGroup<some View> {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            
            Button(action: clearFocus) {
                Label("Hide keyboard", systemImage: "keyboard.chevron.compact.down")
            }
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
        
        NewCategoryView(id: $id, insert: false)
            .environmentObject(CoreDataViewModel())
    }
}
