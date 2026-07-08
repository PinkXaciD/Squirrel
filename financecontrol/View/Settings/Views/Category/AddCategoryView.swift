//
//  AddCategoryView.swift
//  Squirrel
//
//  Created by PinkXaciD on 2023/07/19.
//

import SwiftUI
import Beige

struct AddCategoryView: View {
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.colorScheme)
    private var colorScheme
    
    @EnvironmentObject
    private var cdm: CoreDataModel
    
    @Binding
    var selectedCategory: CategoryEntity?
    let insert: Bool
    
    let colors: [OKLCH]
    let unusedColors: [Double]
    
    @State 
    private var name: String = ""
    @State
    private var oklch = OKLCH(lightness: 0.7, chroma: 0.15, hue: 0)
    @State
    private var triedToSave: Bool = false
    
    @FocusState
    private var isFocused: Bool
    
    private var tintColor: Color {
        switch colorScheme {
        case .dark:
            return oklch.shift(lightness: CategoryColorValues.darkModeLightness - 0.7).color
        default:
            return oklch.shift(lightness: CategoryColorValues.lightModeLightness - 0.7).color
        }
    }
    
    private var namePadding: CGFloat {
        if #available(iOS 26.0, *) {
            return 0
        }
        
        return 3
    }
    
    var body: some View {
        List {
            nameSection
            
            colorSection
        }
        .onAppear {
            if let randomHue = unusedColors.randomElement() {
                self.oklch = .init(lightness: 0.7, chroma: 0.15, hue: randomHue)
            }
        }
        .navigationTitle("New Category")
        .toolbar {
            trailingToolbar
        }
        .addKeyboardToolbar(showToolbar: isFocused) {
            clearFocus()
        }
    }
    
    private var nameSection: some View {
        Section {
            TextField("Enter name", text: $name)
                .focused($isFocused)
                .font(.largeTitle.bold())
                .foregroundColor(tintColor)
                .padding(.vertical, namePadding)
                .onAppear(perform: fieldFocus)
        } header: {
            Text("Name")
        } footer: {
            if triedToSave && name.isEmpty {
                Text("Required")
                    .foregroundColor(.red)
            }
            
            if name.count >= 50 {
                Text("\(100 - name.count) characters left")
                    .foregroundColor(name.count > 100 ? .red : .secondary)
            }
        }
        .tint(tintColor)
        .accentColor(tintColor)
    }
    
    private var colorSection: some View {
        Section {
            CustomColorSelector(oklch: $oklch, usedColors: colors, unusedColors: unusedColors)
        } header: {
            Text("Color")
        }
    }
    
    private var trailingToolbar: ToolbarItem<Void, some View> {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Save") {
                if name.isEmpty || name.count > 100 {
                    triedToSave = true
                    HapticManager.shared.notification(.warning)
                } else {
                    if insert {
                        selectedCategory = cdm.addCategory(name: name, color: oklch.h.formatted(.number.precision(.fractionLength(3))))
                    } else {
                        _ = cdm.addCategory(name: name, color: oklch.h.formatted(.number.precision(.fractionLength(3))))
                    }
                    
                    HapticManager.shared.notification(.success)
                    dismiss()
                }
            }
            .font(.body.bold())
            .foregroundColor(name.isEmpty || name.count > 100 ? .secondary.opacity(0.7) : .accentColor)
        }
    }
    
    func clearFocus() {
        isFocused = false
    }
    
    func fieldFocus() {
        isFocused = true
    }
}

//struct NewCategoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        @State var id = UUID()
//        
//        AddCategoryView(selectedCategory: $id, insert: false)
//            .environmentObject(CoreDataModel())
//    }
//}
