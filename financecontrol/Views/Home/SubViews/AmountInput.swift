//
//  AmountInput.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/06/27.
//

import SwiftUI
import Foundation

struct AmountInput: View {
    @EnvironmentObject private var vm: CoreDataViewModel
    @EnvironmentObject private var rvm: RatesViewModel
    @AppStorage("color") private var tint: String = "Blue"
    
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
    @State private var editCategories: Bool = false

    let utils = InputUtils() // For checking
    
    var body: some View {
        
        NavigationView {
            List {
                Section {
                    TextField("0.00", text: $amount)
                        .multilineTextAlignment(.center)
                        .numbersOnly($amount)
                        .amountStyle()
                        .focused($focusedField, equals: .amount)
                        .onAppear(perform: amountFocus)
                    
                    HStack {
                        Text("Currency")
                        CurrencySelector(currency: $currency, favorites: true)
                    }
                    
                    HStack {
                        Text("Category")
                        CategorySelector(category: $categoryId)
                    }
                    .onChange(of: categoryId) { newValue in
                        category = vm.findCategory(newValue)?.name ?? "Error"
                    }
                    
                    DatePicker("Date", selection: $date, in: Date.distantPast...Date.now)
                        .datePickerStyle(.compact)
                } footer: {
                    if !Calendar.current.isDateInToday(date) {
                        Text("Historical exchange rates are presented as the stock exchange closed on the requested day")
                    } else if !Calendar.current.isDate(date, equalTo: Date.now, toGranularity: .hour) {
                        Text("Exchange rates will be presented for the current hour")
                    }
                }
                
                Section {
                    TextField("Place name", text: $place)
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
                } header: {
                    Text("about")
                } footer: {
                    Text("\(300 - comment.count) characters left")
                        .foregroundColor(comment.count <= 300 ? Color.secondary : Color.red)
                }
                
            }
            .navigationTitle("Add Expence")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                keyboardToolbar
                
                leadingToolbar
                
                trailingToolbar
            }
        }
        .tint(colorIdentifier(color: tint))
        .interactiveDismissDisabled()
    }
    
    // MARK: Variables
    
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
            
            Button("Done", action: done)
                .font(Font.body.weight(.semibold))
                .disabled(!utils.checkAll(amount: amount, place: place, category: category, comment: comment))
        }
    }
    
    // MARK: Functions
    
    private func clearComment() {
        if comment == "Enter your comment here" {
            comment = ""
        }
    }
    
    private func done() {
        if let doubleAmount = Double(amount) {
            
            if comment == "Enter your comment here" {
                comment = ""
            }
            
            var amountUSD: Double = doubleAmount / (rvm.rates[currency] ?? 1)
            
            if !Calendar.current.isDate(date, inSameDayAs: Date.now) {
                Task {
                    do {
                        let oldRates = try await rvm.getHistoricalRates(date).rates
                        await MainActor.run {
                            amountUSD = doubleAmount / (oldRates[currency] ?? 1)
                            
                            vm.addSpending(
                                amount: doubleAmount,
                                amountUSD: amountUSD,
                                currency: currency,
                                date: date,
                                comment: comment,
                                place: place,
                                categoryId: categoryId
                            )
                            
                            dismiss()
                        }
                    } catch {
                        print(error)
                    }
                }
            } else {
                vm.addSpending(
                    amount: doubleAmount,
                    amountUSD: amountUSD,
                    currency: currency,
                    date: date,
                    comment: comment,
                    place: place,
                    categoryId: categoryId
                )
                
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
        
        AmountInput()
            .environmentObject(CoreDataViewModel())
    }
}
