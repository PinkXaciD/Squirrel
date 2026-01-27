//
//  AddSpendingView.swift
//  Squirrel
//
//  Created by PinkXaciD on 2022/06/27.
//

import SwiftUI

struct AddSpendingView: View {
    init(
        ratesViewModel rvm: RatesViewModel,
        codeDataModel cdm: CoreDataModel,
        shortcut: AddSpendingShortcut? = nil
    ) {
        self._vm = StateObject(
            wrappedValue: AddSpendingViewModel(
                ratesViewModel: rvm,
                coreDataModel: cdm,
                shortcut: shortcut,
                places: cdm.places
            )
        )
        
        self.overlayManager = SuggestionsOverlayManager()
    }
    
    @StateObject
    private var vm: AddSpendingViewModel

    private let overlayManager: SuggestionsOverlayManager
    
    @AppStorage(UDKey.color.rawValue)
    private var tint: String = "Orange"
    @AppStorage(UDKey.defaultCurrency.rawValue)
    private var defaultCurrency: String = Locale.current.currencyCode ?? "USD"
    @AppStorage(UDKey.privacyScreen.rawValue)
    private var privacyScreenIsEnabled: Bool = false
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\CategoryEntity.name)], predicate: NSPredicate(format: "isShadowed == false"))
    private var categories: FetchedResults<CategoryEntity>
    
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.colorScheme)
    private var colorScheme
    @Environment(\.scenePhase)
    private var scenePhase
    
    private enum Field {
        case amount
        case place
        case comment
    }
    
    private struct WrappedCategory: ListHorizontalScrollRepresentable, Identifiable {
        let category: CategoryEntity?
        
        var id: UUID {
            category?.id ?? .init()
        }
        
        var foregroundColor: Color {
            Color[self.category?.color ?? "secondary"]
        }
        
        var label: Text {
            Text(category?.name ?? "Error")
        }
    }
    
    @FocusState 
    private var focusedField: Field?
    
    @State
    private var amountIsFocused: Bool = true
    @State
    private var hideContent: Bool = false
    @State
    private var isLoading: Bool = false
    @State
    private var minimizeSuggestions: Bool = false

    private let utils = InputUtils.shared /// For input validation
    
    private var showSuggestions: Bool {
        !vm.place.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !vm.filteredSuggestions.isEmpty && focusedField == .place && !vm.isSuggestionSelected
    }
    
    private var suggestionsAnimation: Animation {
        if #available(iOS 26.0, *) {
            return .bouncy
        }
        
        return .snappy
    }
    
    var body: some View {
        NavigationView {
            List {
                reqiredSection
                    .opacity((showSuggestions && !minimizeSuggestions) ? 0.5 : 1)
                    .blur(radius: (showSuggestions && !minimizeSuggestions) ? 1 : 0)
                    .animation(.default, value: showSuggestions)
                
                placeAndCommentSection
                
#if DEBUG
                debugSection
#endif
            }
            .toolbar {
                leadingToolbar
                
                trailingToolbar
            }
            .addKeyboardToolbar(showToolbar: focusedField != nil) {
                clearFocus()
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .overlay(alignment: .bottom) {
                GeometryReader { geometry in
                    if showSuggestions {
                        var transition: AnyTransition {
                            if #available(iOS 26.0, *) {
                                let anchor: UnitPoint = .init(x: 0.15, y: overlayManager.placeFieldPosition / max(geometry.size.height, 0.1))
                                
                                return .scale(scale: 0, anchor: anchor).combined(with: .opacity)
                            }
                            
                            return .blurWithOpacity
                        }
                        
                        SuggestionsOverlayView(vm: vm, manager: overlayManager, minimizeSuggestions: $minimizeSuggestions, geometry: geometry)
                            .transition(transition)
                    }
                }
                .animation(suggestionsAnimation, value: focusedField)
                .ignoresSafeArea(.keyboard)
            }
        }
        .navigationViewStyle(.stack)
        .tint(colorIdentifier(color: tint))
        .accentColor(colorIdentifier(color: tint))
        .interactiveDismissDisabled(!vm.amount.isEmpty)
        .animation(suggestionsAnimation, value: showSuggestions)
        .animation(suggestionsAnimation, value: minimizeSuggestions)
        .animation(suggestionsAnimation, value: vm.filteredSuggestions)
        .blur(radius: hideContent ? Vars.privacyBlur : 0)
        .onChange(of: scenePhase) { value in
            if privacyScreenIsEnabled {
                if value == .active {
                    withAnimation(.easeOut(duration: 0.2)) {
                        hideContent = false
                    }
                } else {
                    withAnimation {
                        hideContent = true
                    }
                }
            }
        }
        .onChange(of: vm.dismiss) { newValue in
            if newValue {
                dismiss()
            }
        }
    }
    
// MARK: Sections
    
    private var reqiredSection: some View {
        Section {
            TextField(Locale.current.currencyNarrowFormat(0, currency: vm.currency) ?? "0.00", text: $vm.amount)
                .multilineTextAlignment(.center)
                .currencyFormatted($vm.amount, currencyCode: vm.currency)
                .amountStyle()
                .focused($focusedField, equals: .amount)
                .onAppear(perform: amountFocus)
                /// For iPad or external keyboard
                .onSubmit {
                    nextField()
                }
                .normalizePadding()
            
            HStack {
                Text("Currency")
                
                CurrencySelector(currency: $vm.currency)
            }
            
            DatePicker("Date", selection: $vm.date, in: .firstAvailableDate...Date.now)
                .datePickerStyle(.compact)
                .padding(.vertical, -10)
            
            HStack {
                Text("Category")
                
                CategorySelector(selectedCategory: $vm.selectedCategory, categories: categories)
            }
            
        } header: {
            Text("Required")
        } footer: {
            if categories.count > 0 {
                ListHorizontalScroll(
                    selection: $vm.selectedCategory,
                    selectingValue: \WrappedCategory.category,
                    data: categories.sorted(by: { $0.spendings?.count ?? 0 > $1.spendings?.count ?? 0 }).prefix(5).map({ WrappedCategory(category: $0) }),
                    animation: .default
                )
            }
            
            if !Calendar.current.isDateInToday(vm.date) && vm.currency != defaultCurrency {
                Text("Historical exchange rates are presented as the stock exchange closed on the requested day")
            } else if !Calendar.current.isDate(vm.date, equalTo: .now, toGranularity: .hour) && vm.currency != defaultCurrency {
                Text("Exchange rates will be presented for the current hour")
            }
        }
        .disabled(isLoading)
        .animation(.default, value: vm.selectedCategory)
    }
    
    private var placeAndCommentSection: some View {
        Section(header: Text("Optional"), footer: placeAndCommentSectionFooter) {
            TextField("Place", text: $vm.place)
                .focused($focusedField, equals: .place)
                .onSubmit {
                    nextField()
                }
                .background {
                    GeometryReader { geometry in
                        Color.black.opacity(0.001)
                            .preference(
                                key: PlacePositionPreferenceKey.self,
                                value: geometry.frame(in: .global).minY - geometry.frame(in: .global).height - 5
                            )
                            .onChange(of: vm.place) { _ in
                                if overlayManager.placeFieldPosition == 0 {
                                    overlayManager.placeFieldPosition = geometry.frame(in: .global).minY - geometry.frame(in: .global).height - 5
                                }
                            }
                    }
                }
                .onPreferenceChange(PlacePositionPreferenceKey.self) { value in
                    overlayManager.placeFieldPosition = value
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
        .disabled(isLoading)
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
    
    private func getSuggestionButton(value: String) -> some View {
        Button(value) {
            vm.place = value
        }
        .buttonStyle(.plain)
        .lineLimit(1)
    }
    
#if DEBUG
    private var debugSection: some View {
        Section {
            TextField("Timezone identifier", text: $vm.timeZoneIdentifier)
            
            Text("Show suggestions: \(showSuggestions.description)")
            
            Text("Suggestions count: \(vm.filteredSuggestions.count)")
        } header: {
            Text(verbatim: "Debug")
        }
    }
#endif
    
// MARK: Toolbars
    
    private var keyboardToolbar: ToolbarItemGroup<some View> {
        hideKeyboardToolbar {
            clearFocus()
        }
    }
    
    private var leadingToolbar: ToolbarItem<(), some View> {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel", role: .cancel, action: dismissAction)
                .disabled(isLoading)
        }
    }
    
    private var trailingToolbar: ToolbarItem<(), some View> {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                done()
            } label: {
                if isLoading {
                    ProgressView()
                        .accentColor(.secondary)
                        .tint(.secondary)
                } else {
                    Text("Done")
                        .font(Font.body.weight(.semibold))
                }
            }
            .disabled(!utils.checkAll(amount: vm.amount, place: vm.place, comment: vm.comment) || vm.selectedCategory == nil || isLoading)
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
        isLoading = true
        clearFocus()
        vm.done()
    }
}

fileprivate struct PlacePositionPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}

// MARK: Preview
//struct AmountInput_Previews: PreviewProvider {
//    static var previews: some View {
//        AddSpendingView(ratesViewModel: .init(), codeDataModel: .init())
//            .environmentObject(CoreDataModel())
//    }
//}

// MARK: Shortcuts (not yet implemented)
struct AddSpendingShortcut: Identifiable {
    var id: UUID = UUID()
    var shortcutName: String
    var amount: Double?
    var currency: String?
    var categoryID: UUID?
    var place: String?
    var comment: String?
}

//struct AddSpendingShortcutListView: View {
//    let shortcuts = UserDefaults.standard.value(forKey: "addSpendingShortcuts") as? [UUID:AddSpendingShortcut] ?? [:]
//    
//    var body: some View {
//        Group {
//            if !shortcuts.isEmpty {
//                List {
//                    ForEach(Array(shortcuts.keys), id: \.self) { key in
//                        NavigationLink {
//                            AddSpendingShortcutAddView(shortcut: shortcuts[key])
//                        } label: {
//                            Text(shortcuts[key]?.shortcutName ?? "Error")
//                        }
//                    }
//                }
//            } else {
//                CustomContentUnavailableView("No Shortcuts", imageName: "tray.fill")
//            }
//        }
//        .navigationTitle("Shortcuts")
//        .navigationBarTitleDisplayMode(.inline)
//        .toolbar {
//            ToolbarItem(placement: .topBarTrailing) {
//                NavigationLink {
//                    AddSpendingShortcutAddView()
//                } label: {
//                    Label("Add new", systemImage: "plus")
//                }
//            }
//        }
//    }
//}

//struct AddSpendingShortcutAddView: View {
//    @Environment(\.dismiss) private var dismiss
//    
//    let shortcut: AddSpendingShortcut?
//    
//    @State private var shortcutName: String = ""
//    @State private var amount: String = ""
//    @State private var currency: String = UserDefaults.standard.string(forKey: UDKeys.defaultCurrency.rawValue) ?? Locale.current.currencyCode ?? "USD"
//    @State private var categoryID: UUID = .init()
//    @State private var place: String = ""
//    @State private var comment: String = ""
//    
//    init(shortcut: AddSpendingShortcut? = nil) {
//        if let shortcut {
//            var formatter: NumberFormatter {
//                let formatter = NumberFormatter()
//                formatter.maximumFractionDigits = 2
//                formatter.minimumFractionDigits = 0
//                formatter.decimalSeparator = Locale.current.decimalSeparator ?? "."
//                return formatter
//            }
//            
//            self.shortcut = shortcut
//            self.shortcutName = shortcut.shortcutName
//            
//            if let amount = shortcut.amount {
//                self.amount = formatter.string(from: amount as NSNumber) ?? ""
//            }
//            
//            self.currency = shortcut.currency ?? UserDefaults.standard.string(forKey: UDKeys.defaultCurrency.rawValue) ?? Locale.current.currencyCode ?? "USD"
//            self.categoryID = shortcut.categoryID ?? .init()
//            self.place = shortcut.place ?? ""
//            self.comment = shortcut.comment ?? ""
//        } else {
//            self.shortcut = nil
//        }
//    }
//    
//    var body: some View {
//        List {
//            Section {
//                TextField("Name", text: $shortcutName)
//            }
//            
//            Section {
//                TextField("Amount", text: $amount)
//                    .keyboardType(.decimalPad)
//                    .currencyFormatted($amount, currencyCode: currency)
//                
//                HStack {
//                    Text("Currency")
//                    CurrencySelector(currency: $currency)
//                }
//                
//                HStack {
//                    Text("Category")
//                    CategorySelector(selectedCategory: $categoryID)
//                }
//                
//                TextField("Place", text: $place)
//                
//                TextField("Comment", text: $comment)
//            }
//        }
//        .navigationTitle("New Shortcut")
//        .toolbar {
//            ToolbarItem(placement: .topBarTrailing) {
//                Button {
//                    dismiss()
//                } label: {
//                    Text("Save")
//                        .font(.body.bold())
//                }
//            }
//        }
//    }
//}
