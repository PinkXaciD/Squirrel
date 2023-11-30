//
//  SpendingEditView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/31.
//

import SwiftUI

struct SpendingEditView: View {
    @Environment(\.dismiss)
    private var dismiss
    
    @ObservedObject
    var vm: EditSpendingViewModel
    @Binding
    var entity: SpendingEntity
    @Binding
    var edit: Bool
    var categoryColor: Color
    
    @State
    private var alertIsPresented: Bool = false
    @State
    private var filterAmount: String = ""
    let utils = InputUtils()
    
    enum Field {
        case amount
        case comment
        case place
    }
    
    @FocusState
    var focusedField: Field?
    
    var focus: String = "amount"
    
    var body: some View {
        Form {
            infoSection
            
            commentSection
            
            deleteButton
        }
        .toolbar {
            keyboardToolbar
            
            doneToolbar
            
            closeToolbar
        }
        .alert("Delete this expense?", isPresented: $alertIsPresented) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                dismiss()
                vm.cdm.deleteSpending(entity)
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
                
                CategorySelector(category: $vm.categoryId)
            }
            
            DatePicker("Date", selection: $vm.date, in: Date(timeIntervalSinceReferenceDate: 0) ... Date.now)
                .datePickerStyle(.compact)
        }
    }
    
    var infoHeader: some View {
        VStack(alignment: .center, spacing: 8) {
            TextField("Place (Optional)", text: $vm.place)
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .overlay(textFieldOverlay)
                .focused($focusedField, equals: .place)
            
            TextField("Amount", text: $vm.amount)
                .font(.system(.largeTitle, design: .rounded).bold())
                .multilineTextAlignment(.center)
                .overlay(textFieldOverlay)
                .focused($focusedField, equals: .amount)
                .keyboardType(.decimalPad)
                .numbersOnly($filterAmount)
                .onChange(of: vm.amount) { newValue in /// iOS 16 fix
                    filterAmount = newValue
                }
                .onChange(of: filterAmount) { newValue in
                    vm.amount = newValue
                }
            
            HStack {
                CurrencySelector(currency: $vm.currency, showFavorites: false, spacer: false)
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
            TextField("Comment (Optional)", text: $vm.comment, axis: .vertical)
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
    
    var doneToolbar: ToolbarItem<Void, some View> {
        ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
            Button(action: doneButton) {
                Text("Save")
                    .fontWeight(.semibold)
            }
            .disabled(!utils.checkAll(amount: vm.amount, place: vm.place, category: vm.categoryName, comment: vm.comment))
        }
    }
    
    var closeToolbar: ToolbarItem<Void, some View> {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel", action: editButton)
        }
    }
}

// MARK: Functions

extension SpendingEditView {
    private func doneButton() {
        clearFocus()
        vm.done()
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
    
    private func clearFocus() {
        focusedField = .none
    }
}

// struct SpendingEditView_Previews: PreviewProvider {
//    static var previews: some View {
//        @State var entity: SpendingEntity = CoreDataModel().savedSpendings[0]
//        @State var edit: Bool = true
//
//        SpendingEditView(entity: $entity, update: true, edit: $edit, categoryColor: .accentColor, focus: "amount")
//            .environmentObject(CoreDataModel())
//    }
// }
