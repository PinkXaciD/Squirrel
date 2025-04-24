//
//  EditSpendingView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/31.
//

import SwiftUI

struct EditSpendingView: View {
    @AppStorage(UDKey.formatWithoutTimeZones.rawValue)
    private var formatWithoutTimeZones: Bool = false
    @AppStorage(UDKey.timeZoneFormat.rawValue)
    private var timeZoneFormat: Int = 0
    
    @Environment(\.dismiss)
    private var dismiss
    
    @StateObject
    private var vm: EditSpendingViewModel
    
    var entity: SpendingEntity
    @Binding
    var edit: Bool
    var categoryColor: Color
    
    @State
    private var confirmationDialogIsPresented: Bool = false
    @State
    private var buttonTapped: Bool = false
    let utils = InputUtils()
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\CategoryEntity.name)], predicate: NSPredicate(format: "isShadowed == false"))
    private var categories: FetchedResults<CategoryEntity>
    
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
        .confirmationDialog("Delete this expense?", isPresented: $confirmationDialogIsPresented, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                dismiss()
                vm.cdm.deleteSpending(entity)
            }
        } message: {
            Text("You can't undo this action.")
        }
        .onChange(of: toDismiss) { _ in
            cancelButtonAction()
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: appearActions)
        .disabled(vm.isLoading)
    }
    
    // MARK: Variables
    
    private var infoSection: some View {
        Section {
            HStack {
                Text("Category")
                
                CategorySelector(selectedCategory: $vm.category, categories: categories)
            }
            
            DatePicker("Date", selection: $vm.date, in: .firstAvailableDate...Date.now)
                .datePickerStyle(.compact)
        } header: {
            infoHeader
        } footer: {
            if !formatWithoutTimeZones, let timeZoneID = entity.timeZoneIdentifier, timeZoneID != TimeZone.autoupdatingCurrent.identifier {
                HStack {
                    Spacer()
                    
                    Text(vm.date.formatted(getFormatStyle))
                }
            }
        }
    }
    
    private var getFormatStyle: Date.FormatStyle {
        var dateFormatStyle: Date.FormatStyle = .dateTime.day().month().year().hour().minute()
        
        if let timeZoneIdentifier = entity.timeZoneIdentifier, let entityTimeZone = TimeZone(identifier: timeZoneIdentifier) {
            let timeZoneFormatStyle = TimeZone.Format(rawValue: timeZoneFormat)
            dateFormatStyle.timeZone = entityTimeZone
            dateFormatStyle = dateFormatStyle.timeZone(timeZoneFormatStyle.formatStyle)
        }
        
        return dateFormatStyle
    }
    
    private var infoHeader: some View {
        VStack(alignment: .center, spacing: 8) {
            TextField("Place (Optional)", text: $vm.place)
                .focused($focusedField, equals: .place)
                .spendingPlaceTextFieldStyle()
            
            TextField("Amount", text: $vm.amount)
                .focused($focusedField, equals: .amount)
                .currencyFormatted($vm.amount, currencyCode: vm.currency)
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
            .contentShape(.hoverEffect, RoundedRectangle(cornerRadius: 10))
            .hoverEffect()
            .padding(.top, 10)
            
            Button(role: .destructive) {
                confirmationDialogIsPresented.toggle()
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
            .contentShape(.hoverEffect, RoundedRectangle(cornerRadius: 10))
            .hoverEffect()
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
        } footer: {
            Text("Returns amount is greater then the expense amount")
                .foregroundStyle(.red)
                .opacity((entity.returnsSum > (Double(vm.amount.replacingOccurrences(of: ",", with: ".")) ?? 0) && buttonTapped) ? 1 : 0)
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
                if vm.isLoading {
                    ProgressView()
                        .tint(.secondary)
                        .accentColor(.secondary)
                } else {
                    Text("Save")
                        .fontWeight(.semibold)
                }
            }
            .foregroundStyle(isTrailingButtonDisabled ? Color.secondary.opacity(0.7) : categoryColor)
        }
    }
    
    private var isTrailingButtonDisabled: Bool {
        !utils.checkAll(amount: vm.amount, place: vm.place, comment: vm.comment)
        ||
        entity.returnsSum > (Double(vm.amount.replacingOccurrences(of: ",", with: ".")) ?? 0)
    }
    
    private var leadingToolbar: ToolbarItem<Void, some View> {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel", action: cancelButtonAction)
        }
    }
}

// MARK: Functions

extension EditSpendingView {
    init(
        entity: SpendingEntity,
        edit: Binding<Bool>,
        categoryColor: Color,
        focus: String,
        entityToAddReturn: Binding<SpendingEntity?>,
        returnToEdit: Binding<ReturnEntity?>,
        toDismiss: Binding<Bool>,
        cdm: CoreDataModel,
        rvm: RatesViewModel
    ) {
        self.entity = entity
        self._edit = edit
        self.categoryColor = categoryColor
        self.focus = focus
        self._entityToAddReturn = entityToAddReturn
        self._returnToEdit = returnToEdit
        self._toDismiss = toDismiss
        self._vm = StateObject(wrappedValue: EditSpendingViewModel(ratesViewModel: rvm, coreDataModel: cdm, entity: entity))
    }
    
    private func returnRow(_ returnEntity: ReturnEntity) -> some View {
        ReturnRow(returnToEdit: $returnToEdit, returnEntity: returnEntity, spendingCurrency: entity.wrappedCurrency)
    }
    
    private func doneButtonAction() {
        guard !isTrailingButtonDisabled else {
            withAnimation {
                buttonTapped = true
            }
            HapticManager.shared.notification(.error)
            return
        }
        
        vm.isLoading = true
        vm.done()
        clearFocus()
    }
    
    private func cancelButtonAction() {
        edit.toggle()
        vm.clear()
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
