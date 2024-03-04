//
//  SearchViewModel.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/03/05.
//

import Foundation

class SearchViewModel: ViewModel {
    @Published var search: String = ""
    
    init() {}
    
    func getPublisher() -> Published<String>.Publisher {
        return $search
    }
}
