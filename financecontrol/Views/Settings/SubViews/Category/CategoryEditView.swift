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
    
    @EnvironmentObject private var cdm: CoreDataModel
    
    @State private var name: String
    @State private var colorSelected: Color
    @State private var colorSelectedDescription: String
    
    @FocusState var nameIsFocused: Bool
        
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
                    .focused($nameIsFocused)
                    .onAppear(perform: nameFocus)
            }
            .toolbar {
                keyboardToolbar
            }
            
            Section {
                CustomColorSelector(colorSelected: $colorSelected, colorSelectedDescription: $colorSelectedDescription)
            }
            
            Section {
                Button("Save") {
                    cdm.editCategory(category, name: name, color: colorSelectedDescription)
                    dismiss.toggle()
                }
                .font(.body.bold())
                .disabled(name.isEmpty || colorSelectedDescription.isEmpty)
            }
            
            Section {
                if let spendings = category.spendings?.allObjects as? [SpendingEntity], !spendings.isEmpty {
                    ForEach(spendings.sorted { $0.wrappedDate > $1.wrappedDate }) { spending in
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                if let place = spending.place, !place.isEmpty {
                                    Text(spending.categoryName)
                                        .font(.caption)
                                        .foregroundColor(Color.secondary)
                                    
                                    Text(place)
                                        .foregroundColor(.primary)
                                } else {
                                    Text(spending.categoryName)
                                        .foregroundColor(.primary)
                                }
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 5) {
                                Text(dateFormatter.string(from: spending.wrappedDate))
                                    .font(.caption)
                                    .foregroundColor(Color.secondary)
                                
                                Text("\((spending.amountWithReturns * -1.0).formatted(.currency(code: spending.wrappedCurrency)))")
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                } else {
                    Text("No expenses")
                }
            } header: {
                Text("Expenses")
            }
        }
        .scrollDismissesKeyboard(.immediately)
    }
    
    private var keyboardToolbar: ToolbarItem<Void, some View> {
        ToolbarItem(placement: .keyboard) {
            HStack {
                Spacer()
                
                Button {
                    nameIsFocused = false
                } label: {
                    Label("Hide keyboard", systemImage: "keyboard.chevron.compact.down")
                }
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter: DateFormatter = .init()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    private func nameFocus() {
        nameIsFocused = true
    }
}
