//
//  SpendingViewModelProtocol.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/11/23.
//

import Foundation

protocol SpendingViewModel: ViewModel {
    var cdm: CoreDataModel { get }
    var rvm: RatesViewModel { get }
    
    var amount: String { get }
    var currency: String { get }
    var date: Date { get }
    var categoryName: String { get }
    var categoryId: UUID { get }
    var place: String { get }
    var comment: String { get }
    
    func done()
}
