//
//  FiltersView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/11/21.
//

import SwiftUI

struct FiltersView: View {
    @EnvironmentObject
    private var cdm: CoreDataModel
    @EnvironmentObject
    private var fvm: FiltersViewModel
    @EnvironmentObject
    private var pcvm: PieChartViewModel
    @EnvironmentObject
    private var privacyMonitor: PrivacyMonitor
    @Environment(\.dismiss)
    private var dismiss
    @AppStorage(UDKeys.color.rawValue)
    private var tint: String = "Orange"
    @AppStorage(UDKeys.privacyScreen.rawValue)
    private var privacyScreenIsEnabled: Bool = false
    
    @State
    private var showCategoriesPicker: Bool = false
    @State
    private var hideContent: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                dateSection
                    .datePickerStyle(.compact)
                
                categoriesSection
                
                currenciesSection
                
                returnsSection
                
                clearButton
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                leadingToolbar
                
                trailingToolbar
            }
        }
        .accentColor(colorIdentifier(color: tint))
        .blur(radius: hideContent ? Vars.privacyBlur : 0)
        .onChange(of: privacyMonitor.privacyScreenIsEnabled) { value in
//            print("--- \(value), privacy \(privacyScreenIsEnabled), hideContent \(hideContent)")
            let animation: Animation = value ? .default : .easeOut(duration: 0.2)
            
            if privacyScreenIsEnabled {
                withAnimation(animation) {
                    hideContent = value
                }
            }
        }
    }
    
    private var dateSection: some View {
        Section(header: dateSectionHeader) {
            firstDatePicker
            
            secondDatePicker
            
            currentYearButton
        }
    }
    
    private var dateSectionHeader: some View {
        Text("Date")
    }
    
    private var firstDatePicker: some View {
        let firstDate: Date = cdm.savedSpendings.last?.wrappedDate ?? .init(timeIntervalSinceReferenceDate: 0)
        
        return DatePicker("From", selection: $fvm.startFilterDate, in: firstDate...fvm.endFilterDate, displayedComponents: .date)
    }
    
    private var secondDatePicker: some View {
        DatePicker("To", selection: $fvm.endFilterDate, in: fvm.startFilterDate...Date.now, displayedComponents: .date)
    }
    
    private var currentYearButton: some View {
        Button {
            setCurrentYear()
        } label: {
            HStack {
                Text("Current year")
                
                Spacer()
                
                if fvm.startFilterDate == getFirstYearDate() && Calendar.current.isDate(fvm.endFilterDate, inSameDayAs: Date()) {
                    Image(systemName: "checkmark")
                        .font(.body.bold())
                }
            }
            .foregroundColor(.accentColor)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var categoriesSection: some View {
        Section {
            NavigationLink {
                FiltersCategoriesView(categories: $fvm.filterCategories, applyFilters: $fvm.applyFilters, cdm: cdm)
            } label: {
                categoriesPickerLabel
            }
        } header: {
            Text("Categories")
        }
    }
    
    private var categoriesPickerLabel: some View {
        HStack(spacing: 5) {
            Text("Categories")
            
            Spacer()
            
            Text("\(fvm.filterCategories.count) selected")
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: Returns
    private var returnsSection: some View {
        Section {
            NavigationLink {
                FiltersReturnsView(withReturns: fvm.withReturns)
            } label: {
                HStack {
                    Text("Returns")
                    
                    Spacer()
                    
                    switch fvm.withReturns {
                    case nil:
                        Text("Disabled")
                            .foregroundColor(.secondary)
                    case true:
                        Text("With returns")
                            .foregroundColor(.secondary)
                    case false:
                        Text("Without returns")
                            .foregroundColor(.secondary)
                    default:
                        Text("")
                    }
                }
            }
        } header: {
            Text("Returns")
        }
    }
    
    private var currenciesSection: some View {
        Section {
            NavigationLink {
                FiltersCurrenciesView()
            } label: {
                HStack {
                    Text("Currencies")
                    
                    Spacer()
                    
                    Text("\(fvm.currencies.count) selected")
                        .foregroundColor(.secondary)
                }
            }
        } header: {
            Text("Currencies")
        }
    }
    
    private var clearButton: some View {
        Button("Clear", role: .destructive) {
            clearFilters()
        }
    }
    
    private var leadingToolbar: ToolbarItem<(), some View> {
        ToolbarItem(placement: .topBarLeading) {
            Button("Close") {
                dismiss()
            }
        }
    }
    
    private var trailingToolbar: ToolbarItem<(), some View> {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Apply") {
                pcvm.selection = 0
                pcvm.isScrollDisabled = true
                pcvm.selectedCategory = nil
                fvm.applyFilters = true
                fvm.updateList = true
                pcvm.updateData()
                dismiss()
            }
            .font(.body.bold())
        }
    }
}
    
extension FiltersView {
    private func clearFilters() {
        withAnimation {
            pcvm.selectedCategory = nil
            fvm.clearFilters()
            pcvm.updateData()
            pcvm.isScrollDisabled = false
        }
    }
    
    private func setCurrentMonth() {
        let firstDate: Date = cdm.savedSpendings.last?.wrappedDate ?? .init(timeIntervalSinceReferenceDate: 0)
        
        fvm.startFilterDate = Date().getFirstDayOfMonth() < firstDate ? firstDate : Date().getFirstDayOfMonth()
        fvm.endFilterDate = Date()
    }
    
    private func setCurrentYear() {
        var components: DateComponents = Calendar.current.dateComponents([.year, .era], from: Date())
        components.calendar = Calendar.current
        
        guard let startDate = components.date else {
            return
        }
        
        let firstDate: Date = cdm.savedSpendings.last?.wrappedDate ?? .init(timeIntervalSinceReferenceDate: 0)
        
        fvm.startFilterDate = startDate < firstDate ? firstDate : startDate
        fvm.endFilterDate = Date()
    }
    
    private func getFirstYearDate() -> Date {
        var components: DateComponents = Calendar.current.dateComponents([.year, .era], from: Date())
        components.calendar = Calendar.current
        
        guard let startDate = components.date else {
            return Date()
        }
        
        let firstDate: Date = cdm.savedSpendings.last?.wrappedDate ?? .init(timeIntervalSinceReferenceDate: 0)
        
        return startDate < firstDate ? firstDate : startDate
    }
}

struct FiltersCategoriesView: View {
    @Environment(\.dismiss)
    private var dismiss
    
    @Binding 
    var categories: [UUID]
    @Binding
    var applyFilters: Bool
    
    let listData: [CategoryEntity]
    
    var body: some View {
        List {
            Section {
                ForEach(listData) { category in
                    Button {
                        categoryButtonAction(category)
                    } label: {
                        categoryRowLabel(category)
                    }
                }
            }
            
            Section {
                Button("Clear selection", role: .destructive) {
                    categories.removeAll()
                }
                .disabled(categories.isEmpty)
                .animation(.default.speed(2), value: categories)
            }
        }
        .navigationTitle("Filter by Categories")
        .toolbar {
            trailingToolbar
        }
    }
    
    private var trailingToolbar: ToolbarItem<Void, some View> {
        ToolbarItem {
            Button("Save") {
                dismiss()
            }
            .font(.body.bold())
        }
    }
    
    private func categoryButtonAction(_ category: CategoryEntity) {
        guard let id = category.id else {
            return
        }
        
        if categories.contains(id) {
            let index: Int = categories.firstIndex(of: id) ?? 0
            categories.remove(at: index)
        } else {
            categories.append(id)
        }
    }
    
    private func categoryRowLabel(_ category: CategoryEntity) -> some View {
        return HStack {
            Image(systemName: "circle.fill")
                .foregroundColor(Color[category.color ?? ""])
                .font(.body)
                
            Text(category.name ?? "Error")
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "checkmark")
                .font(.body.bold())
                .opacity(categories.contains(category.id ?? .init()) ? 1 : 0)
                .animation(.default.speed(3), value: categories)
        }
    }
    
    init(categories: Binding<[UUID]>, applyFilters: Binding<Bool>, cdm: CoreDataModel) {
        self._categories = categories
        self._applyFilters = applyFilters
        self.listData = (cdm.savedCategories + cdm.shadowedCategories).sorted { $0.name ?? "" < $1.name ?? "" }
    }
}

struct FiltersReturnsView: View {
    @Environment(\.dismiss)
    private var dismiss
    
    @EnvironmentObject
    private var fvm: FiltersViewModel
    
    @State
    var withReturns: Bool?
    
    var body: some View {
        List {
            Section {
                Button {
                    if fvm.withReturns != true {
                        fvm.withReturns = true
                    }
                } label: {
                    HStack {
                        Text("With returns")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "checkmark")
                            .font(.body.bold())
                            .opacity(fvm.withReturns == true ? 1 : 0)
                            .animation(.default.speed(3), value: fvm.withReturns)
                    }
                }
                
                Button {
                    if fvm.withReturns != false {
                        fvm.withReturns = false
                    }
                } label: {
                    HStack {
                        Text("Without returns")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "checkmark")
                            .font(.body.bold())
                            .opacity(fvm.withReturns == false ? 1 : 0)
                            .animation(.default.speed(3), value: fvm.withReturns)
                    }
                }
                
                Button {
                    if fvm.withReturns != nil {
                        fvm.withReturns = nil
                    }
                } label: {
                    HStack {
                        Text("Disable")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "checkmark")
                            .font(.body.bold())
                            .opacity(fvm.withReturns == nil ? 1 : 0)
                            .animation(.default.speed(3), value: fvm.withReturns)
                    }
                }
            }
        }
        .navigationTitle("Returns")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.body.bold())
                }
            }
        }
    }
}

struct FiltersCurrenciesView: View {
    @Environment(\.dismiss)
    private var dismiss
    
    @EnvironmentObject 
    private var fvm: FiltersViewModel
    @EnvironmentObject
    private var cdm: CoreDataModel
    
    var body: some View {
        List {
            ForEach(cdm.usedCurrencies.sorted(by: <)) { currency in
                Button {
                    rowAction(currency.code)
                } label: {
                    rowLabel(currency)
                }
            }
            
            Section {
                Button("Clear selection", role: .destructive) {
                    fvm.currencies = []
                }
                .disabled(fvm.currencies.isEmpty)
                .animation(.default.speed(3), value: fvm.currencies)
            }
        }
        .navigationTitle("Currencies")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            trailingToolbar
        }
    }
    
    private var trailingToolbar: ToolbarItem<Void, some View> {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                dismiss()
            } label: {
                Text("Done")
                    .bold()
            }

        }
    }
    
    private func rowLabel(_ currency: Currency) -> some View {
        HStack {
            Text(currency.name ?? currency.code)
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "checkmark")
                .font(.body.bold())
                .opacity(fvm.currencies.contains(currency.code) ? 1 : 0)
                .animation(.default.speed(3), value: fvm.currencies)
        }
    }
    
    private func rowAction(_ code: String) {
        if let index = fvm.currencies.firstIndex(of: code) {
            fvm.currencies.remove(at: index)
            return
        }
        
        fvm.currencies.append(code)
    }
}

final class PrivacyMonitor: ObservableObject {
    @Published private(set) var privacyScreenIsEnabled: Bool
    
    init(privacyScreenIsEnabled: Bool) {
        self.privacyScreenIsEnabled = privacyScreenIsEnabled
    }
    
    func changePrivacyScreenValue(_ newValue: Bool) {
        self.privacyScreenIsEnabled = newValue
    }
}
