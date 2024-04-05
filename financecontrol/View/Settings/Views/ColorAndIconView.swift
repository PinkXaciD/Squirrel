//
//  ColorAndIconView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/19.
//

import SwiftUI

struct ColorAndIconView: View {
    @AppStorage(UDKeys.color.rawValue) 
    var defaultColor: String = "Orange"
    
    @State
    private var selectedIcon: String? = UIApplication.shared.alternateIconName
    
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
            colorSection
            
            iconSection
        }
        .navigationTitle("Color and Icon")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var colorSection: some View {
        Section {
            Picker("Color", selection: $defaultColor) {
                ForEach(colors, id: \.1) { name, color in
                    Text(name)
                        .tag("\(color.description.capitalized)")
                        .foregroundColor(color)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        } header: {
            Text("Accent Color")
        }
    }
    
    private var iconSection: some View {
        Section {
            ForEach(CustomIcon.allCases, id: \.imageName) { icon in
                IconRow(icon, selection: $selectedIcon)
            }
        } header: {
            Text("Icon")
        }
    }
}

struct ColorSelector_Previews: PreviewProvider {
    static var previews: some View {
        ColorAndIconView()
    }
}
