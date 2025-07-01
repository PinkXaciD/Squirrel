//
//  ExportCSVView.swift
//  Squirrel
//
//  Created by PinkXaciD on 2024/10/16.
//

import SwiftUI

struct ExportCSVView: View {
    @Environment(\.dismiss)
    private var dismiss
    
    @AppStorage(UDKey.color.rawValue) 
    private var accentColor: String = "Orange"
    @AppStorage(UDKey.privacyScreen.rawValue)
    private var privacyScreenIsEnabled: Bool = false
    
    @EnvironmentObject
    private var privacyMonitor: PrivacyMonitor
    @ObservedObject
    private var cdm: CoreDataModel
    
    @StateObject
    private var vm: ExportCSVViewModel
    @StateObject
    private var fvm: FiltersViewModel
    
    @State
    private var shareURL: URL = .init(string: "https://apple.com")!
    @State
    private var startedExporting: Bool = false
    @State
    private var presentExportSheet: Bool = false
    @State
    private var presentFiltersSheet: Bool = false
    @State
    private var hideContent: Bool = false
    
    let showTimePicker: Bool
    
    let gregorianCalendar = Calendar(identifier: .gregorian)
    let firstSpendingDate: Date
    
    init(cdm: CoreDataModel, predicate: NSPredicate? = nil, showTimePicker: Bool = true) {
        self._cdm = .init(wrappedValue: cdm)
        self._vm = .init(wrappedValue: ExportCSVViewModel(cdm: cdm, predicate: predicate))
        self._fvm = .init(wrappedValue: .init(startFilterDate: cdm.firstSpendingDate ?? .firstAvailableDate, dateType: .all))
        self.showTimePicker = showTimePicker
        self.firstSpendingDate = cdm.firstSpendingDate ?? .firstAvailableDate
    }
    
    var body: some View {
        List {
            if showTimePicker {
                filtersSection
            }
            
            optionsSection
            
            columnsSection
            
            Section {
                exportButton
            }
        }
        .blur(radius: hideContent ? Vars.privacyBlur : 0)
        .onChange(of: fvm.startFilterDate) { newValue in
            if fvm.dateType == .all, !Calendar.current.isDate(newValue, inSameDayAs: FiltersView.DateType.all.dates.firstDate ?? .distantPast) {
                fvm.dateType = .multi
            }
        }
        .onChange(of: fvm.endFilterDate) { newValue in
            if fvm.dateType == .all, !Calendar.current.isDate(newValue, inSameDayAs: FiltersView.DateType.all.dates.secondDate ?? .distantPast) {
                fvm.dateType = .multi
            }
        }
        .onChange(of: privacyMonitor.privacyScreenIsEnabled) { value in
            let animation: Animation = value ? .default : .easeOut(duration: 0.2)
            
            if privacyScreenIsEnabled {
                withAnimation(animation) {
                    hideContent = value
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
                .disabled(startedExporting)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Export") {
                    exportButtonAction()
                }
                .font(.body.bold())
                .disabled(vm.selectedFieldsCount == 0 || startedExporting)
            }
        }
        .disabled(presentExportSheet)
        .interactiveDismissDisabled(presentExportSheet)
        .sheet(isPresented: $presentExportSheet, onDismiss: deleteTempFile) {
            CustomShareSheet(url: $shareURL)
        }
        .accentColor(colorIdentifier(color: accentColor))
        .navigationTitle("Export to Spreadsheet")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var filtersSection: some View {
        Group {
            Section {
                switch fvm.dateType {
                case .month:
                    HStack {
                        Text("Month")
                        
                        MonthPicker(selection: $fvm.month, year: fvm.year, firstAvailableDate: firstSpendingDate, calendar: gregorianCalendar)
                        
                        YearPicker(selection: $fvm.year, addSpacer: false, firstAvailableDate: firstSpendingDate, calendar: gregorianCalendar)
                    }
                case .year:
                    HStack {
                        Text("Year")
                        
                        YearPicker(selection: $fvm.year, addSpacer: true, firstAvailableDate: firstSpendingDate, calendar: gregorianCalendar)
                    }
                case .single:
                    DatePicker("Date", selection: $fvm.endFilterDate, in: (firstSpendingDate.addingTimeInterval(-1))...(Date().addingTimeInterval(1)), displayedComponents: .date)
                default:
                    Group {
                        DatePicker("From", selection: $fvm.startFilterDate, in: (firstSpendingDate.addingTimeInterval(-1))...fvm.endFilterDate, displayedComponents: .date)
                        
                        DatePicker("To", selection: $fvm.endFilterDate, in: fvm.startFilterDate...(Date().addingTimeInterval(1)), displayedComponents: .date)
                    }
                }
            } header: {
                Text("Filters")
            } footer: {
                ListHorizontalScroll(selection: $fvm.dateType, data: FiltersView.DateType.allCases, id: \.hashValue, animation: .default) { type in
                    if let firstDate = type.dates.firstDate {
                        fvm.startFilterDate = firstDate
                    }
                    
                    if let secondDate = type.dates.secondDate {
                        fvm.endFilterDate = secondDate
                    }
                }
            }
            
            Section {
                NavigationLink {
                    FiltersView(
                        startDate: cdm.firstSpendingDate ?? .firstAvailableDate,
                        fvm: fvm,
                        spendingsCount: cdm.spendingsCount,
                        firstSpendingDate: cdm.firstSpendingDate ?? .firstAvailableDate,
                        usedCurrencies: cdm.usedCurrencies,
                        showDismissButton: false,
                        showDateSelection: false
                    )
                    .environmentObject(fvm)
                    .environmentObject(privacyMonitor)
                } label: {
                    var text: Text {
                        let count = (fvm.filterCategories.isEmpty ? 0 : 1) + (fvm.currencies.isEmpty ? 0 : 1) + (fvm.withReturns == nil ? 0 : 1)
                        
                        switch count {
                        case 0:
                            return Text("None Applied")
                        case 1:
                            if !fvm.filterCategories.isEmpty {
                                return Text("\(fvm.filterCategories.count) Categories")
                            }
                            
                            if !fvm.currencies.isEmpty {
                                return Text("\(fvm.currencies.count) Currencies")
                            }
                            
                            if let withReturns = fvm.withReturns {
                                return withReturns ? Text("With Returns") : Text("Without Returns")
                            }
                        default:
                            return Text("\(count) Filters Applied")
                        }
                        
                        return Text("")
                    }
                    
//                    let count = (fvm.filterCategories.isEmpty ? 0 : 1) + (fvm.currencies.isEmpty ? 0 : 1) + (fvm.withReturns == nil ? 0 : 1)
                    
                    return HStack {
                        Text("More Filters")
                        
                        Spacer()
                        
                        text
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private var optionsSection: some View {
        Section {
            Toggle("Use Amounts with Returns", isOn: $vm.withReturns)
            
            NavigationLink("CSV Options") {
                CSVOptionsView()
                    .environmentObject(vm)
            }
            
            if vm.isTimeZoneSelected {
                HStack {
                    Text("Timezone Format")
                    
                    Menu {
                        Picker("Timezone Format", selection: $vm.timeZoneFormat) {
                            ForEach(TimeZone.Format.allCases, id: \.hashValue) { timeZoneFormat in
                                Button {} label: {
                                    if #available(iOS 16, *) {
                                        Text(timeZoneFormat.localizedName)
                                        
                                        Text(TimeZone.autoupdatingCurrent.formatted(timeZoneFormat))
                                    } else {
                                        Text("\(timeZoneFormat.localizedName)\n\(TimeZone.autoupdatingCurrent.formatted(timeZoneFormat))")
                                    }
                                }
                                .tag(timeZoneFormat)
                            }
                        }
                        .pickerStyle(.inline)
                    } label: {
                        HStack {
                            Spacer()
                            
                            Text(vm.timeZoneFormat.localizedName)
                        }
                    }
                }
            }
        } header: {
            Text("CSV Options")
        }
    }
    
    private var columnsSection: some View {
        Section {
            ForEach(vm.items) { item in
                HStack {
                    Button {
                        vm.toggleItemActiveState(item)
                    } label: {
                        if item.isActive {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.tint)
                        } else {
                            Image(systemName: "circle")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .font(.title3)
                    
                    Text(item.name)
                        .foregroundStyle(item.isActive ? .primary : .secondary)
                    
                    if #available(iOS 16.0, *) {
                        Spacer()
                        
                        Image(systemName: "line.3.horizontal")
                            .foregroundStyle(.secondary.opacity(0.5))
                            .font(.title2)
                    }
                }
            }
            .onMove { indexSet, int in
                vm.items.move(fromOffsets: indexSet, toOffset: int)
            }
        } header: {
            Text("Columns")
        }
    }
    
    private var exportButton: some View {
        Button {
            exportButtonAction()
        } label: {
            HStack {
                Image(systemName: "arrow.up.doc.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                
                VStack(alignment: .leading) {
                    Text("Export")
                        .font(.body.bold())
                        .foregroundStyle(.primary)
                    
                    Text(vm.selectedFieldsCount == 0 ? "Select at least one field" : "Export with selected parameters")
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding()
        }
        .buttonStyle(.plain)
        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay {
            if startedExporting {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                    
                    ProgressView()
                        .tint(.primary)
                }
            }
        }
        .disabled(vm.selectedFieldsCount == 0)
        .animation(.default, value: startedExporting)
        .animation(.default, value: vm.selectedFieldsCount)
    }
    
    private func exportButtonAction() {
        startedExporting = true
        
        Task {
            if let url = vm.export(predicate: vm.predicate ?? fvm.getPredicate()) {
                await MainActor.run {
                    shareURL = url
                    presentExportSheet.toggle()
                    startedExporting = false
                }
            }
        }
    }
    
    private func deleteTempFile() {
        do {
            try FileManager.default.removeItem(at: shareURL)
            dismiss()
        } catch {
            ErrorType(error: error).publish()
        }
    }
}

fileprivate extension View {
    func forceEditMode(_ isActive: Bool = true) -> some View {
        guard isActive else {
            return self
        }
        
        if #available(iOS 15.0, *) {
            return self.environment(\.editMode, .constant(.active))
        }
        
        return self
    }
}

#Preview("CSV Export Settings") {
    ExportCSVView(cdm: .init())
}
