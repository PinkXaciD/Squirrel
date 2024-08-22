//
//  SearchViewModel.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/03/05.
//

import SwiftUI
import Combine

class SearchViewModel: ViewModel {
    @Published var search: String = ""
    @Published var input: String = ""
    var cancellables = Set<AnyCancellable>()
    
    init() {
        updateSearch()
    }
    
    deinit {
        cancellables.cancelAll()
    }
    
    func getPublisher() -> Published<String>.Publisher {
        return $search
    }
    
    func updateSearch() {
        self.$input
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] value in
                withAnimation {
                    self?.search = value
                }
            }
            .store(in: &cancellables)
    }
}
