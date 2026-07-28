//
//  FiltersSelectionView.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/06/12.
//

import SwiftUI

struct FiltersSelectionView<Value, Selection, RowLabel>: View where Value: Comparable, Value: Hashable, Selection: Hashable, RowLabel: View {
    @Environment(\.dismiss)
    private var dismiss
    
    @Binding var selectedValues: [Selection]
    let possibleValues: Set<Value>
    let selection: KeyPath<Value, Selection>
    let rowLabel: (Value) -> (RowLabel)
    let sortBy: (Value, Value) -> Bool
    
    let navigationTitle: LocalizedStringKey
    
    init(
        selectedValues: Binding<[Selection]>,
        possibleValues: Set<Value>,
        selecting code: KeyPath<Value, Selection>,
        navigationTitle: LocalizedStringKey,
        sorting sortBy: ((Value, Value) -> Bool)? = nil,
        rowLabel: @escaping (Value) -> (RowLabel)
    ) {
        self._selectedValues = selectedValues
        self.possibleValues = possibleValues
        self.selection = code
        self.navigationTitle = navigationTitle
        self.rowLabel = rowLabel
        
        if let sortBy {
            self.sortBy = sortBy
        } else {
            self.sortBy = {
                $0 < $1
            }
        }
    }
    
    init(
        selectedValues: Binding<[Selection]>,
        possibleValues: Set<Value>,
        navigationTitle: LocalizedStringKey,
        sorting sortBy: ((Value, Value) -> Bool)? = nil,
        rowLabel: @escaping (Value) -> (RowLabel)
    ) where Value: Identifiable, Value.ID == Selection {
        self._selectedValues = selectedValues
        self.possibleValues = possibleValues
        self.selection = \Value.id
        self.navigationTitle = navigationTitle
        self.rowLabel = rowLabel
        
        if let sortBy {
            self.sortBy = sortBy
        } else {
            self.sortBy = {
                $0 < $1
            }
        }
    }
    
    var body: some View {
        List {
            ForEach(possibleValues.sorted(by: sortBy), id: selection) { value in
                Button {
                    rowAction(value[keyPath: selection])
                } label: {
                    internalRowLabel(value)
                }
            }
            
            if !possibleValues.isEmpty {
                Section {
                    Button("Select All") {
                        selectedValues = possibleValues.map { $0[keyPath: selection] }
                    }
                    .disabled(selectedValues.count == possibleValues.count)
                    
                    Button("Clear Selection", role: .destructive) {
                        selectedValues = []
                    }
                    .disabled(selectedValues.isEmpty)
                    .animation(.default.speed(3), value: selectedValues)
                }
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            trailingToolbar
        }
        .overlay {
            if possibleValues.isEmpty {
                CustomContentUnavailableView("No Expenses", imageName: "list.bullet", description: "You can add expenses from home screen.")
            }
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
    
    private func internalRowLabel(_ value: Value) -> some View {
        HStack {
            rowLabel(value)
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "checkmark")
                .font(.body.bold())
                .opacity(selectedValues.contains(value[keyPath: selection]) ? 1 : 0)
                .animation(.default.speed(3), value: selectedValues)
        }
    }
    
    private func rowAction(_ code: Selection) {
        if let index = selectedValues.firstIndex(of: code) {
            selectedValues.remove(at: index)
            return
        }
        
        selectedValues.append(code)
    }
}
