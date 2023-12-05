//
//  AddSpendingView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/06/27.
//

import SwiftUI

struct AddSpendingView: View {
    internal init(ratesViewModel rvm: RatesViewModel, codeDataModel cdm: CoreDataModel) {
        self._vm = StateObject(wrappedValue: AddSpendingViewModel(ratesViewModel: rvm, coreDataModel: cdm))
    }
    
    @StateObject
    private var vm: AddSpendingViewModel
    
    @AppStorage("color") 
    private var tint: String = "Orange"
    @AppStorage("defaultCurrency") 
    private var defaultCurrency: String = "USD"
    
    @Environment(\.dismiss) 
    private var dismiss
    
    enum Field {
        case amount
        case place
        case comment
    }
    
    @FocusState 
    private var focusedField: Field?
    
    @State
    private var amountIsFocused: Bool = true
    @State
    private var filterAmount: String = ""

    let utils = InputUtils() /// For input checking
    
    var body: some View {
        NavigationView {
            Form {
                reqiredSection
                
                placeAndCommentSection
            }
            .toolbar {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    keyboardToolbar
                }
                
                leadingToolbar
                
                trailingToolbar
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
        }
        .tint(colorIdentifier(color: tint))
        .accentColor(colorIdentifier(color: tint))
        .interactiveDismissDisabled(vm.categoryName != "Select Category" || !vm.amount.isEmpty)
    }
    
    // MARK: Variables
    
    var reqiredSection: some View {
        Section {
            TextField("0.00", text: $vm.amount)
                .multilineTextAlignment(.center)
                .numbersOnly($filterAmount)
                .amountStyle()
                .focused($focusedField, equals: .amount)
                .onAppear(perform: amountFocus)
                .onChange(of: vm.amount) { newValue in      ///
                    filterAmount = newValue                 ///
                }                                           /// iOS 16 fix
                .onChange(of: filterAmount) { newValue in   ///
                    vm.amount = newValue                    ///
                }
                /// For iPad or external keyboard
                .onSubmit {
                    nextField()
                }
            
            HStack {
                Text("Currency")
                CurrencySelector(currency: $vm.currency, showFavorites: true)
            }
            
            HStack {
                Text("Category")
                CategorySelector(category: $vm.categoryId)
            }
            .onChange(of: vm.categoryId) { newValue in
                vm.categoryName = vm.cdm.findCategory(newValue)?.name ?? "Error"
            }
            
            DatePicker("Date", selection: $vm.date, in: Date.init(timeIntervalSinceReferenceDate: 0)...Date.now)
                .datePickerStyle(.compact)
            
        } header: {
            Text("Required")
            
        } footer: {
            if !Calendar.current.isDateInToday(vm.date) && vm.currency != defaultCurrency {
                Text("Historical exchange rates are presented as the stock exchange closed on the requested day")
            } else if !Calendar.current.isDate(vm.date, equalTo: .now, toGranularity: .hour) && vm.currency != defaultCurrency {
                Text("Exchange rates will be presented for the current hour")
            }
        }
    }
    
    var placeAndCommentSection: some View {
        Section(header: Text("Optional"), footer: placeAndCommentSectionFooter) {
            TextField("Name", text: $vm.place)
                .focused($focusedField, equals: .place)
                .onSubmit {
                    nextField()
                }
                
            if #available(iOS 16.0, *) {
                TextField("Comment", text: $vm.comment, axis: .vertical)
                    .focused($focusedField, equals: .comment)
            } else {
                TextEditor(text: $vm.comment)
                    .focused($focusedField, equals: .comment)
            }
        }
    }
    
    var placeAndCommentSectionFooter: some View {
        VStack(alignment: .leading) {
            switch focusedField {
            case .place:
                if vm.place.count >= 50{
                    Text("\(100 - vm.place.count) characters left")
                        .foregroundColor(vm.place.count <= 100 ? .secondary : .red)
                }
            case .comment:
                if vm.comment.count >= 250 {
                    Text("\(300 - vm.comment.count) characters left")
                        .foregroundColor(vm.comment.count <= 300 ? .secondary : .red)
                }
            default:
                EmptyView()
            }
            
            if vm.place.count > 100 {
                Text("Name is too long")
                    .foregroundColor(.red)
            }
            
            if vm.comment.count > 300 {
                Text("Comment is too long")
                    .foregroundColor(.red)
            }
        }
    }
    
    var keyboardToolbar: ToolbarItemGroup<some View> {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            
            Button(action: clearFocus) {
                Label("Hide keyboard", systemImage: "keyboard.chevron.compact.down")
            }
            .padding(.horizontal)
        }
    }
    
    var leadingToolbar: ToolbarItem<(), some View> {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel", role: .cancel, action: dismissAction)
        }
    }
    
    var trailingToolbar: ToolbarItem<(), some View> {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                done()
            } label: {
                Text("Done")
            }
            .font(Font.body.weight(.semibold))
            .disabled(!utils.checkAll(amount: vm.amount, place: vm.place, category: vm.categoryName, comment: vm.comment))
        }
    }
}

extension AddSpendingView {
    private func amountFocus() {
        if amountIsFocused {
            focusedField = .amount
            amountIsFocused = false
        }
    }
    
    private func clearFocus() {
        focusedField = .none
    }
    
    private func dismissAction() {
        dismiss()
    }
    
    private func nextField() {
        switch focusedField {
        case .amount:
            focusedField = .place
        case .place, .comment:
            focusedField = .comment
        case .none:
            focusedField = .none
        }
    }
    
    private func done() {
        vm.done()
        dismiss()
    }
}

struct AmountInput_Previews: PreviewProvider {
    static var previews: some View {
        
        AddSpendingView(ratesViewModel: .init(), codeDataModel: .init())
            .environmentObject(CoreDataModel())
    }
}
