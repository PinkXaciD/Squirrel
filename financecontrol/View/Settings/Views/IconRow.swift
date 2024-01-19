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
        Button(action: vm.setIcon, label: label)
    }
    
    private func label() -> some View {
        HStack {
            icon
            
            text
            
            Spacer()
            
            checkmark
        }
        .normalizePadding()
    }
    
    private var icon: some View {
        vm.getIconImage()
            .resizable()
            .frame(width: iconSize, height: iconSize)
            .cornerRadius(cornerRadius)
            .overlay(iconOverlay)
    }
    
    private var iconOverlay: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(lineWidth: 1)
            .foregroundColor(.primary)
            .opacity(0.3)
    }
    
    private var text: some View {
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
    }
    
    private var checkmark: some View {
        Image(systemName: "checkmark")
            .font(.body.bold())
            .opacity(selectedIcon == vm.icon.fileName ? 1 : 0)
    }
}

extension IconRow {
    init(_ icon: CustomIcon, selection: Binding<String?>) {
        self._vm = StateObject(wrappedValue: .init(icon: icon, selection: selection))
        self._selectedIcon = selection
    }
}
