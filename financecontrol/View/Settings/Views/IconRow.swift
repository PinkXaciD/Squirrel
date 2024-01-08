//
//  IconRow.swift
//  financecontrol
//
//  Created by PinkXaciD on R 6/01/08.
//

import SwiftUI

struct IconRow: View {
    @StateObject private var vm: IconRowViewModel
    @Binding var selectedIcon: String?
    private let iconSize: CGFloat = 60
    private let cornerRadius: CGFloat = 13.5
    
    var body: some View {
        Button {
            vm.setIcon()
        } label: {
            HStack {
                Image(vm.icon.imageName)
                    .resizable()
                    .frame(width: iconSize, height: iconSize)
                    .cornerRadius(cornerRadius)
                    .overlay { iconOverlay }
                
                VStack(alignment: .leading) {
                    Text(vm.icon.displayName)
                        .foregroundColor(.primary)
                    
                    if vm.icon.description != "" {
                        Text(vm.icon.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.leading)
                
                Spacer()
                
                Image(systemName: "checkmark")
                    .font(.body.bold())
                    .opacity(selectedIcon == vm.icon.fileName ? 1 : 0)
            }
        }
    }
    
    private var iconOverlay: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(lineWidth: 1)
            .foregroundColor(.primary)
            .opacity(0.3)
    }
}

extension IconRow {
    init(_ icon: CustomIcon, selection: Binding<String?>) {
        self._vm = StateObject(wrappedValue: .init(icon: icon, selection: selection))
        self._selectedIcon = selection
    }
}
