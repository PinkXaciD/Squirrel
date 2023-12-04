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
    
    @Binding
    var entityToAddReturn: SpendingEntity?
    
    @Binding
    var toDismiss: Bool
    
    var body: some View {
        Form {
            infoSection
            
            commentSection
            
            if !(entity.returns?.allObjects.isEmpty ?? true) {
                returnsSection
            }
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
        .onChange(of: toDismiss) { _ in
            editButtonAction()
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
                .focused($focusedField, equals: .place)
                .spendingPlaceTextFieldStyle()
            
            TextField("Amount", text: $vm.amount)
                .focused($focusedField, equals: .amount)
                .numbersOnly($filterAmount)
                .onChange(of: vm.amount) { newValue in /// iOS 16 fix
                    filterAmount = newValue
                }
                .onChange(of: filterAmount) { newValue in
                    vm.amount = newValue
                }
                .spendingAmountTextFieldStyle()
            
            CurrencySelector(currency: $vm.currency, showFavorites: false, spacer: false)
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
        Section(header: Text("Comment"), footer: returnAndDeleteButtons) {
            if #available(iOS 16.0, *) {
                TextField("Comment (Optional)", text: $vm.comment, axis: .vertical)
                    .focused($focusedField, equals: .comment)
            }
        }
    }
    
    var returnAndDeleteButtons: some View {
        HStack(spacing: 15) {
            Button(entity.amountWithReturns == 0 ? "Returned" : "Add return") {
                entityToAddReturn = entity
            }
            .foregroundColor(entity.amountWithReturns == 0 ? .secondary : .green)
            .buttonStyle(.borderless)
            .disabled(entity.amountWithReturns == 0)
            .frame(maxWidth: .infinity)
            .padding(10)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color(uiColor: .secondarySystemGroupedBackground))
            }
            .padding(.top, 10)
            
            Button("Delete", role: .destructive) {
                alertIsPresented.toggle()
            }
            .buttonStyle(.borderless)
            .frame(maxWidth: .infinity)
            .padding(10)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color(uiColor: .secondarySystemGroupedBackground))
            }
            .padding(.top, 10)
        }
        .padding(.horizontal, -20)
    }
    
    var returnsSection: some View {
        Section {
            if let returns =  entity.returns?.allObjects as? [ReturnEntity] {
                ForEach(returns) { returnEntity in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(returnEntity.amount.formatted(.currency(code: entity.wrappedCurrency)))
                            
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
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            vm.cdm.deleteReturn(spendingReturn: returnEntity)
                        } label: {
                            Label("Delete", systemImage: "trash.fill")
                        }
                        .tint(.red)
                    }
                }
            }
        } header: {
            Text("\(entity.returns?.allObjects.count ?? 0) returns")
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
            Button(action: doneButtonAction) {
                Text("Save")
                    .fontWeight(.semibold)
            }
            .disabled(
                !utils.checkAll(amount: vm.amount, place: vm.place, category: vm.categoryName, comment: vm.comment)
                ||
                entity.returnsSum > (Double(vm.amount) ?? 0)
            )
        }
    }
    
    var closeToolbar: ToolbarItem<Void, some View> {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel", action: editButtonAction)
        }
    }
}

// MARK: Functions

extension SpendingEditView {
    private func doneButtonAction() {
        clearFocus()
        vm.done()
        withAnimation {
            edit.toggle()
        }
    }
    
    private func editButtonAction() {
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
