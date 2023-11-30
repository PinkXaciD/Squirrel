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
    @Environment(\.dismiss)
    private var dismiss
    @AppStorage("color")
    private var tint: String = "Orange"
    
    @Binding
    var firstFilterDate: Date
    @Binding
    var secondFilterDate: Date
    @Binding
    var applyFilters: Bool
    
    @State
    private var showFirstDate: Bool = false
    @State
    private var showSecondDate: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                dateSection
                
                clearButton
            }
            .navigationTitle("Filter by date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                leadingToolbar
                
                trailingToolbar
            }
        }
        .accentColor(colorIdentifier(color: tint))
    }
    
    private var dateSection: some View {
        Section(header: Text("Date")) {
            Button(action: showFirstDateFunc, label: firstDateButtonLabel)
            
            if showFirstDate {
                firstDatePicker
            }
            
            Button(action: showSecondDateFunc, label: secondDateButtonLabel)
            
            if showSecondDate {
                secondDatePicker
            }
        }
    }
    
    private var firstDatePicker: some View {
        DatePicker("From", selection: $firstFilterDate, in: .init(timeIntervalSinceReferenceDate: 0)...secondFilterDate, displayedComponents: .date)
            .datePickerStyle(.graphical)
    }
    
    private var secondDatePicker: some View {
        DatePicker("To", selection: $secondFilterDate, in: firstFilterDate...Date.now, displayedComponents: .date)
            .datePickerStyle(.graphical)
    }
    
    private var clearButton: some View {
        Button("Clear", role: .destructive) {
            applyFilters = false
            dismiss()
            firstFilterDate = .now.getFirstDayOfMonth()
            secondFilterDate = .now
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
                applyFilters = true
                dismiss()
            }
            .font(.body.bold())
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .long
        return formatter
    }
    
    private func firstDateButtonLabel() -> some View {
        return HStack{
            Text("From")
                .foregroundColor(.primary)
            Spacer()
            Text(dateFormatter.string(from: firstFilterDate))
                .foregroundColor(showFirstDate ? .primary : .accentColor)
        }
    }
    
    private func secondDateButtonLabel() -> some View {
        return HStack {
            Text("To")
                .foregroundColor(.primary)
            Spacer()
            Text(dateFormatter.string(from: secondFilterDate))
                .foregroundColor(showSecondDate ? .primary : .accentColor)
        }
    }
    
    private func showFirstDateFunc() -> Void {
        withAnimation {
            showFirstDate.toggle()
        }
    }
    
    private func showSecondDateFunc() -> Void {
        withAnimation {
            showSecondDate.toggle()
        }
    }
}
