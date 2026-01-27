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

    var padding: CGFloat {
        geometry.size.height - manager.placeFieldPosition + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom
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
                            .padding(.horizontal, minimizeSuggestions ? 12 : 20)
                            .padding(.top, minimizeSuggestions ? 9 : 17)
                        
                        if !minimizeSuggestions {
                            content
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, minimizeSuggestions ? 9 : 17)
                    .modifier(MenuBackgroundModifier(minimizeSuggestions: minimizeSuggestions))
                } else {
                    VStack(alignment: .leading, spacing: 7.5) {
                        minimizeButton
                            .padding(.horizontal, minimizeSuggestions ? 12 : 15)
                            .padding(.top, minimizeSuggestions ? 9 : 12)
                        
                        if !minimizeSuggestions {
                            content
                                .padding(.vertical, 2)
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, minimizeSuggestions ? 9 : 12)
                    .modifier(MenuBackgroundModifier(minimizeSuggestions: minimizeSuggestions))
                }
            }
            .padding(.vertical, 10)
            .offset(x: 0, y: -padding)
            .animation(.none, value: padding)
            .animation(suggestionsAnimation, value: vm.filteredSuggestions.count)
        }
    }
    
    private var content: some View {
        ForEach(vm.filteredSuggestions.reversed(), id: \.self) { suggestion in
            getSuggestionButton(value: suggestion.value)
                .id(suggestion.id)
                .transition(.blurWithOpacity.animation(suggestionsAnimation))
        }
    }

    private var minimizeButton: some View {
        Button {
            minimizeSuggestions.toggle()
        } label: {
            HStack {
                Text("Suggestions")
                
                Label(minimizeSuggestions ? "Show" : "Hide", systemImage: "chevron.down")
                    .labelStyle(.iconOnly)
                    .rotationEffect(.degrees(minimizeSuggestions ? 180 : 0))
            }
            .foregroundStyle(.secondary)
            .font(.footnote.bold())
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
                    RoundedRectangle(cornerRadius: 15)
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
