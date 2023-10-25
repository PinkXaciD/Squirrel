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
    @Binding var edit: Bool
    var categoryColor: Color
    
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
    
    enum SpendingEditViewField {
        case amount
        case comment
        case place
    }
    
    @FocusState var focusedField: SpendingEditViewField?
    
    var focus: String = "amount"
    
    var body: some View {
        
        Form {
            infoSection
            
            commentSection
            
            deleteButton
        }
        .toolbar {
            doneToolbar
            closeToolbar
            keyboardToolbar
        }
        .alert("Delete this expense?", isPresented: $alertIsPresented) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                dismiss()
                vm.deleteSpending(entity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: appearActions)
        .interactiveDismissDisabled()
    }
    
    // MARK: Variables
    
    var infoSection: some View {
        Section(header: infoHeader) {
            HStack {
                Text("Category")
                
                CategorySelector(category: $newCategoryId)
            }
            
            DatePicker("Date", selection: $newDate, in: Date.init(timeIntervalSinceReferenceDate: 0)...Date.now)
                .datePickerStyle(.compact)
        }
    }
    
    var infoHeader: some View {
        
        VStack(alignment: .center, spacing: 8) {
            TextField("Place (Optional)", text: $newPlace)
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .overlay(textFieldOverlay)
                .focused($focusedField, equals: .place)
            
            TextField("Amount", text: $newAmount)
                .font(.system(.largeTitle, design: .rounded).bold())
                .multilineTextAlignment(.center)
                .overlay(textFieldOverlay)
                .focused($focusedField, equals: .amount)
                .keyboardType(.decimalPad)
                .numbersOnly($newAmount)
            
            HStack {
                CurrencySelector(currency: $newCurrency, showFavorites: false, spacer: false)
            }
        }
        .padding(.bottom)
        .textCase(nil)
        .foregroundColor(categoryColor)
        .frame(maxWidth: .infinity)
    }
    
    var textFieldOverlay: some View {
        
        RoundedRectangle(cornerRadius: 10)
            .stroke(Color(uiColor: UIColor.secondarySystemGroupedBackground), lineWidth: 1)
    }
    
    var commentSection: some View {
        Section(header: Text("Comment")) {
            TextField("Comment (Optional)", text: $newComment, axis: .vertical)
                .focused($focusedField, equals: .comment)
        }
    }
    
    var deleteButton: some View {
        Section {
            Button("Delete", role: .destructive) {
                alertIsPresented.toggle()
            }
        }
    }
    
    var keyboardToolbar: ToolbarItemGroup<some View> {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            
            Button(action: clearFocus) {
                Image(systemName: "keyboard.chevron.compact.down")
            }
        }
    }
    
    var doneToolbar: ToolbarItem<(), some View> {
        ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
            Button(action: doneButton) {
                Text("Save")
                    .fontWeight(.semibold)
            }
            .disabled(!utils.checkAll(amount: newAmount, place: newPlace, category: newCategory, comment: newComment))
        }
    }
    
    var closeToolbar: ToolbarItem<(), some View> {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel", action: editButton)
        }
    }
}

// MARK: Functions

extension SpendingEditView {
    
    private func doneButton() {
        clearFocus()
        done(entity: entity)
        withAnimation {
            edit.toggle()
        }
    }
    
    private func editButton() {
        withAnimation {
            edit.toggle()
        }
    }
    
    private func appearActions() {
        
        if update {
            updateValues()
            update = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            switch focus {
            case "amount":
                focusedField = .amount
            case "comment":
                focusedField = .comment
            case "place":
                focusedField = .place
            default:
                focusedField = nil
            }
        }
    }
    
    private func done(entity: SpendingEntity) {
        
        if let newAmount = Double(newAmount) {
                        
            var newSpending = SpendingEntityLocal(
                amountUSD: 0,
                amount: newAmount,
                comment: newComment,
                currency: newCurrency,
                date: newDate,
                place: newPlace,
                categoryId: newCategoryId
            )
            
            if Calendar.current.isDate(newDate, equalTo: Date.now, toGranularity: .day) { // If day == today
                
                newSpending.amountUSD = newAmount / (rvm.rates[newCurrency.isEmpty ? (entity.currency ?? "Error") : newCurrency] ?? 1)
                
                vm.editSpending(
                    spending: entity,
                    newSpending: newSpending
                )
            } else { // If day != today
                Task {
                    do {
                        let oldRates = try await rvm.getHistoricalRates(newDate).rates
                        newSpending.amountUSD = newAmount / (oldRates[newCurrency.isEmpty ? entity.wrappedCurrency : newCurrency] ?? 1)
                        
                        vm.editSpending(
                            spending: entity,
                            newSpending: newSpending
                        )
                    } catch {
                        
                        if let error = error as? InfoPlistError {
                            ErrorType(infoPlistError: error).publish()
                        }
                        
                        newSpending.amountUSD = newAmount / (rvm.rates[newCurrency.isEmpty ? (entity.currency ?? "Error") : newCurrency] ?? 1)
                        
                        vm.editSpending(
                            spending: entity,
                            newSpending: newSpending
                        )
                    }
                }
            }
        }
    }
    
    private func clearComment() {
        newComment = ""
    }
    
    private func updateValues() {
        newAmount = String(entity.amount)
        newCurrency = entity.wrappedCurrency
        newDate = entity.wrappedDate
        newPlace = entity.place ?? ""
        newCategory = entity.categoryName
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
        
        SpendingEditView(entity: $entity, update: true, edit: $edit, categoryColor: .accentColor, focus: "amount")
            .environmentObject(CoreDataViewModel())
    }
}
