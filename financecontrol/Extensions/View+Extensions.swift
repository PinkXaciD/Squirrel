//
//  TextFieldExtensions.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/24.
//

import SwiftUI

extension View {
    /// Giving amount style to some text view
    /// - Returns: Few modifiers
    func amountStyle() -> some View {
        self
            .modifier(AmountStyleViewModifier())
    }
    
    /// Allows user to input only numbers with up to n numbers after decimal separator
    /// - Parameter text: Text to be formatted
    /// - Parameter currencyCode
    /// - Returns: Formatted text
    func currencyFormatted(_ text: Binding<String>, currencyCode: String) -> some View {
        self
            .modifier(NumbersViewModifier(text: text, currency: Currency(code: currencyCode)))
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
    
    func styleListsToDynamicType() -> some View {
        return self
            .modifier(DynamicTypeListStylingViewModifier())
    }
    
    func fixWheelPicker() -> some View {
        if #available(iOS 16.0, *) {
            return self
        }
        
        return self
            .frame(minWidth: .zero)
            .compositingGroup()
            .clipped()
    }
    
    func contentTransitionNumericText() -> some View {
        if #available(iOS 16.0, *) {
            return self
                .contentTransition(.numericText())
        }
        
        return self
    }
    
    func addKeyboardToolbar(showToolbar: Bool, _ action: @escaping () -> Void) -> some View {
        if #available(iOS 26.0, *) {
            return self
                .overlay(alignment: .bottomTrailing) {
                    if showToolbar {
                        Button(action: action) {
                            Label("Hide Keyboard", systemImage: "keyboard.chevron.compact.down")
                                .imageScale(.large)
                                .labelStyle(.iconOnly)
                        }
                        .buttonStyle(.glass)
                        .padding(.horizontal)
                        .padding(.vertical, 7)
                        .transition(.scale.combined(with: .moveFromBottom))
                    }
                }
                .animation(.bouncy, value: showToolbar)
        }
        
        return self
            .overlay(alignment: .bottomTrailing) {
                if showToolbar {
                    Button(action: action) {
                        Label("Hide Keyboard", systemImage: "keyboard.chevron.compact.down")
                            .imageScale(.large)
                            .labelStyle(.iconOnly)
                    }
                    .padding(.vertical, 7)
                    .padding(.horizontal, 9)
                    .background {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color(uiColor: .secondarySystemGroupedBackground))
                            .overlay {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.secondary, lineWidth: 1)
                                    .opacity(0.3)
                            }
                    }
                    .padding()
                    .transition(.moveFromBottom)
                }
            }
            .animation(.smooth, value: showToolbar)
    }
    
    static var listCornerRadius: CGFloat {
        if #available(iOS 26, *) {
            return 25
        }
        
        return 10
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

fileprivate struct AmountStyleViewModifier: ViewModifier {
    @ScaledMetric private var fontSize: CGFloat = 30
    
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 2)
            .keyboardType(.decimalPad)
            .font(.system(size: fontSize, weight: .semibold, design: .rounded))
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
            .padding(.horizontal, Content.listCornerRadius - 10)
            .overlay(overlay)
            .clipShape(RoundedRectangle(cornerRadius: Content.listCornerRadius))
    }
    
    private var overlay: some View {
        RoundedRectangle(cornerRadius: Content.listCornerRadius)
            .stroke(Color(uiColor: UIColor.secondarySystemGroupedBackground), lineWidth: 1)
    }
}

fileprivate struct SpendingAmountTextFieldStyleModifier: ViewModifier {
    private var cornerRadius: CGFloat {
        if #available(iOS 26.0, *) {
            return 25
        }
        
        return 10
    }
    
    func body(content: Content) -> some View {
        content
            .font(.system(.largeTitle, design: .rounded).bold())
            .multilineTextAlignment(.center)
            .padding(.horizontal, cornerRadius - 10)
            .overlay(overlay)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .keyboardType(.decimalPad)
    }
    
    private var overlay: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
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

fileprivate struct DynamicTypeListStylingViewModifier: ViewModifier {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    func body(content: Content) -> some View {
        return styleList(content: content)
    }
    
    @ViewBuilder
    func styleList(content: some View) -> some View {
        if dynamicTypeSize > .xLarge, horizontalSizeClass == .compact {
            content.listStyle(.grouped)
        } else {
            content.listStyle(.insetGrouped)
        }
    }
}

struct MaskFromTheBottomModifier: ViewModifier {
    let isActive: Bool
    let withOpacity: Bool
    
    func body(content: Content) -> some View {
        content
            .zIndex(isActive ? -1 : 1)
            .opacity((isActive && withOpacity) ? 0 : 1)
            .mask {
                VStack(spacing: 0) {
                    Rectangle()
                        .frame(maxHeight: isActive ? 0 : nil)
                    
                    if isActive {
                        Spacer()
                    }
                }
            }
    }
}
