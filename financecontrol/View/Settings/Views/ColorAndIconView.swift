//
//  ColorAndIconView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/19.
//

import SwiftUI

struct ColorAndIconView: View {
    @AppStorage(UDKey.color.rawValue) 
    var defaultColor: String = "Orange"
    @AppStorage(UDKey.color.rawValue, store: UserDefaults(suiteName: Vars.groupName))
    var sharedDefaultColor: String = "Orange"
    
    @State
    private var selectedIcon: String? = UIApplication.shared.alternateIconName
    
    let colors: [(LocalizedStringKey, Color)] = [
        ("Orange", Color.orange),
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
            ForEach(colors, id: \.1) { name, color in
                Button {
                    setColor(color.description.capitalized)
                } label: {
                    HStack {
                        Text(name)
                            .foregroundColor(color)
                        
                        Spacer()
                        
                        Image(systemName: "checkmark")
                            .font(.body.bold())
                            .opacity(defaultColor == color.description.capitalized ? 1 : 0)
                    }
                }
            }
//            Picker("Color", selection: $defaultColor) {
//                ForEach(colors, id: \.1) { name, color in
//                    Text(name)
//                        .tag("\(color.description.capitalized)")
//                        .foregroundColor(color)
//                }
//            }
//            .pickerStyle(.inline)
//            .labelsHidden()
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
    
    private func setColor(_ color: String) {
        withAnimation {
            defaultColor = color
            sharedDefaultColor = color
        }
        WidgetsManager.shared.accentColorChanged = true
    }
}

struct ColorSelector_Previews: PreviewProvider {
    static var previews: some View {
        ColorAndIconView()
    }
}
