//
//  TextFieldExtensions.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/24.
//

import Foundation
import SwiftUI

extension View {
    /// Giving amount style to some text view
    /// - Returns: Few modifiers
    func amountStyle() -> some View {
        self
            .padding(.vertical, 2)
            .keyboardType(.decimalPad)
            .font(.system(size: 30, weight: .semibold, design: .rounded))
    }
    
    /// Allows user to input only numbers with up to 2 numbers after decimal separator
    /// - Parameter text: Text to be formatted
    /// - Returns: Formatted text
    func numbersOnly(_ text: Binding<String>) -> some View {
        self
            .modifier(NumbersViewModifier(text: text))
    }
}
