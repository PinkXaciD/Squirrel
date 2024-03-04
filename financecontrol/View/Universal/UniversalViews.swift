//
//  UniversalViews.swift
//  financecontrol
//
//  Created by PinkXaciD on R 6/01/24.
//

import SwiftUI

func hideKeyboardToolbar(action: @escaping () -> Void) -> ToolbarItemGroup<some View> {
    return ToolbarItemGroup(placement: .keyboard) {
        Spacer()
        
        Button(action: action) {
            Label("Hide keyboard", systemImage: "keyboard.chevron.compact.down")
        }
    }
}
