//
//  AddSpendingView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/06/27.
//

import SwiftUI

struct AddSpendingView: View {
    init(ratesViewModel rvm: RatesViewModel, codeDataModel cdm: CoreDataModel, shortcut: AddSpendingShortcut? = nil) {
        self._vm = StateObject(wrappedValue: AddSpendingViewModel(ratesViewModel: rvm, coreDataModel: cdm, shortcut: shortcut))
    }
    
    @StateObject
    private var vm: AddSpendingViewModel
    
    @AppStorage(UDKeys.color.rawValue)
    private var tint: String = "Orange"
    @AppStorage(UDKeys.defaultCurrency.rawValue)
    private var defaultCurrency: String = Locale.current.currencyCode ?? "USD"
    
    @Environment(\.dismiss) 
    private var dismiss
    @Environment(\.colorScheme)
    private var colorScheme
    
    private enum Field {
        case amount
        case place
        case comment
    }
    
    @FocusState 
    private var focusedField: Field?
    
    private enum ViewState {
        case active, processing, done
    }
    
    @State
    private var viewState: ViewState = .active
    
    @State
    private var amountIsFocused: Bool = true
    @State
    private var filterAmount: String = ""

    private let utils = InputUtils() /// For input checking
    
    var body: some View {
        NavigationView {
            Form {
                reqiredSection
                
                placeAndCommentSection
            }
            .toolbar {
                keyboardToolbar
                
                leadingToolbar
                
                trailingToolbar
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
        .tint(colorIdentifier(color: tint))
        .accentColor(colorIdentifier(color: tint))
        .interactiveDismissDisabled(vm.categoryName != "Select Category" || !vm.amount.isEmpty)
    }
    
// MARK: Sections
    
    private var reqiredSection: some View {
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
                .normalizePadding()
            
            HStack {
                Text("Currency")
                CurrencySelector(currency: $vm.currency)
            }
            
            DatePicker("Date", selection: $vm.date, in: Date.init(timeIntervalSinceReferenceDate: 0)...Date.now)
                .datePickerStyle(.compact)
            
            HStack {
                Text("Category")
                CategorySelector(category: $vm.categoryId)
            }
            .onChange(of: vm.categoryId) { newValue in
                vm.categoryName = vm.cdm.findCategory(newValue)?.name ?? "Error"
            }
            
        } header: {
            Text("Required")
        } footer: {
            if vm.popularCategories.count > 0 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(vm.popularCategories) { category in
                            PopularCategoryButtonView(category: category)
                                .environmentObject(vm)
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .listRowInsets(.init(top: 10, leading: 0, bottom: 5, trailing: 0))
            }
            
            if !Calendar.current.isDateInToday(vm.date) && vm.currency != defaultCurrency {
                Text("Historical exchange rates are presented as the stock exchange closed on the requested day")
            } else if !Calendar.current.isDate(vm.date, equalTo: .now, toGranularity: .hour) && vm.currency != defaultCurrency {
                Text("Exchange rates will be presented for the current hour")
            }
        }
    }
    
    private var placeAndCommentSection: some View {
        Section(header: Text("Optional"), footer: placeAndCommentSectionFooter) {
            TextField("Place", text: $vm.place)
                .focused($focusedField, equals: .place)
                .onSubmit {
                    nextField()
                }
                
            if #available(iOS 16.0, *) {
                TextField("Comment", text: $vm.comment, axis: .vertical)
                    .focused($focusedField, equals: .comment)
            } else {
                TextEditor(text: $vm.comment)
                    .padding(.horizontal, -5)
                    .focused($focusedField, equals: .comment)
                    .overlay(alignment: .leading) {
                        if vm.comment.isEmpty {
                            Text("Comment")
                                .foregroundColor(.secondary.opacity(0.5))
                        }
                    }
                    .onTapGesture {
                        focusedField = .comment
                    }
            }
        }
    }
    
    private var placeAndCommentSectionFooter: some View {
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
                Text("Place name is too long")
                    .foregroundColor(.red)
            }
            
            if vm.comment.count > 300 {
                Text("Comment is too long")
                    .foregroundColor(.red)
            }
        }
    }
    
// MARK: Toolbars
    
    private var keyboardToolbar: ToolbarItemGroup<some View> {
        hideKeyboardToolbar {
            clearFocus()
        }
    }
    
    private var leadingToolbar: ToolbarItem<(), some View> {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel", role: .cancel, action: dismissAction)
        }
    }
    
    private var trailingToolbar: ToolbarItem<(), some View> {
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

// MARK: Functions

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
        clearFocus()
        withAnimation {
            viewState = .processing
        }
        vm.done()
        dismiss()
    }
}

fileprivate struct PopularCategoryButtonView: View {
    @EnvironmentObject private var vm: AddSpendingViewModel
    let category: CategoryEntity
    
    var body: some View {
        Button {
            if let id = category.id {
                withAnimation {
                    vm.categoryId = id
                }
            }
        } label: {
            Text(category.name ?? "Error")
                .font(.body)
                .fontWeight(vm.categoryId == category.id ? .semibold : .regular)
                .foregroundColor(vm.categoryId == category.id ? Color(uiColor: .secondarySystemGroupedBackground) : Color[category.color ?? ""])
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(vm.categoryId == category.id ? Color[category.color ?? ""] : Color(uiColor: .secondarySystemGroupedBackground))
                }
                .animation(.default, value: vm.categoryId)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: Preview
struct AmountInput_Previews: PreviewProvider {
    static var previews: some View {
        AddSpendingView(ratesViewModel: .init(), codeDataModel: .init())
            .environmentObject(CoreDataModel())
    }
}

// MARK: Shortcuts
struct AddSpendingShortcut: Identifiable {
    var id: UUID = UUID()
    var shortcutName: String
    var amount: Double?
    var currency: String?
    var categoryID: UUID?
    var place: String?
    var comment: String?
}

struct AddSpendingShortcutListView: View {
    let shortcuts = UserDefaults.standard.value(forKey: "addSpendingShortcuts") as? [UUID:AddSpendingShortcut] ?? [:]
    
    var body: some View {
        if !shortcuts.isEmpty {
            List {
                ForEach(Array(shortcuts.keys), id: \.self) { key in
                    NavigationLink {
                        AddSpendingShortcutAddView(shortcut: shortcuts[key])
                    } label: {
                        Text(shortcuts[key]?.shortcutName ?? "Error")
                    }
                }
            }
            .navigationTitle("Shortcuts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        AddSpendingShortcutAddView()
                    } label: {
                        Label("Add new", systemImage: "plus")
                    }
                }
            }
        } else {
            CustomContentUnavailableView("No Shortcuts", imageName: "tray.fill")
                .navigationTitle("Shortcuts")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink {
                            AddSpendingShortcutAddView()
                        } label: {
                            Label("Add new", systemImage: "plus")
                        }
                    }
                }
        }
    }
}

struct AddSpendingShortcutAddView: View {
    @Environment(\.dismiss) private var dismiss
    
    let shortcut: AddSpendingShortcut?
    
    @State private var shortcutName: String = ""
    @State private var amount: String = ""
    @State private var currency: String = UserDefaults.standard.string(forKey: UDKeys.defaultCurrency.rawValue) ?? Locale.current.currencyCode ?? "USD"
    @State private var categoryID: UUID = .init()
    @State private var place: String = ""
    @State private var comment: String = ""
    
    init(shortcut: AddSpendingShortcut? = nil) {
        if let shortcut {
            var formatter: NumberFormatter {
                let formatter = NumberFormatter()
                formatter.maximumFractionDigits = 2
                formatter.minimumFractionDigits = 0
                formatter.decimalSeparator = Locale.current.decimalSeparator ?? "."
                return formatter
            }
            
            self.shortcut = shortcut
            self.shortcutName = shortcut.shortcutName
            
            if let amount = shortcut.amount {
                self.amount = formatter.string(from: amount as NSNumber) ?? ""
            }
            
            self.currency = shortcut.currency ?? UserDefaults.standard.string(forKey: UDKeys.defaultCurrency.rawValue) ?? Locale.current.currencyCode ?? "USD"
            self.categoryID = shortcut.categoryID ?? .init()
            self.place = shortcut.place ?? ""
            self.comment = shortcut.comment ?? ""
        } else {
            self.shortcut = nil
        }
    }
    
    var body: some View {
        List {
            Section {
                TextField("Name", text: $shortcutName)
            }
            
            Section {
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
                    .numbersOnly($amount)
                
                HStack {
                    Text("Currency")
                    CurrencySelector(currency: $currency)
                }
                
                HStack {
                    Text("Category")
                    CategorySelector(category: $categoryID)
                }
                
                TextField("Place", text: $place)
                
                TextField("Comment", text: $comment)
            }
        }
        .navigationTitle("New Shortcut")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Text("Save")
                        .font(.body.bold())
                }
            }
        }
    }
}
