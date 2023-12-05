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
            colorSection
            
            iconSection
        }
        .navigationTitle("Color and Icon")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var colorSection: some View {
        Section {
            Picker("Color", selection: $defaultColor) {
                ForEach(0 ..< colors.count, id: \.self) { index in
                    Text(colors[index].0)
                        .tag("\(colors[index].1.description.capitalized)")
                        .foregroundColor(colors[index].1)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        } header: {
            Text("Color")
        }
    }
    
    private var iconSection: some View {
        Section {
            iconButton()
            
            iconButton("FirstFlight", displayName: "First Flight")
            
            iconButton("NeonNight", displayName: "Neon Night")
        } header: {
            Text("Icon")
        }
    }
    
    private func iconButton(_ name: String? = nil, displayName: LocalizedStringKey = "Default") -> some View {
        let iconSize: CGFloat = 60
        let cornerRadius: CGFloat = 13.5
        
        if let name = name {
            return Button {
                UIApplication.shared.setAlternateIconName("AppIcon_\(name)")
            } label: {
                HStack {
                    Image("AppIcon_\(name)_Image")
                        .resizable()
                        .frame(width: iconSize, height: iconSize)
                        .cornerRadius(cornerRadius)
                        .overlay {
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(lineWidth: 1)
                                .foregroundColor(.primary)
                                .opacity(0.3)
                        }
                    
                    Text(displayName)
                        .padding(.leading)
                        .foregroundColor(.primary)
                    
                    if UIApplication.shared.alternateIconName == "AppIcon_\(name)" {
                        Spacer()
                        
                        Image(systemName: "checkmark")
                            .font(.body.bold())
                    }
                }
            }
        } else {
            return Button {
                UIApplication.shared.setAlternateIconName(nil)
            } label: {
                HStack {
                    Image("AppIcon_Image")
                        .resizable()
                        .frame(width: iconSize, height: iconSize)
                        .cornerRadius(cornerRadius)
                        .overlay {
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(lineWidth: 1)
                                .foregroundColor(.primary)
                                .opacity(0.3)
                        }
                    
                    Text(displayName)
                        .padding(.leading)
                        .foregroundColor(.primary)
                    
                    if UIApplication.shared.alternateIconName == nil {
                        Spacer()
                        
                        Image(systemName: "checkmark")
                            .font(.body.bold())
                    }
                }
            }
        }
    }
}

struct ColorSelector_Previews: PreviewProvider {
    static var previews: some View {
        UiColorSelector()
    }
}

