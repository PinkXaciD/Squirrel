//
//  NumberaViewModifier.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/03.
//

import SwiftUI
import Combine

struct NumbersViewModifier: ViewModifier {
    @Binding var text: String
    
    func body(content: Content) -> some View {
        content
            .onReceive(Just(text.replacingOccurrences(of: "٫", with: Locale.current.decimalSeparator ?? "."))) { newValue in
                let decimalSeparator: String = Locale.current.decimalSeparator ?? "."
                var filteredText = newValue.filter { $0.isNumber || $0 == decimalSeparator.first ?? "." }
                
                while validate(filteredText.components(separatedBy: decimalSeparator)) {
                    filteredText = String(filteredText.dropLast())
                }
                
                if newValue != filteredText {
                    self.text = filteredText
                }
            }
    }
    
    private func validate(_ components: [String]) -> Bool {
        return components.count > 2 || (components.count == 2 && components[1].count > 2)
    }
}
