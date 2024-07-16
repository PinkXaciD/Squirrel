//
//  StatsViewModel.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/07/04.
//

import Foundation

final class StatsViewModel: ViewModel {
    @Published
    var entityToEdit: SpendingEntity? = nil
    @Published
    var entityToAddReturn: SpendingEntity? = nil
    @Published
    var edit: Bool = false
    
    init() {}
}
