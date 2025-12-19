//
//  IconRow.swift
//  financecontrol
//
//  Created by PinkXaciD on R 6/01/08.
//

import SwiftUI

struct IconRow: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var vm: IconRowViewModel
    @Binding var selectedIcon: String?
    private let iconSize: CGFloat = 60
    
    private var cornerRadius: CGFloat {
        if #available(iOS 26.0, *) {
            return 16
        }
        
        return 13.5
    }
    
    var body: some View {
        Button(action: vm.setIcon, label: label)
            .contextMenu {
                Button {
                    vm.setIcon()
                } label: {
                    Text("Set icon")
                }

            }
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
            .setDarkModeForIcon()
            .hoverEffect(.lift)
            .shadow(color: .black.opacity(0.2), radius: 5, y: 2)
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

fileprivate extension View {
    func setDarkModeForIcon() -> some View {
        if #unavailable(iOS 18.0) {
            return self.environment(\.colorScheme, .light)
        }
        
        return self
    }
}

#Preview {
    NavigationView {
        List {
            ForEach(CustomIcon.allCases, id: \.imageName) { icon in
                IconRow(icon, selection: .constant(nil))
            }
        }
    }
}
