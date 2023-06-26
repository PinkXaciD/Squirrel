//
//  SpendingEditView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/31.
//

import SwiftUI

struct SpendingEditView: View {
    @EnvironmentObject private var vm: CoreDataViewModel
    @EnvironmentObject private var rvm: RatesViewModel
    
    @Binding var entity: SpendingEntity
    @State var update: Bool
    var focus: String
    @Binding var edit: Bool
    
    let utils = InputUtils()
    @Environment(\.dismiss) private var dismiss
    
    @State private var newAmount: String = ""
    @State private var newCurrency: String = ""
    @State private var newPlace: String = ""
    @State private var newCategory: String = ""
    @State private var newCategoryId: UUID = UUID()
    @State private var newDate: Date = Date.now
    @State private var newComment: String = ""
    
    @State private var alertIsPresented: Bool = false
    
    enum Field {
        case amount
        case comment
    }
    
    @FocusState var focusedField: Field?
    
    @FocusState var placeIsFocused: Bool
    
    var body: some View {
        List {
            Section(header: Text("amount")) {
                TextField(newAmount, text: $newAmount)
                    .padding(.vertical, 10)
                    .amountStyle()
                    .numbersOnly($newAmount)
                    .focused($focusedField, equals: .amount)
                    .onAppear {
                        focusedField = .amount
                    }
                
                HStack {
                    Text("Currency")
                    
                    CurrencySelector(currency: $newCurrency, favorites: true)
                }
            }
            
            Section(header: Text("info")) {
                HStack {
                    Text("Category")
                    
                    CategorySelector(category: $newCategoryId)
                }
                
                DatePicker("Date", selection: $newDate, in: Date.distantPast...Date.now)
                    .datePickerStyle(.compact)
            }
            
            Section(header: Text("place and comment")) {
                NavigationLink {
                    EditPlaceView(newPlace: $newPlace)
                } label: {
                    HStack {
                        Text("Place")
                        Spacer()
                        if entity.place != "" {
                            Text(entity.place ?? "No place")
                                .foregroundColor(Color.secondary)
                        } else {
                            Text("No place provided")
                                .foregroundColor(Color.secondary)
                        }
                    }
                }
                
                if #available(iOS 16.0, *) {
                    TextField("Comment", text: $newComment, axis: .vertical)
                        .focused($focusedField, equals: .comment)
                } else {
                    TextEditor(text: $newComment)
                        .onTapGesture(perform: clearComment)
                        .focused($focusedField, equals: .comment)
                }
            }
            
            Button("Delete", role: .destructive) {
                alertIsPresented.toggle()
            }
            .alert("Delete this spending?", isPresented: $alertIsPresented) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    dismiss()
                    vm.deleteSpending(entity)
                }
            }
            .onAppear(perform: appearActions)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            keyboardToolbar
            
            trailingToolbar
        }
    }
    
    // MARK: Variables
    
    var keyboardToolbar: ToolbarItemGroup<some View> {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            
            Button(action: clearFocus) {
                Image(systemName: "keyboard.chevron.compact.down")
            }
        }
    }
    
    var trailingToolbar: ToolbarItem<(), some View> {
        ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
            Button(action: doneButton) {
                Text("Done")
                    .fontWeight(.semibold)
            }
            .disabled(!utils.checkAll(amount: newAmount, place: newPlace, category: newCategory, comment: newComment))
        }
    }
    
    // MARK: Functions
    
    private func doneButton() {
        clearFocus()
        done(entity: entity)
        withAnimation {
            edit.toggle()
        }
    }
    
    private func appearActions() {
        if update {
            updateValues()
            update = false
        }
        focusSet(focus)
    }
    
    private func focusSet(_ focus: String) {
        switch focus {
        case "amount":
            focusedField = .amount
        case "comment":
            focusedField = .comment
        default:
            focusedField = .none
        }
    }
    
    private func done(entity: SpendingEntity) {
        
        if let newAmount = Double(newAmount) {
            
            let amountUSD = newAmount / (rvm.rates[newCurrency.isEmpty ? (entity.currency?.lowercased() ?? "Error") : newCurrency.lowercased()] ?? 1)
            
            vm.editSpending(spending: entity, amount: newAmount,amountUSD: amountUSD, currency: newCurrency, place: newPlace, categoryId: newCategoryId, date: newDate, comment: newComment)
        }
        
    }
    
    private func clearComment() {
        newComment = ""
    }
    
    private func updateValues() {
        newAmount = String(entity.amount)
        newCurrency = entity.currency ?? "Error"
        newDate = entity.date ?? Date()
        newPlace = entity.place ?? "Error"
        newCategory = entity.category?.name ?? "Error"
        newCategoryId = entity.category?.id ?? UUID()
        newComment = entity.comment ?? ""
        focusedField = .amount
        
    }
    
    private func clearFocus() {
        focusedField = .none
    }
}

struct SpendingEditView_Previews: PreviewProvider {
    static var previews: some View {
        @State var entity: SpendingEntity = CoreDataViewModel().savedSpendings[0]
        @State var edit: Bool = true
        
        SpendingEditView(entity: $entity, update: true, focus: "amount", edit: $edit)
            .environmentObject(CoreDataViewModel())
    }
}
