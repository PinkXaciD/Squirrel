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
                .onReceive(Just(text)) { newValue in
                    var numbers = "0123456789"
                    let decimalSeparator: String = Locale.current.decimalSeparator ?? "."
                    numbers += decimalSeparator
                    if newValue.components(separatedBy: decimalSeparator).count-1 > 1 {
                        let filtered = newValue
                        self.text = isValid(newValue: String(filtered.dropLast()), decimalSeparator: decimalSeparator)
                    } else {
                        let filtered = newValue.filter { numbers.contains($0)}
                        if filtered != newValue {
                            self.text = isValid(newValue: filtered, decimalSeparator: decimalSeparator)
                        } else {
                            self.text = isValid(newValue: newValue, decimalSeparator: decimalSeparator)
                        }
                    }
                }
        }
    
    private func isValid(newValue: String, decimalSeparator: String) -> String {
            let component = newValue.components(separatedBy: decimalSeparator)
            if component.count > 1 {
                guard let last = component.last else { return newValue }
                if last.count > 2 {
                    let filtered = newValue
                    return String(filtered.dropLast())
                }
            }
            return newValue
        }
}
