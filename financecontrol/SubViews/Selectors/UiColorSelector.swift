//
//  ColorSelector.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/19.
//

import SwiftUI

struct UiColorSelector: View {
    @AppStorage("color") var defaultColor: String = "Orange"
    
    let colors: [(LocalizedStringKey, Color)] = [
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
            Picker("Color", selection: $defaultColor) {
                ForEach(0 ..< colors.count, id: \.self) { index in
                    Text(colors[index].0)
                        .tag("\(colors[index].1.description.capitalized)")
                        .foregroundColor(colors[index].1)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        }
        .navigationTitle("Colors")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ColorSelector_Previews: PreviewProvider {
    static var previews: some View {
        UiColorSelector()
    }
}

