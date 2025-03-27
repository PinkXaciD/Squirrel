//
//  ListHorizontalScrollView.swift
//  Squirrel
//
//  Created by PinkXaciD on 2025/03/25.
//

import SwiftUI

struct ListHorizontalScroll<Data, ID, Selection>: View where Data: RandomAccessCollection, Data.Element: ListHorizontalScrollRepresentable, ID: Hashable, Selection: Equatable {
    let data: Data
    let id: KeyPath<Data.Element, ID>
    let selectingValue: KeyPath<Data.Element, Selection>
    let animation: Animation
    let action: (Data.Element) -> Void
    
    @Binding
    var selection: Selection
    
    init(
        selection: Binding<Data.Element>,
        data: Data,
        id: KeyPath<Data.Element, ID>,
        animation: Animation = .linear(duration: 0),
        action: @escaping (Data.Element) -> Void = { (_) in }
    ) where Data.Element == Selection {
        self._selection = selection
        self.data = data
        self.id = id
        self.selectingValue = \Data.Element.self
        self.animation = animation
        self.action = action
    }
    
    init(
        selection: Binding<Data.Element>,
        data: Data,
        animation: Animation = .linear(duration: 0),
        action: @escaping (Data.Element) -> Void = { (_) in }
    ) where Data.Element: Identifiable, Data.Element.ID == ID, Data.Element == Selection {
        self._selection = selection
        self.data = data
        self.id = \.id
        self.selectingValue = \Data.Element.self
        self.animation = animation
        self.action = action
    }
    
    init(
        selection: Binding<Selection>,
        selectingValue: KeyPath<Data.Element, Selection>,
        data: Data,
        id: KeyPath<Data.Element, ID>,
        animation: Animation = .linear(duration: 0),
        action: @escaping (Data.Element) -> Void = { (_) in }
    ) {
        self._selection = selection
        self.data = data
        self.id = id
        self.selectingValue = selectingValue
        self.animation = animation
        self.action = action
    }
    
    init(
        selection: Binding<Selection>,
        selectingValue: KeyPath<Data.Element, Selection>,
        data: Data,
        animation: Animation = .linear(duration: 0),
        action: @escaping (Data.Element) -> Void = { (_) in }
    ) where Data.Element: Identifiable, Data.Element.ID == ID {
        self._selection = selection
        self.data = data
        self.id = \.id
        self.selectingValue = selectingValue
        self.animation = animation
        self.action = action
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(data, id: id) { element in
                    Button {
                        withAnimation(animation) {
                            selection = element[keyPath: selectingValue]
                        }
                        
                        action(element)
                    } label: {
                        var isSelected: Bool {
                            selection == element[keyPath: selectingValue]
                        }
                        
                        return element.label
                            .font(isSelected ? .body.bold() : .body)
                            .foregroundColor(isSelected ? Color(uiColor: .secondarySystemGroupedBackground) : element.foregroundColor)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(isSelected ? element.foregroundColor : Color(uiColor: .secondarySystemGroupedBackground))
                            }
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 0))
    }
}
