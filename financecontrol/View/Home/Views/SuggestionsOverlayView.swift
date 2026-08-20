//
//  SuggestionsOverlayView.swift
//  Squirrel
//
//  Created by PinkXaciD on 2026/01/27.
//

import SwiftUI

struct SuggestionsOverlayView: View {
    @ObservedObject
    var vm: AddSpendingViewModel
    @ObservedObject
    var manager: SuggestionsOverlayManager

    @Binding
    var minimizeSuggestions: Bool

    let geometry: GeometryProxy
    
    @ScaledMetric(relativeTo: .footnote)
    private var buttonWidth: CGFloat = 100

    var padding: CGFloat {
        geometry.size.height - manager.placeFieldPosition + geometry.safeAreaInsets.top + (geometry.safeAreaInsets.bottom * 0.75) + (UIDevice.current.isIPhone ? 0 : 25)
    }

    private var suggestionsAnimation: Animation {
        if #available(iOS 26.0, *) {
            return .bouncy
        }
        
        return .snappy
    }

    var body: some View {
        VStack {
            Spacer()
            
            Group {
                if #available(iOS 26.0, *) {
                    VStack(alignment: .leading, spacing: 15) {
                        minimizeButton
                        
                        if !minimizeSuggestions {
                            VStack(alignment: .leading, spacing: 15) {
                                content
                                    .padding(.horizontal, 20)
                            }
                            .background(alignment: .leading) {
                                buttonsHitboxFix
                                    .padding(.vertical, -7.5)
                            }
                        }
                    }
                    .padding(.bottom, minimizeSuggestions ? 0 : 17)
                    .modifier(MenuBackgroundModifier(minimizeSuggestions: minimizeSuggestions))
                } else {
                    VStack(alignment: .leading, spacing: 7.5) {
                        minimizeButton
                        
                        if !minimizeSuggestions {
                            VStack(alignment: .leading, spacing: 7.5) {
                                content
                                    .padding(.vertical, 2)
                                    .padding(.horizontal, 20)
                            }
                            .background(alignment: .leading) {
                                buttonsHitboxFix
                                    .padding(.vertical, -3.75)
                            }
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .padding(.bottom, minimizeSuggestions ? 0 : 12)
                    .modifier(MenuBackgroundModifier(minimizeSuggestions: minimizeSuggestions))
                }
            }
            .padding(.vertical, 10)
            .offset(x: 0, y: -padding)
            .animation(.none, value: padding)
            .animation(suggestionsAnimation, value: vm.filteredSuggestions)
        }
    }
    
    private var content: some View {
        ForEach(vm.filteredSuggestions.reversed(), id: \.self) { suggestion in
            getSuggestionButton(value: suggestion.value)
                .id(suggestion.id)
                .transition(.blurWithOpacity.animation(suggestionsAnimation))
        }
    }
    
    private var buttonsHitboxFix: some View {
        var horizontalPadding: CGFloat {
            if #available(iOS 26.0, *) {
                return 40
            }
            
            return 30
        }
        
        return VStack(spacing: 0) {
            ForEach(vm.filteredSuggestions.reversed(), id: \.self) { suggestion in
                Button {
                    vm.place = suggestion.value
                    vm.selectedSuggestion = suggestion.value
                } label: {
                    Color.clear
                        .frame(minWidth: buttonWidth + horizontalPadding)
                }
                .id(suggestion.id)
                .transition(.blurWithOpacity.animation(suggestionsAnimation))
                .contentShape(.hoverEffect, RoundedRectangle(cornerRadius: Self.listCornerRadius))
                .hoverEffect()
            }
        }
    }

    private var minimizeButton: some View {
        var horizontalPadding: CGFloat {
            if #available(iOS 26.0, *) {
                return 20
            }
            
            return 15
        }
        
        var verticalPadding: CGFloat {
            if #available(iOS 26.0, *) {
                return 17
            }
            
            return 12
        }
        
        return Button {
            minimizeSuggestions.toggle()
        } label: {
            HStack {
                Text("Suggestions")
                
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(minimizeSuggestions ? 180 : 0))
            }
            .foregroundStyle(.secondary)
            .font(.footnote.bold())
            .padding(.horizontal, minimizeSuggestions ? 12 : horizontalPadding)
            .padding(.top, minimizeSuggestions ? 9 : verticalPadding)
            .padding(.bottom, minimizeSuggestions ? 9 : 0)
            .background {
                Color.black.opacity(0.001) // Hitbox fix
            }
        }
        .buttonStyle(.plain)
        .zIndex(2)
    }

    private func getSuggestionButton(value: String) -> some View {
        Button(value) {
            vm.place = value
            vm.selectedSuggestion = value
        }
        .buttonStyle(.plain)
        .lineLimit(1)
    }
}

fileprivate struct MenuBackgroundModifier: ViewModifier {
    let minimizeSuggestions: Bool
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .glassEffect(.regular.interactive(!minimizeSuggestions), in: RoundedRectangle(cornerRadius: 30))
                .padding()
        } else {
            content
                .background {
                    Rectangle()
                        .fill(Color(uiColor: .systemBackground))
                    
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(lineWidth: 1)
                        .fill(.primary.opacity(0.1))
                }
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding()
                .shadow(color: .black.opacity(0.25), radius: 5)
        }
    }
}
