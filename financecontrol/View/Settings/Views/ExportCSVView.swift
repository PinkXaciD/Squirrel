//
//  ExportCSVView.swift
//  Squirrel
//
//  Created by PinkXaciD on 2024/10/16.
//

import SwiftUI

struct ExportCSVView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode
    @ObservedObject private var cdm: CoreDataModel
    
    @StateObject private var vm: ExportCSVViewModel
    
    @State private var shareURL: URL = .init(string: "https://apple.com")!
    @State private var presentExportSheet: Bool = false
    
    init(cdm: CoreDataModel) {
        self._cdm = .init(wrappedValue: cdm)
        self._vm = .init(wrappedValue: ExportCSVViewModel(cdm: cdm))
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    DatePicker("From", selection: $vm.dateFrom, in: Vars.firstAvailableDate...vm.dateTo, displayedComponents: .date)
                    
                    DatePicker("To", selection: $vm.dateTo, in: vm.dateFrom...Date(), displayedComponents: .date)
                }
                
                Toggle("Use Amounts with Returns", isOn: $vm.withReturns)
                
                if vm.isTimeZoneSelected {
                    HStack {
                        Text("Timezone format")
                        
                        Menu {
                            Picker("Timezone format", selection: $vm.timeZoneFormat) {
                                ForEach(ExportCSVViewModel.TimeZoneFormat.allCases, id: \.hashValue) { timeZoneFormat in
                                    Button {} label: {
                                        if #available(iOS 16, *) {
                                            Text(timeZoneFormat.name)
                                            
                                            Text(timeZoneFormat.example)
                                        } else {
                                            Text("\(timeZoneFormat.name)\n\(timeZoneFormat.example)")
                                        }
                                    }
                                    .tag(timeZoneFormat)
                                }
                            }
                            .pickerStyle(.inline)
                        } label: {
                            HStack {
                                Spacer()
                                
                                Text(vm.timeZoneFormat.name)
                            }
                        }
                    }
                }
                
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
                        }
                    }
                    .onMove { indexSet, int in
                        vm.items.move(fromOffsets: indexSet, toOffset: int)
                    }
                }
                
                Section {
                    exportButton
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .disabled(presentExportSheet)
            .interactiveDismissDisabled(presentExportSheet)
            .sheet(isPresented: $presentExportSheet, onDismiss: deleteTempFile) {
                CustomShareSheet(url: $shareURL)
            }
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .forceEditMode()
        }
    }
    
    private var exportButton: some View {
        Button {
            if let url = vm.export() {
                shareURL = url
                presentExportSheet.toggle()
            }
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
            if presentExportSheet {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                    
                    ProgressView()
                        .tint(.primary)
                }
            }
        }
        .disabled(vm.selectedFieldsCount == 0)
        .animation(.default, value: presentExportSheet)
        .animation(.default, value: vm.selectedFieldsCount)
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
    func forceEditMode() -> some View {
        if #available(iOS 16.0, *) {
            return self.environment(\.editMode, .constant(.active))
        }
        
        return self
    }
}

#Preview("CSV Export Settings") {
    ExportCSVView(cdm: .init())
}
