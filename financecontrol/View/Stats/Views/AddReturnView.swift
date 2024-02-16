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
            List {
                mainSection
                
                addFullButton
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
            
            CurrencySelector(currency: $vm.currency, showFavorites: false, spacer: false)
                .font(.body)
        }
        .textCase(nil)
        .foregroundColor(.accentColor)
        .frame(maxWidth: .infinity)
        .listRowInsets(.init(top: 10, leading: 0, bottom: 40, trailing: 0))
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
            .disabled(spending.amountWithReturns == 0 || (Double(vm.amount.replacingOccurrences(of: ",", with: ".")) ?? 0) == spending.amountWithReturns)
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
        hideKeyboardToolbar {
            clearFocus()
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
