//
//  TextFieldExtensions.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/24.
//

import SwiftUI
import UIKit

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
    
    /// Adds Custom alert to the View
    /// - Parameters:
    ///   - type: Type of custom alert
    ///   - presenting: State of presentation
    ///   - message: Text inside an alert
    /// - Returns: View with added custom alert overlay
    func customAlert(_ type: CustomAlertType, presenting: Binding<Bool>, message: String = "") -> some View {
        
        let offset = -(
            UIScreen.main.bounds.height / 2
        ) + (
//            UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
            (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.top ?? 0
        )
            
        return self
            .overlay {
                CustomAlertView(
                    isPresented: presenting,
                    type: type,
                    text: message
                )
                .scaleEffect(presenting.wrappedValue ? 1 : 0.3)
                .offset(y:(presenting.wrappedValue ? (offset + 60) : (offset - 130)))
                .onTapGesture {
                    withAnimation(.bouncy) {
                        presenting.wrappedValue = false
                    }
                }
                .gesture(DragGesture(minimumDistance: 5).onChanged { value in
                    if value.translation.height < 0 {
                        withAnimation(.bouncy) {
                            presenting.wrappedValue = false
                        }
                    }
                })
                .onChange(of: presenting.wrappedValue) { newValue in
                    if newValue {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                            withAnimation(.bouncy) {
                                presenting.wrappedValue = false
                            }
                        }
                    }
                }
            }
    }
    
    func smallSheet(_ fraction: CGFloat? = nil) -> some View {
        if #available(iOS 16.0, *) {
            return self
                .presentationDetents([.fraction(fraction ?? 0.5), .large])
                .presentationDragIndicator(.hidden)
        } else {
            return self
        }
    }
    
    func spendingAmountTextFieldStyle() -> some View {
        return self
            .modifier(SpendingAmountTextFieldStyleModifier())
    }
    
    func spendingPlaceTextFieldStyle() -> some View {
        return self
            .modifier(SpendingPlaceTextFieldStyleModifier())
    }
}

extension Text {
    func amountFont() -> Text {
        return self
            .font(.system(.largeTitle, design: .rounded).bold())
    }
}

struct SpendingPlaceTextFieldStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title2.bold())
            .multilineTextAlignment(.center)
            .overlay(overlay)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, -20)
    }
    
    private var overlay: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(Color(uiColor: UIColor.secondarySystemGroupedBackground), lineWidth: 1)
    }
}

struct SpendingAmountTextFieldStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(.largeTitle, design: .rounded).bold())
            .multilineTextAlignment(.center)
            .overlay(overlay)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, -20)
            .keyboardType(.decimalPad)
    }
    
    private var overlay: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(Color(uiColor: UIColor.secondarySystemGroupedBackground), lineWidth: 1)
    }
}
