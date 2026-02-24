//
//  SuggestionsOverlayManager.swift
//  Squirrel
//
//  Created by PinkXaciD on 2026/01/27.
//

import Foundation

final class SuggestionsOverlayManager: ObservableObject {
    @Published
    var placeFieldPosition: CGFloat
    
    init() {
        self.placeFieldPosition = 0
    }
}
