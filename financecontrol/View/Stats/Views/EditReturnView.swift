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
    
    enum Field {
        case amount, name
    }
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        NavigationView {
            List {
                mainSection
                
                commentSection
            }
            .toolbar {
                keyboardToolbar
                
                leadingToolbar
                
                trailingToolbar
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var header: some View {
        VStack(alignment: .center, spacing: 8) {
            if vm.currency != spending.wrappedCurrency {
                Text(vm.doubleAmount.formatted(.currency(code: spending.wrappedCurrency)))
                    .font(.system(.title, design: .rounded).bold())
                    .opacity(0.8)
                    .transition(.opacity)
                    .padding(.bottom, 20)
            }
            
            TextField("Amount", text: $vm.amount)
                .focused($focusedField, equals: .amount)
                .numbersOnly($vm.amount)
                .spendingAmountTextFieldStyle()
                .onAppear {
                    focusedField = .amount
                }
            
            CurrencySelector(currency: $vm.currency, spacer: false)
                .font(.body)
        }
        .textCase(nil)
        .foregroundColor(.accentColor)
        .frame(maxWidth: .infinity)
        .listRowInsets(.init(top: 10, leading: 0, bottom: 40, trailing: 0))
    }
    
    private var mainSection: some View {
        Section(header: header) {
            DatePicker("Date", selection: $vm.date, in: spending.wrappedDate...Date.now);
        }
    }
    
    private var commentSection: some View {
        Section {
            if #available(iOS 16.0, *) {
                TextField("Comment", text: $vm.name, axis: .vertical)
                    .focused($focusedField, equals: .name)
            } else {
                TextField("Comment", text: $vm.name)
                    .focused($focusedField, equals: .name)
            }
        } header: {
            Text("Comment")
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
    
    private var keyboardToolbar: ToolbarItemGroup<some View> {
        hideKeyboardToolbar {
            clearFocus()
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

