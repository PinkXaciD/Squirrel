//
//  EditSpendingView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/31.
//

import SwiftUI

struct EditSpendingView: View {
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
    
    @Binding
    var entityToAddReturn: SpendingEntity?
    @Binding
    var returnToEdit: ReturnEntity?
    
    @Binding
    var toDismiss: Bool
    
    var body: some View {
        List {
            infoSection
            
            commentSection
            
            if !(entity.returns?.allObjects.isEmpty ?? true) {
                returnsSection
            }
        }
        .toolbar {
            keyboardToolbar
            
            trailingToolbar
            
            leadingToolbar
        }
        .confirmationDialog("Delete this expense? \nYou can't undo this action.", isPresented: $alertIsPresented, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                dismiss()
                vm.cdm.deleteSpending(entity)
            }
            
            Button("Cancel", role: .cancel) {}
        }
        .onChange(of: toDismiss) { _ in
            cancelButtonAction()
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: appearActions)
        .interactiveDismissDisabled()
    }
    
    // MARK: Variables
    
    private var infoSection: some View {
        Section(header: infoHeader) {
            HStack {
                Text("Category")
                
                CategorySelector(category: $vm.categoryId)
            }
            
            DatePicker("Date", selection: $vm.date, in: Date(timeIntervalSinceReferenceDate: 0) ... Date.now)
                .datePickerStyle(.compact)
        }
    }
    
    private var infoHeader: some View {
        VStack(alignment: .center, spacing: 8) {
            TextField("Place (Optional)", text: $vm.place)
                .focused($focusedField, equals: .place)
                .spendingPlaceTextFieldStyle()
            
            TextField("Amount", text: $vm.amount)
                .focused($focusedField, equals: .amount)
                .numbersOnly($filterAmount)
                .onChange(of: vm.amount) { newValue in      ///
                    filterAmount = newValue                 ///
                }                                           /// iOS 16 fix
                .onChange(of: filterAmount) { newValue in   ///
                    vm.amount = newValue                    ///
                }
                .spendingAmountTextFieldStyle()
            
            CurrencySelector(currency: $vm.currency, spacer: false)
                .font(.body)
        }
        .textCase(nil)
        .foregroundColor(categoryColor)
        .frame(maxWidth: .infinity)
        .listRowInsets(.init(top: 10, leading: 0, bottom: 40, trailing: 0))
    }
    
    private var commentSection: some View {
        Section(header: Text("Comment"), footer: returnAndDeleteButtons) {
            if #available(iOS 16.0, *) {
                TextField("Comment (Optional)", text: $vm.comment, axis: .vertical)
                    .focused($focusedField, equals: .comment)
            } else {
                TextEditor(text: $vm.comment)
                    .focused($focusedField, equals: .comment)
            }
        }
    }
    
    private var returnAndDeleteButtons: some View {
        HStack(spacing: 15) {
            Button {
                entityToAddReturn = entity
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color(uiColor: .secondarySystemGroupedBackground))
                    
                    Text(entity.amountWithReturns == 0 ? "Returned" : "Add return")
                        .padding(10)
                        .font(.body)
                }
            }
            .foregroundColor(entity.amountWithReturns == 0 ? .secondary : .green)
            .disabled(entity.amountWithReturns == 0)
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
            
            Button(role: .destructive) {
                alertIsPresented.toggle()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color(uiColor: .secondarySystemGroupedBackground))
                    
                    Text("Delete")
                        .padding(10)
                        .font(.body)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
        }
        .listRowInsets(.init(top: 15, leading: 0, bottom: 15, trailing: 0))
        .frame(height: 30)
    }
    
    private var returnsSection: some View {
        Section {
            ForEach(entity.returnsArr) { returnEntity in
                returnRow(returnEntity)
            }
        } header: {
            Text("\(entity.returns?.allObjects.count ?? 0) returns")
        }
    }
    
    private var keyboardToolbar: ToolbarItemGroup<some View> {
        hideKeyboardToolbar {
            clearFocus()
        }
    }
    
    private var trailingToolbar: ToolbarItem<Void, some View> {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: doneButtonAction) {
                Text("Save")
                    .fontWeight(.semibold)
            }
            .disabled(
                !utils.checkAll(amount: vm.amount, place: vm.place, category: vm.categoryName, comment: vm.comment)
                ||
                entity.returnsSum > (Double(vm.amount.replacingOccurrences(of: ",", with: ".")) ?? 0)
            )
        }
    }
    
    private var leadingToolbar: ToolbarItem<Void, some View> {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel", action: cancelButtonAction)
        }
    }
}

// MARK: Functions

extension EditSpendingView {
    private func returnRow(_ returnEntity: ReturnEntity) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(returnEntity.amount.formatted(.currency(code: returnEntity.currency ?? entity.wrappedCurrency)))
                
                Spacer()
                
                Text(returnEntity.date?.formatted(date: .abbreviated, time: .shortened) ?? "Date error")
            }
            
            if let name = returnEntity.name, !name.isEmpty {
                Text(name)
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 1)
        .foregroundColor(.primary)
// MARK: Todo
//                .swipeActions(edge: .leading) {
//                    Button {
//                        returnToEdit = returnEntity
//                    } label: {
//                        Label("Edit", systemImage: "pencil")
//                    }
//                    .tint(.yellow)
//                }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                vm.removeReturn(returnEntity)
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }
            .tint(.red)
        }
    }
    
    private func doneButtonAction() {
        vm.done()
        clearFocus()
        withAnimation {
            edit.toggle()
        }
    }
    
    private func cancelButtonAction() {
        withAnimation {
            edit.toggle()
            vm.clear()
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
