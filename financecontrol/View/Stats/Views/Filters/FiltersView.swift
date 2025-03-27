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
                return (nil, nil)
            case .year:
                return (nil, nil)
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
    
    init(startDate: Date, fvm: FiltersViewModel) {
        self._startDate = State(wrappedValue: fvm.startFilterDate)
        self._endDate = State(wrappedValue: fvm.endFilterDate)
        self._dateType = State(wrappedValue: fvm.dateType)
        self._year = State(wrappedValue: fvm.year)
        self._month = State(wrappedValue: fvm.month)
    }
    
    var body: some View {
        NavigationView {
            Group {
                if cdm.spendingsCount == 0 {
                    CustomContentUnavailableView("No Expenses", imageName: "list.bullet", description: "You can add expenses from home screen.")
                } else {
                    List {
                        dateSection
                            .datePickerStyle(.compact)
                        
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
        }
        .accentColor(colorIdentifier(color: tint))
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
        .onChange(of: year) { newValue in
            if newValue == gregorianCalendar.component(.year, from: Date()), month > gregorianCalendar.component(.month, from: Date()) {
                month = gregorianCalendar.component(.month, from: Date())
            } else if newValue == gregorianCalendar.component(.year, from: cdm.firstSpendingDate ?? .firstAvailableDate), month < gregorianCalendar.component(.month, from: cdm.firstSpendingDate ?? .firstAvailableDate) {
                month = gregorianCalendar.component(.month, from: cdm.firstSpendingDate ?? .firstAvailableDate)
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
                    
                    Spacer()
                    
                    monthPicker
                    
                    yearPicker
                }
            case .year:
                HStack {
                    Text("Year")
                    
                    Spacer()
                    
                    yearPicker
                }
            case .single:
                DatePicker("Date", selection: $endDate, in: (cdm.firstSpendingDate?.addingTimeInterval(-1) ?? .firstAvailableDate)...(Date().addingTimeInterval(1)), displayedComponents: .date)
            default:
                Group {
                    DatePicker("From", selection: $startDate, in: (cdm.firstSpendingDate?.addingTimeInterval(-1) ?? .firstAvailableDate)...endDate, displayedComponents: .date)
                    
                    DatePicker("To", selection: $endDate, in: startDate...(Date().addingTimeInterval(1)), displayedComponents: .date)
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
        }
    }
    
    private var dateSectionHeader: some View {
        Text("Date")
    }
    
//    private var firstDatePicker: some View {
//        let firstDate: Date = cdm.firstSpendingDate ?? .firstAvailableDate
//        
//        return DatePicker("From", selection: $fvm.startFilterDate, in: firstDate...fvm.endFilterDate, displayedComponents: .date)
//    }
//    
//    private var secondDatePicker: some View {
//        DatePicker("To", selection: $fvm.endFilterDate, in: fvm.startFilterDate...(Calendar.current.date(byAdding: .minute, value: 1, to: Date()) ?? Date()), displayedComponents: .date)
//    }
//    
//    private var currentYearButton: some View {
//        Button {
//            setCurrentYear()
//        } label: {
//            HStack {
//                Text("Current year")
//                
//                Spacer()
//                
//                if fvm.startFilterDate == getFirstYearDate() && Calendar.current.isDate(fvm.endFilterDate, inSameDayAs: Date()) {
//                    Image(systemName: "checkmark")
//                        .font(.body.bold())
//                }
//            }
//            .foregroundColor(.accentColor)
//        }
//        .buttonStyle(PlainButtonStyle())
//    }
    
    private var monthPicker: some View {
        Menu {
            Picker("Select month", selection: $month){
                ForEach(getMonths(), id: \.self) { month in
                    Text((DateComponents(calendar: .current, month: month).date ?? Date()).formatted(.dateTime.month(.wide)))
                        .tag(month)
                }
            }
        } label: {
            HStack {
                Text((DateComponents(calendar: .current, month: self.month).date ?? Date()).formatted(.dateTime.month(.wide)))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(.secondary.opacity(0.15))
                    }
            }
        }
    }
    
    private var yearPicker: some View {
        Menu {
            Picker("Select year", selection: $year) {
                ForEach(getYears(), id: \.self) { year in
                    Text((DateComponents(calendar: gregorianCalendar, year: year).date ?? Date()).formatted(.dateTime.year()))
                        .tag(year)
                        .disabled(true)
                }
            }
        } label: {
            Text((DateComponents(calendar: gregorianCalendar, year: self.year).date ?? Date()).formatted(.dateTime.year()))
                .foregroundColor(.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(.secondary.opacity(0.15))
                }
        }
    }
    
    private func getMonths() -> [Int] {
        let currentYear = gregorianCalendar.component(.year, from: Date())
        
        if year == currentYear {
            let currentMonth = gregorianCalendar.component(.month, from: Date())
            let firstMonth = gregorianCalendar.component(.month, from: cdm.firstSpendingDate ?? .firstAvailableDate)
            
            if currentMonth == 1 {
                return [1]
            }
            
            if firstMonth == currentMonth, gregorianCalendar.component(.year, from: cdm.firstSpendingDate ?? .firstAvailableDate) == currentYear {
                return [currentMonth]
            }
            
            let range = 1...gregorianCalendar.component(.month, from: Date())
            
            return range.map({ $0 })
        }
        
        if let firstSpendingDate = cdm.firstSpendingDate, year == gregorianCalendar.component(.year, from: firstSpendingDate) {
            let firstSpendingMonth = gregorianCalendar.component(.month, from: firstSpendingDate)
            
            if firstSpendingMonth == 12 {
                return [12]
            }
            
            let range = firstSpendingMonth...12
            
            return range.map({ $0 })
        }
        
        let range = 1...12
        
        return range.map({ $0 })
    }
    
    private func getYears() -> [Int] {
        let startYear = gregorianCalendar.component(.year, from: cdm.firstSpendingDate ?? .firstAvailableDate)
        let currentYear  = gregorianCalendar.component(.year, from: Date())
        
        guard currentYear > startYear else {
            return [currentYear]
        }
        
        let range = startYear...currentYear
        
        return range.map({ $0 }).reversed()
    }
    
    // MARK: Categories
    private var categoriesSection: some View {
        Section {
            NavigationLink {
                FiltersCategoriesView(categories: $fvm.filterCategories, applyFilters: $fvm.applyFilters)
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
        .disabled(!fvm.applyFilters)
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
                applyFilters()
            }
            .font(.body.bold())
            .disabled(cdm.spendingsCount == 0)
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
            
            fvm.startFilterDate = max(startOfYear, cdm.firstSpendingDate ?? .firstAvailableDate)
            fvm.endFilterDate = min(endOfYear, Date())
        case .month:
            let components = DateComponents(calendar: gregorianCalendar, year: year, month: month, day: 1, hour: 0, minute: 0, second: 0, nanosecond: 0)
            
            guard let startOfMonth = components.date else {
                return
            }
            
            guard let endOfMonth = gregorianCalendar.date(byAdding: .month, value: 1, to: startOfMonth)?.addingTimeInterval(-1) else {
                return
            }
            
            fvm.startFilterDate = max(startOfMonth, cdm.firstSpendingDate ?? .firstAvailableDate)
            fvm.endFilterDate = min(endOfMonth, Date())
        case .single:
            guard let startOfDay = gregorianCalendar.date(bySettingHour: 0, minute: 0, second: 0, of: endDate) else {
                return
            }
            
            guard let endOfDay = gregorianCalendar.date(byAdding: .day, value: 1, to: startOfDay)?.addingTimeInterval(-1) else {
                return
            }
            
            fvm.startFilterDate = max(startOfDay, cdm.firstSpendingDate ?? .firstAvailableDate)
            fvm.endFilterDate = min(endOfDay, Date())
        default:
            fvm.startFilterDate = startDate
            fvm.endFilterDate = endDate
        }
        
        fvm.dateType = dateType
        fvm.year = year
        fvm.month = month
        
        fvm.applyFilters = true
        fvm.updateList = true
        pcvm.applyFilters()
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
            
            fvm.clearFilters()
            pcvm.disableFilters()
        }
    }
    
//    private func setCurrentMonth() {
//        let firstDate: Date = cdm.firstSpendingDate ?? .firstAvailableDate
//        
//        fvm.startFilterDate = Date().getFirstDayOfMonth() < firstDate ? firstDate : Date().getFirstDayOfMonth()
//        fvm.endFilterDate = Date()
//    }
//    
//    private func setCurrentYear() {
//        var components: DateComponents = Calendar.current.dateComponents([.year, .era], from: Date())
//        components.calendar = Calendar.current
//        
//        guard let startDate = components.date else {
//            return
//        }
//        
//        let firstDate: Date = cdm.firstSpendingDate ?? .firstAvailableDate
//        
//        fvm.startFilterDate = startDate < firstDate ? firstDate : startDate
//        fvm.endFilterDate = Date()
//    }
    
    private func getFirstYearDate() -> Date {
        var components: DateComponents = Calendar.current.dateComponents([.year, .era], from: Date())
        components.calendar = Calendar.current
        
        guard let startDate = components.date else {
            return Date()
        }
        
        let firstDate: Date = cdm.firstSpendingDate ?? .firstAvailableDate
        
        return startDate < firstDate ? firstDate : startDate
    }
}
