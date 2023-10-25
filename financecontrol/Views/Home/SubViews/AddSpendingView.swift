//
//  AmountInput.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/06/27.
//

import SwiftUI

struct AddSpendingView: View {
    @EnvironmentObject private var vm: CoreDataViewModel
    @EnvironmentObject private var rvm: RatesViewModel
    
    @AppStorage("color") private var tint: String = "Blue"
    @AppStorage("defaultCurrency") private var defaultCurrency: String = "USD"
    
    @Environment(\.dismiss) private var dismiss
    
    enum Field {
        case amount
        case place
        case comment
    }
    
    @FocusState private var focusedField: Field?
    
    @State private var amount: String = ""
    @State private var currency: String = (UserDefaults.standard.string(forKey: "defaultCurrency") ?? "USD")
    @State private var date: Date = Date.now
    @State private var category: String = "Select Category"
    @State private var categoryId: UUID = UUID()
    @State private var place: String = ""
    @State private var comment: String = "Enter your comment here"
    @State private var commentColor: Color = Color.secondary
    
    @State private var amountIsFocused: Bool = true
    @State private var buttonIsPressed: Bool = true

    let utils = InputUtils() // For checking
    
    var body: some View {
        
        NavigationView {
            Form {
                infoSection
                
                placeAndCommentSection
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                keyboardToolbar
                
                leadingToolbar
                
                trailingToolbar
            }
        }
        .tint(colorIdentifier(color: tint))
        .interactiveDismissDisabled(category != "Select Category" || !amount.isEmpty)
    }
    
    // MARK: Variables
    
    var infoSection: some View {
        Section {
            TextField("0.00", text: $amount)
                .multilineTextAlignment(.center)
                .numbersOnly($amount)
                .amountStyle()
                .focused($focusedField, equals: .amount)
                .onAppear(perform: amountFocus)
            
            HStack {
                Text("Currency")
                CurrencySelector(currency: $currency, showFavorites: true)
            }
            
            HStack {
                Text("Category")
                CategorySelector(category: $categoryId)
            }
            .onChange(of: categoryId) { newValue in
                category = vm.findCategory(newValue)?.name ?? "Error"
            }
            
            DatePicker("Date", selection: $date, in: Date.init(timeIntervalSinceReferenceDate: 0)...Date.now)
                .datePickerStyle(.compact)
            
        } header: {
            Text("Required")
        } footer: {
            
            if !Calendar.current.isDateInToday(date) && currency != defaultCurrency {
                Text("Historical exchange rates are presented as the stock exchange closed on the requested day")
            } else if !Calendar.current.isDate(date, equalTo: Date.now, toGranularity: .hour) && currency != defaultCurrency {
                Text("Exchange rates will be presented for the current hour")
            }
        }
    }
    
    var placeAndCommentSection: some View {
        Section(header: Text("Optional"), footer: placeAndCommentSectionFooter) {
            TextField("Name", text: $place)
                .focused($focusedField, equals: .place)
                
            if #available(iOS 16.0, *) {
                TextField("Comment", text: $comment, axis: .vertical)
                    .onAppear(perform: clearComment)
                    .focused($focusedField, equals: .comment)
            } else {
                TextEditor(text: $comment)
                    .focused($focusedField, equals: .comment)
                    .foregroundColor(commentColor)
                    .onTapGesture {
                        clearComment()
                        commentColor = Color.primary
                    }
            }
        }
    }
    
    var placeAndCommentSectionFooter: some View {
        Text("\(300 - comment.count) characters left")
            .foregroundColor(comment.count <= 300 ? Color.secondary : Color.red)
    }
    
    var keyboardToolbar: ToolbarItemGroup<some View> {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            
            Button(action: clearFocus) {
                Label("Hide keyboard", systemImage: "keyboard.chevron.compact.down")
            }
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
                if buttonIsPressed {
                    Text("Done")
                } else {
                    ProgressView()
                        .foregroundStyle(.secondary)
                }
            }
            .font(Font.body.weight(.semibold))
            .disabled(!utils.checkAll(amount: amount, place: place, category: category, comment: comment) || !buttonIsPressed)
        }
    }
}

extension AddSpendingView {
    
    private func clearComment() {
        if comment == "Enter your comment here" {
            comment = ""
        }
    }
    
    private func done() {
        if let doubleAmount = Double(amount) {
            
            buttonIsPressed = false
            
            if comment == "Enter your comment here" {
                comment = ""
            }
            
            var spending = SpendingEntityLocal(
                amountUSD: 0,
                amount: doubleAmount,
                comment: comment,
                currency: currency,
                date: date,
                place: place,
                categoryId: categoryId
            )
            
            if !Calendar.current.isDate(date, inSameDayAs: Date.now) {
                Task {
                    do {
                        let oldRates = try await rvm.getHistoricalRates(date).rates
                        await MainActor.run {
                            spending.amountUSD = doubleAmount / (oldRates[currency] ?? 1)
                            
                            vm.addSpending(spending: spending)
                            
                            dismiss()
                        }
                    } catch {
                        if let error = error as? InfoPlistError {
                            ErrorType(infoPlistError: error).publish()
                        } else {
                            ErrorType(error: error).publish()
                        }
                        
                        spending.amountUSD = doubleAmount / (rvm.rates[currency] ?? 1)
                        
                        vm.addSpending(spending: spending)
                        
                        dismiss()
                    }
                }
            } else {
                
                spending.amountUSD = doubleAmount / (rvm.rates[currency] ?? 1)
                
                vm.addSpending(spending: spending)
                
                dismiss()
            }
        }
    }
    
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
}

struct AmountInput_Previews: PreviewProvider {
    static var previews: some View {
        
        AddSpendingView()
            .environmentObject(CoreDataViewModel())
    }
}
