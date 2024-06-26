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
    func customAlert(_ type: CustomAlertType, presenting: Binding<Bool>, message: Text = .init(verbatim: "")) -> some View {
        
        let topOffset = -(UIScreen.main.bounds.height / 2)
        let safeArea = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
        let offset = topOffset + safeArea
            
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
    
    func roundedStrikeThrough(_ color: Color = .primary, thickness: CGFloat = 2) -> some View {
        return self
            .modifier(RoundedStrikeThroughModifier(color: color, thickness: thickness))
    }
    
    func normalizePadding() -> some View {
        return self
            .modifier(IOS15Padding())
    }
    
    func invertLayoutDirection(_ isActive: Bool = true) -> some View {
        return self
            .modifier(InvertLayoutDirectionModifier(isActive: isActive))
    }
}

extension Text {
    func amountFont() -> Text {
        return self
            .font(.system(.largeTitle, design: .rounded).bold())
    }
}

fileprivate struct IOS15Padding: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            return content
        } else {
            return content.padding(.vertical, 5)
        }
    }
}

fileprivate struct RoundedStrikeThroughModifier: ViewModifier {
    let color: Color
    let thickness: CGFloat
    
    func body(content: Content) -> some View {
        content
            .overlay {
                Capsule()
                    .frame(maxWidth: .infinity, maxHeight: thickness)
                    .foregroundColor(color)
            }
    }
}

fileprivate struct SpendingPlaceTextFieldStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title2.bold())
            .multilineTextAlignment(.center)
            .overlay(overlay)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private var overlay: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(Color(uiColor: UIColor.secondarySystemGroupedBackground), lineWidth: 1)
    }
}

fileprivate struct SpendingAmountTextFieldStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(.largeTitle, design: .rounded).bold())
            .multilineTextAlignment(.center)
            .overlay(overlay)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .keyboardType(.decimalPad)
    }
    
    private var overlay: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(Color(uiColor: UIColor.secondarySystemGroupedBackground), lineWidth: 1)
    }
}

fileprivate struct InvertLayoutDirectionModifier: ViewModifier {
    @Environment(\.layoutDirection) private var layoutDirection
    let isActive: Bool
    
    func body(content: Content) -> some View {
        if isActive {
            if layoutDirection == .leftToRight {
                return content.environment(\.layoutDirection, .rightToLeft)
            } else {
                return content.environment(\.layoutDirection, .leftToRight)
            }
        } else {
            return content.environment(\.layoutDirection, layoutDirection)
        }
    }
}
