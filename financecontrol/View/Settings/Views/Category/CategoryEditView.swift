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
    @State private var triedToSave: Bool = false
    
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
            nameSection
            
            colorSection
            
            favoriteSection
            
            spendingsSection
        }
        .toolbar {
            keyboardToolbar
            
            trailingToolbar
        }
    }
    
    private var nameSection: some View {
        Section {
            TextField("Enter name", text: $name)
                .focused($nameIsFocused)
        } footer: {
            if triedToSave && name.isEmpty {
                Text("Required")
                    .foregroundColor(.red)
            }
        }
    }
    
    private var colorSection: some View {
        Section {
            CustomColorSelector(colorSelected: $colorSelected, colorSelectedDescription: $colorSelectedDescription)
        } footer: {
            if triedToSave && colorSelectedDescription.isEmpty {
                Text("Required")
                    .foregroundColor(.red)
            }
        }
    }
    
    private var favoriteSection: some View {
        Section {
            Button(category.isFavorite ? "Remove from favorites" : "Add to favorites") {
                withAnimation {
                    cdm.changeFavoriteStateOfCategory(category)
                }
            }
        }
    }
    
    private var spendingsSection: some View {
        Section {
            if let spendings = category.spendings?.allObjects as? [SpendingEntity], !spendings.isEmpty {
                let sortedSpendings: [SpendingEntity] = spendings.sorted { first, second in
                    return first.wrappedDate > second.wrappedDate
                }
                
                ForEach(sortedSpendings) { spending in
                    spendingRow(spending)
                }
            } else {
                Text("No expenses")
            }
        } header: {
            Text("Expenses")
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
                    withAnimation {
                        triedToSave = true
                    }
                    HapticManager.shared.notification(.warning)
                } else {
                    cdm.editCategory(category, name: name, color: colorSelectedDescription)
                    dismiss.toggle()
                    HapticManager.shared.notification(.success)
                }
            }
            .font(.body.bold())
            .foregroundColor(name.isEmpty || colorSelectedDescription.isEmpty ? .secondary.opacity(0.7) : .accentColor)
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter: DateFormatter = .init()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    private func clearFocus() {
        nameIsFocused = false
    }
    
    private func spendingRow(_ spending: SpendingEntity) -> some View {
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
        .normalizePadding()
    }
}
