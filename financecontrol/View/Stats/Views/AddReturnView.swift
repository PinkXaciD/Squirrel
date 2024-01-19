//
//  AddReturnView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/11/30.
//

import SwiftUI

struct AddReturnView: View {
    @Environment(\.dismiss) private var dismiss
    
    var spending: SpendingEntity
    @StateObject private var vm: AddReturnViewModel
    @State private var filterAmount: String = ""
    
    enum Field {
        case amount, name
    }
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        NavigationView {
            Form {
                mainSection
                
                addFullButton
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
        .listRowInsets(.init(top: 25, leading: 20, bottom: 25, trailing: 20))
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
    
    private var addFullButton: some View {
        Section {
            Button("Return full amount") {
                vm.addFull()
            }
            .disabled(spending.amountWithReturns == 0 || (Double(vm.amount) ?? 0) == spending.amountWithReturns)
        }
    }
    
    private var textFieldOverlay: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(Color(uiColor: UIColor.secondarySystemGroupedBackground), lineWidth: 1)
    }
    
    private var trailingToolbar: ToolbarItem<Void, some View> {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Add") {
                vm.done()
                dismiss()
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
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            
            Button(action: clearFocus) {
                Label("Hide keyboard", systemImage: "keyboard.chevron.compact.down")
                    .labelStyle(.iconOnly)
            }
        }
    }
}

extension AddReturnView {
    internal init(spending: SpendingEntity, cdm: CoreDataModel, rvm: RatesViewModel) {
        self.spending = spending
        self._vm = .init(wrappedValue: .init(spending: spending, cdm: cdm, rvm: rvm))
    }
    
    private func clearFocus() {
        focusedField = .none
    }
}
