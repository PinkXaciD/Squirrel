//
//  CustomContentUnavailableView.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/03/05.
//

import SwiftUI

struct CustomContentUnavailableView: View {
    let imageName: String
    let title: LocalizedStringKey
    let description: LocalizedStringKey?
    let showEffect: Bool
    let effectType: CustomSymbolEffect
    @State private var animation: Bool = false
    @ScaledMetric private var imageSize: CGFloat = 50
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .symbolRenderingMode(.monochrome)
                .availableSymbolEffect(value: animation, effect: effectType)
                .frame(height: imageSize)
                .foregroundColor(.secondary)
                .padding(15)
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            if let description {
                Text(description)
                    .foregroundColor(.secondary)
                    .font(.callout)
            }
        }
        .onAppear {
            animation.toggle()
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 30)
    }
    
    init(_ title: LocalizedStringKey, imageName: String = "questionmark", description: LocalizedStringKey? = nil, effect: CustomSymbolEffect = .none) {
        self.title = title
        self.imageName = imageName
        self.description = description
        self.showEffect = effect != .none
        self.effectType = effect
    }
}

extension CustomContentUnavailableView {
    static let search: Self = CustomContentUnavailableView("No results", imageName: "magnifyingglass", description: "Check the spelling or try a new search.")
    
    static func search(_ text: String) -> CustomContentUnavailableView {
        return CustomContentUnavailableView("No results for \"\(text.trimmingCharacters(in: .whitespacesAndNewlines))\"", imageName: "magnifyingglass", description: "Check the spelling or try a new search.")
    }
}

fileprivate extension View {
    @ViewBuilder
    func availableSymbolEffect<T: Equatable>(value: T, effect: CustomSymbolEffect = .none) -> some View {
        if #available(iOS 17, *) {
            switch effect {
            case .variableColor:
                self
                    .symbolEffect(.variableColor, options: .repeating, value: value)
            case .bounce:
                self
                    .symbolEffect(.bounce.byLayer, value: value)
            case .none:
                self
            }
        } else {
            self
        }
    }
}

enum CustomSymbolEffect {
    case variableColor, bounce, none
}

#if DEBUG
#Preview {
    CustomContentUnavailableView("Test", imageName: "archivebox.fill", description: "Description.", effect: .bounce)
}
#endif
