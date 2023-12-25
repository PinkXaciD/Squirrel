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
            iconButton(description: "Yes, that's his real name")
            
            iconButton("FirstFlight", displayName: "First Flight", description: "To the store!")
            
            iconButton("NeonNight", displayName: "Neon Night")
            
            iconButton("Winterized", displayName: "Winterized", description: "Even a squirrel needs a hat in winter")
            
            iconButton("DawnOfSquipan", displayName: "Dawn of Squipan")
            
            iconButton("NA", displayName: "N:A", description: "Everything that lives is designed to end. We are perpetually trapped in a never-ending spiral...")
        } header: {
            Text("Icon")
        }
    }
    
    private func iconButton(_ name: String? = nil, displayName: LocalizedStringKey = "Sqwoorl", description: LocalizedStringKey = "") -> some View {
        let iconSize: CGFloat = 60
        let cornerRadius: CGFloat = 13.5
        
        return Button {
            UIApplication.shared.setAlternateIconName(name != nil ? "AppIcon_\(name ?? "")" : nil)
        } label: {
            HStack {
                Image("AppIcon\(name != nil ? ("_" + (name ?? "")) : "")_Image")
                    .resizable()
                    .frame(width: iconSize, height: iconSize)
                    .cornerRadius(cornerRadius)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(lineWidth: 1)
                            .foregroundColor(.primary)
                            .opacity(0.3)
                    }
                
                VStack(alignment: .leading) {
                    Text(displayName)
                        .foregroundColor(.primary)
                    
                    if description != "" {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.leading)
                
                Spacer()
                
                Image(systemName: "checkmark")
                    .font(.body.bold())
                    .opacity(UIApplication.shared.alternateIconName == (name != nil ? "AppIcon_\(name ?? "")" : nil) ? 1 : 0)
            }
        }
    }
}

struct ColorSelector_Previews: PreviewProvider {
    static var previews: some View {
        UiColorSelector()
    }
}

