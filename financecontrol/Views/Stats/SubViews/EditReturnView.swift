//
//  EditReturnView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/12/05.
//

import SwiftUI

struct EditReturnView: View {
    @Environment(\.dismiss) private var dismiss
    
    var spending: SpendingEntity
    @StateObject private var vm: EditReturnViewModel
    @State private var filterAmount: String = ""
    
    enum Field {
        case amount, name
    }
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        NavigationView {
            Form {
                mainSection
            }
            .toolbar {
                keyboardToolbar
                
                leadingToolbar
                
                trailingToolbar
            }
        }
    }
    
    private var header: some View {
        VStack(alignment: .center, spacing: 8) {
            TextField("Amount", text: $vm.amount)
                .focused($focusedField, equals: .amount)
                .numbersOnly($filterAmount)
                .spendingAmountTextFieldStyle()
                .onAppear {
                    focusedField = .amount
                }
                .onChange(of: vm.amount) { newValue in      ///
                    filterAmount = newValue                 ///
                }                                           /// iOS 16 fix
                .onChange(of: filterAmount) { newValue in   ///
                    vm.amount = newValue                    ///
                }
        }
        .padding(.vertical)
        .textCase(nil)
    }
    
    private var mainSection: some View {
        Section(header: header) {
            DatePicker("Date", selection: $vm.date, in: spending.wrappedDate...Date.now)
            
            if #available(iOS 16.0, *) {
                TextField("Comment", text: $vm.name, axis: .vertical)
                    .focused($focusedField, equals: .name)
            } else {
                TextField("Comment", text: $vm.name)
                    .focused($focusedField, equals: .name)
            }
        }
    }
    
    private var trailingToolbar: ToolbarItem<Void, some View> {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Save") {
                dismiss()
                vm.editFromSpending(spending: spending)
            }
            .font(.body.bold())
            .disabled(vm.validate())
        }
    }
    
    private var leadingToolbar: ToolbarItem<Void, some View> {
        ToolbarItem(placement: .topBarLeading) {
            Button("Cancel") {
                dismiss()
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
}

extension EditReturnView {
    internal init(returnEntity: ReturnEntity, spending: SpendingEntity, cdm: CoreDataModel, rvm: RatesViewModel) {
        self.spending = spending
        self._vm = .init(wrappedValue: .init(returnEntity: returnEntity, cdm: cdm, rvm: rvm))
    }
    
    private func clearFocus() {
        focusedField = .none
    }
}

