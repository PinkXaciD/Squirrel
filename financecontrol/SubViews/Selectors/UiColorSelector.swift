//
//  ColorSelector.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/19.
//

import SwiftUI

struct UiColorSelector: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("color") var defaultColor: String = "Orange"
    
    @State var colorSelected: String = (UserDefaults.standard.string(forKey: "color") ?? "Blue")
    @State private var toggleIsOn: Bool = true
    
    let colors: [(String, Color)] = [
        ("Orange", Color.orange),
        ("Red", Color.red),
        ("Pink", Color.pink),
        ("Purple", Color.purple),
        ("Indigo", Color.indigo),
        ("Blue", Color.blue),
        ("Teal", Color.teal),
        ("Mint", Color.mint)
    ]
    
    var body: some View {
        List {
            Picker("Color", selection: $colorSelected) {
                ForEach(0 ..< colors.count, id: \.self) { index in
                    Text(colors[index].0).tag(colors[index].0)
                        .foregroundColor(colors[index].1)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
            
            Section {
                Toggle("Test toggle", isOn: $toggleIsOn)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                
                } label: {
                    Text("Test button")
                }
            }
        }
        .onChange(of: colorSelected, perform: { newValue in
            done()
        })
        .onAppear {
            colorSelected = defaultColor
        }
        .navigationTitle("Colors")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func done() {
        defaultColor = colorSelected
    }
}

struct ColorSelector_Previews: PreviewProvider {
    static var previews: some View {
        UiColorSelector()
    }
}

