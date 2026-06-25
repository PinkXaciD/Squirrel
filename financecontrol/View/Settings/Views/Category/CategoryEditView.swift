//
//  CategorySpendingsView.swift
//  Squirrel
//
//  Created by PinkXaciD on 2023/09/11.
//

import SwiftUI
import Beige

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
    @Environment(\.colorScheme)
    private var colorScheme
    
    let category: CategoryEntity
    @Binding
    var dismiss: Bool
    
    @EnvironmentObject
    private var cdm: CoreDataModel
    
    @State
    private var name: String
    @State
    private var oklch: OKLCH
    @State
    private var triedToSave: Bool = false
    
    @FocusState
    var nameIsFocused: Bool
        
    init(category: CategoryEntity, dismiss: Binding<Bool>) {
        self.category = category
        self.name = category.name ?? "Error"
        self._dismiss = dismiss
        self._oklch = .init(initialValue: .init(lightness: 0.7, chroma: CategoryColorValues.chroma, hue: Double(category.color ?? "") ?? 0))
    }
    
    private var tintColor: Color {
        switch colorScheme {
        case .dark:
            return oklch.shift(lightness: CategoryColorValues.darkModeLightness - 0.7).color
        default:
            return oklch.shift(lightness: CategoryColorValues.lightModeLightness - 0.7).color
        }
    }
    
    private var namePadding: CGFloat {
        if #available(iOS 26.0, *) {
            return 0
        }
        
        return 3
    }
    
    var body: some View {
        List {
            nameSection
            
            colorSection
            
            spendingsSection
        }
        .toolbar {
            trailingToolbar
        }
        .addKeyboardToolbar(showToolbar: nameIsFocused) {
            clearFocus()
        }
    }
    
    private var nameSection: some View {
        Section {
            TextField("Enter name", text: $name)
                .focused($nameIsFocused)
                .font(.largeTitle.bold())
                .foregroundColor(tintColor)
                .padding(.vertical, namePadding)
//                .minimumScaleFactor(0.6)
//                .scaledToFit()
        } header: {
            Text("Name")
        } footer: {
            if triedToSave && name.isEmpty {
                Text("Required")
                    .foregroundColor(.red)
            }
            
            if name.count >= 50 {
                Text("\(100 - name.count) characters left")
                    .foregroundColor(name.count > 100 ? .red : .secondary)
            }
        }
        .tint(tintColor)
        .accentColor(tintColor)
    }
    
    private var colorSection: some View {
        Section {
            CustomColorSelector(oklch: $oklch)
        } header: {
            Text("Color")
        } footer: {
            favoriteAndArchiveSection
                .listRowInsets(.init(top: 20, leading: 0, bottom: 15, trailing: 0))
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
    
    private var archiveSection: some View {
        Section {
            Button("Archive") {
                dismiss = true
                cdm.changeShadowStateOfCategory(category)
            }
        }
    }
    
    private var favoriteAndArchiveSection: some View {
        HStack {
            Button(category.isFavorite ? "Unfavorite" : "Favorite") {
                cdm.changeFavoriteStateOfCategory(category)
            }
            .animation(.default, value: category.isFavorite)
            
            Button("Archive") {
                dismiss = true
                cdm.changeShadowStateOfCategory(category)
            }
        }
        .buttonStyle(SpendingListRowButtonStyle())
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
    
    private var trailingToolbar: ToolbarItem<Void, some View> {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Save") {
                if name.isEmpty || name.count > 100 {
                    withAnimation {
                        triedToSave = true
                    }
                    
                    HapticManager.shared.notification(.warning)
                } else {
                    cdm.editCategory(category, name: name, color: /*colorSelectedDescription*/"\(oklch.h)")
                    dismiss.toggle()
                    HapticManager.shared.notification(.success)
                }
            }
            .font(.body.bold())
            .foregroundColor(name.isEmpty || name.count > 100 ? .secondary.opacity(0.7) : .accentColor)
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
