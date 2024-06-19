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
        DatePicker("To", selection: $fvm.endFilterDate, in: fvm.startFilterDate...(Calendar.current.date(byAdding: .minute, value: 1, to: Date()) ?? Date()), displayedComponents: .date)
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
