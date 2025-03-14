//
//  StatsRowViewModel.swift
//  Squirrel
//
//  Created by PinkXaciD on 2025/02/19.
//

import Foundation

final class StatsRowViewModel: ViewModel {
    @Published
    var hOffset: CGFloat = 0
    @Published
    var showLeadingButtons: UUID? = nil
    @Published
    var showTrailingButtons: UUID? = nil
    @Published
    var triggerLeadingAction: UUID? = nil
    @Published
    var triggerTrailingAction: UUID? = nil
    @Published
    var lastDragged: UUID? = nil
    
    init() {}
}
