//
//  FiltersView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/11/21.
//

import SwiftUI

struct FiltersView: View {
    @EnvironmentObject
    private var fvm: FiltersViewModel
    @EnvironmentObject
    private var privacyMonitor: PrivacyMonitor
    @Environment(\.dismiss)
    private var dismiss
    @AppStorage(UDKey.color.rawValue)
    private var tint: String = "Orange"
    @AppStorage(UDKey.privacyScreen.rawValue)
    private var privacyScreenIsEnabled: Bool = false
    
    @State
    private var hideContent: Bool = false
    
    @State
    private var startDate: Date
    @State
    private var endDate: Date
    @State
    private var month: Int = Calendar.current.component(.month, from: .now)
    @State
    private var year: Int = Calendar(identifier: .gregorian).component(.year, from: .now)
    @State
    private var dateType: DateType
    @State
    private var filterCategories: [UUID]
    @State
    private var currencies: [String]
    @State
    private var withReturns: Bool?
    
    let spendingsCount: Int
    let firstSpendingDate: Date
    let usedCurrencies: Set<Currency>
    let showDismissButton: Bool
    let showDateSelection: Bool
    let gregorianCalendar = Calendar(identifier: .gregorian)
    
    enum DateType: CaseIterable, ListHorizontalScrollRepresentable {
        case multi, single, month, year, all
        
        var dates: (firstDate: Date?, secondDate: Date?) {
            switch self {
            case .single:
                return (.now, nil)
            case .multi:
                let gregorianCalendar = Calendar(identifier: .gregorian)
                let startOfMonth = DateComponents(calendar: gregorianCalendar, year: gregorianCalendar.component(.year, from: .now), month: Calendar.current.component(.month, from: .now), day: 1, hour: 0, minute: 0, second: 0, nanosecond: 0).date ?? Date()
                return (startOfMonth, .now)
            case .month:
                let gregorianCalendar = Calendar(identifier: .gregorian)
                let startOfMonth = DateComponents(calendar: gregorianCalendar, year: gregorianCalendar.component(.year, from: .now), month: Calendar.current.component(.month, from: .now), day: 1, hour: 0, minute: 0, second: 0, nanosecond: 0).date ?? Date()
                return (startOfMonth, .now)
            case .year:
                let gregorianCalendar = Calendar(identifier: .gregorian)
                let startOfMonth = DateComponents(calendar: gregorianCalendar, year: gregorianCalendar.component(.year, from: .now), month: 1, day: 1, hour: 0, minute: 0, second: 0, nanosecond: 0).date ?? Date()
                return (startOfMonth, .now)
            case .all:
                return (.firstAvailableDate, .now)
            }
        }
        
        var label: Text {
            switch self {
            case .single:
                Text("Single Date")
            case .multi:
                Text("Custom")
            case .month:
                Text("Month")
            case .year:
                Text("Year")
            case .all:
                Text("All Time")
            }
        }
        
        var foregroundColor: Color {
            .accentColor
        }
    }
    
    init(
        startDate: Date,
        fvm: FiltersViewModel,
        spendingsCount: Int,
        firstSpendingDate: Date,
        usedCurrencies: Set<Currency>,
        showDismissButton: Bool = true,
        showDateSelection: Bool = true
    ) {
        self._startDate = State(wrappedValue: max(fvm.startFilterDate, firstSpendingDate))
        
        if fvm.applyFilters {
            self._endDate = State(wrappedValue: fvm.endFilterDate)
        } else {
            self._endDate = State(wrappedValue: .now)
        }
        
        self._dateType = State(wrappedValue: fvm.dateType)
        self._year = State(wrappedValue: fvm.year)
        self._month = State(wrappedValue: fvm.month)
        self._filterCategories = State(wrappedValue: fvm.filterCategories)
        self._currencies = State(wrappedValue: fvm.currencies)
        self._withReturns = State(wrappedValue: fvm.withReturns)
        self.spendingsCount = spendingsCount
        self.firstSpendingDate = firstSpendingDate
        self.usedCurrencies = usedCurrencies
        self.showDismissButton = showDismissButton
        self.showDateSelection = showDateSelection
    }
    
    private var firstPickerDateRange: ClosedRange<Date> {
        guard firstSpendingDate < endDate else {
            return Date.firstAvailableDate...Date.now
        }
        
        return firstSpendingDate...endDate
    }
    
    private var secondPickerRange: ClosedRange<Date> {
        guard startDate < Date() else {
            return Date.firstAvailableDate...Date.now
        }
        
        return startDate...Date.now
    }
    
    private let singlePickerRange: ClosedRange<Date> = Date.firstAvailableDate...Date.now
    
    var body: some View {
        Group {
            if spendingsCount == 0 {
                CustomContentUnavailableView("No Expenses", imageName: "list.bullet", description: "You can add expenses from home screen.")
            } else {
                List {
                    if showDateSelection {
                        dateSection
                            .datePickerStyle(.compact)
                    }
                    
                    categoriesSection
                    
                    currenciesSection
                    
                    returnsSection
                    
                    clearButton
                }
            }
        }
        .navigationTitle("Filters")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            leadingToolbar
            
            trailingToolbar
        }
        .onChange(of: startDate) { newValue in
            if dateType == .all, !Calendar.current.isDate(newValue, inSameDayAs: DateType.all.dates.firstDate ?? .distantPast) {
                dateType = .multi
            }
        }
        .onChange(of: endDate) { newValue in
            if dateType == .all, !Calendar.current.isDate(newValue, inSameDayAs: DateType.all.dates.secondDate ?? .distantPast) {
                dateType = .multi
            }
        }
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
    
    // MARK: Dates
    private var dateSection: some View {
        Section {
            switch dateType {
            case .month:
                HStack {
                    Text("Month")
                    
                    MonthPicker(selection: $month, year: year, firstAvailableDate: firstSpendingDate, calendar: gregorianCalendar)
                    
                    YearPicker(selection: $year, addSpacer: false, firstAvailableDate: firstSpendingDate, calendar: gregorianCalendar)
                }
            case .year:
                HStack {
                    Text("Year")
                    
                    YearPicker(selection: $year, addSpacer: true, firstAvailableDate: firstSpendingDate, calendar: gregorianCalendar)
                }
            case .single:
                DatePicker("Date", selection: $endDate, in: singlePickerRange, displayedComponents: .date)
            default:
                Group {
                    DatePicker("From", selection: $startDate, in: firstPickerDateRange, displayedComponents: .date)
                    
                    DatePicker("To", selection: $endDate, in: secondPickerRange, displayedComponents: .date)
                }
            }
        } header: {
            dateSectionHeader
        } footer: {
            ListHorizontalScroll(selection: $dateType, data: DateType.allCases, id: \.hashValue, animation: .default) { type in
                if let firstDate = type.dates.firstDate {
                    startDate = firstDate
                }
                
                if let secondDate = type.dates.secondDate {
                    endDate = secondDate
                }
            }
            .accentColor(colorIdentifier(color: tint))
        }
    }
    
    private var dateSectionHeader: some View {
        Text("Date")
    }
    
    // MARK: Categories
    private var categoriesSection: some View {
        Section {
            NavigationLink {
                FiltersCategoriesView(categories: $filterCategories, applyFilters: $fvm.applyFilters)
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
            
            Text("\(filterCategories.count) selected")
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: Returns
    private var returnsSection: some View {
        Section {
            NavigationLink {
                FiltersReturnsView(withReturns: $withReturns)
            } label: {
                HStack {
                    Text("Returns")
                    
                    Spacer()
                    
                    switch withReturns {
                    case true:
                        Text("With returns")
                            .foregroundColor(.secondary)
                    case false:
                        Text("Without returns")
                            .foregroundColor(.secondary)
                    default:
                        Text("Disabled")
                            .foregroundColor(.secondary)
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
                FiltersCurrenciesView(currencies: $currencies, usedCurrencies: usedCurrencies)
                    .environmentObject(fvm)
            } label: {
                HStack {
                    Text("Currencies")
                    
                    Spacer()
                    
                    Text("\(currencies.count) selected")
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
        .disabled(disableClearButton)
    }
    
    private var leadingToolbar: ToolbarItem<(), some View> {
        ToolbarItem(placement: .topBarLeading) {
            if showDismissButton {
                Button("Close") {
                    dismiss()
                }
            }
        }
    }
    
    private var trailingToolbar: ToolbarItem<(), some View> {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Apply") {
                applyFilters()
            }
            .font(.body.bold())
            .disabled(spendingsCount == 0)
        }
    }
}
    
extension FiltersView {
    private func applyFilters() {
        switch dateType {
        case .year:
            let components = DateComponents(calendar: gregorianCalendar, year: year, month: 1, day: 1, hour: 0, minute: 0, second: 0, nanosecond: 0)
            
            guard let startOfYear = components.date else {
                return
            }
            
            guard let endOfYear = gregorianCalendar.date(byAdding: .year, value: 1, to: startOfYear)?.addingTimeInterval(-1) else {
                return
            }
            
            fvm.startFilterDate = max(startOfYear, firstSpendingDate)
            fvm.endFilterDate = min(endOfYear, Date())
        case .month:
            let components = DateComponents(calendar: gregorianCalendar, year: year, month: month, day: 1, hour: 0, minute: 0, second: 0, nanosecond: 0)
            
            guard let startOfMonth = components.date else {
                return
            }
            
            guard let endOfMonth = gregorianCalendar.date(byAdding: .month, value: 1, to: startOfMonth)?.addingTimeInterval(-1) else {
                return
            }
            
            fvm.startFilterDate = max(startOfMonth, firstSpendingDate)
            fvm.endFilterDate = min(endOfMonth, Date())
        case .single:
            guard let startOfDay = gregorianCalendar.date(bySettingHour: 0, minute: 0, second: 0, of: endDate) else {
                return
            }
            
            guard let endOfDay = gregorianCalendar.date(byAdding: .day, value: 1, to: startOfDay)?.addingTimeInterval(-1) else {
                return
            }
            
            fvm.startFilterDate = max(startOfDay, firstSpendingDate)
            fvm.endFilterDate = min(endOfDay, Date())
        default:
            fvm.startFilterDate = startDate
            fvm.endFilterDate = endDate
        }
        
        fvm.dateType = dateType
        fvm.year = year
        fvm.month = month
        fvm.filterCategories = filterCategories
        fvm.currencies = currencies
        fvm.withReturns = withReturns
        
        fvm.applyFilters = true
        fvm.updateList = true
        NotificationCenter.default.post(name: .UpdatePieChart, object: nil)
        dismiss()
    }
    
    private func clearFilters() {
        withAnimation {
            self.dateType = .multi
            
            if let firstDate = self.dateType.dates.firstDate {
                startDate = firstDate
            }
            
            if let secondDate = self.dateType.dates.secondDate {
                endDate = secondDate
            }
            
            self.filterCategories = []
            self.currencies = []
            self.withReturns = nil
            fvm.clearFilters()
            NotificationCenter.default.post(name: .UpdatePieChart, object: nil)
        }
    }
    
    private var disableClearButton: Bool {
        return (
            self.filterCategories.isEmpty &&
            self.withReturns == nil &&
            self.currencies.isEmpty &&
            self.dateType == .multi
        )
    }
}

struct MonthPicker: View {
    @Binding var selection: Int
    let year: Int
    let firstAvailableDate: Date
    let calendar: Calendar
    
    var cornerRadius: CGFloat {
        if #available(iOS 26.0, *) {
            return 20
        }
        
        return 8
    }
    
    var body: some View {
        Menu {
            Picker("Select month", selection: $selection){
                ForEach(getMonths(), id: \.self) { month in
                    Text((DateComponents(calendar: .current, month: month).date ?? Date()).formatted(.dateTime.month(.wide)))
                        .tag(month)
                }
            }
        } label: {
            HStack {
                Spacer()
                
                Text((DateComponents(calendar: .current, month: self.selection).date ?? Date()).formatted(.dateTime.month(.wide)))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .foregroundColor(.secondary.opacity(0.15))
                    }
            }
        }
        .onChange(of: year) { newValue in
            if newValue == calendar.component(.year, from: Date()), selection > calendar.component(.month, from: Date()) {
                selection = calendar.component(.month, from: Date())
            } else if newValue == calendar.component(.year, from: firstAvailableDate), selection < calendar.component(.month, from: firstAvailableDate) {
                selection = calendar.component(.month, from: firstAvailableDate)
            }
        }
    }
    
    private func getMonths() -> [Int] {
        let currentYear = calendar.component(.year, from: Date())
        
        if year == currentYear {
            let currentMonth = calendar.component(.month, from: Date())
            let firstMonth = calendar.component(.month, from: firstAvailableDate)
            
            if currentMonth == 1 {
                return [1]
            }
            
            if firstMonth == currentMonth, calendar.component(.year, from: firstAvailableDate) == currentYear {
                return [currentMonth]
            }
            
            let range = 1...calendar.component(.month, from: Date())
            
            return range.map({ $0 })
        }
        
        if year == calendar.component(.year, from: firstAvailableDate) {
            let firstSpendingMonth = calendar.component(.month, from: firstAvailableDate)
            
            if firstSpendingMonth == 12 {
                return [12]
            }
            
            let range = firstSpendingMonth...12
            
            return range.map({ $0 })
        }
        
        let range = 1...12
        
        return range.map({ $0 })
    }
}

struct YearPicker: View {
    @Binding var selection: Int
    let addSpacer: Bool
    let firstAvailableDate: Date
    let calendar: Calendar
    
    var cornerRadius: CGFloat {
        if #available(iOS 26.0, *) {
            return 20
        }
        
        return 8
    }
    
    var body: some View {
        Menu {
            Picker("Select year", selection: $selection) {
                ForEach(getYears(), id: \.self) { year in
                    Text((DateComponents(calendar: calendar, year: year).date ?? Date()).formatted(.dateTime.year()))
                        .tag(year)
                        .disabled(true)
                }
            }
        } label: {
            HStack {
                if addSpacer {
                    Spacer()
                }
                
                Text((DateComponents(calendar: calendar, year: self.selection).date ?? Date()).formatted(.dateTime.year()))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .foregroundColor(.secondary.opacity(0.15))
                    }
            }
        }
    }
    
    private func getYears() -> [Int] {
        let startYear = calendar.component(.year, from: firstAvailableDate)
        let currentYear  = calendar.component(.year, from: Date())
        
        guard currentYear > startYear else {
            return [currentYear]
        }
        
        let range = startYear...currentYear
        
        return range.map({ $0 }).reversed()
    }
}
