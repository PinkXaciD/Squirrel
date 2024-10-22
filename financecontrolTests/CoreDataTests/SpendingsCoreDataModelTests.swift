//
//  SpendingsCoreDataModelTests.swift
//  financecontrolTests
//
//  Created by PinkXaciD on R 6/01/02.
//

import XCTest
import Combine
@testable import Squirrel

final class SpendingsCoreDataModelTests: XCTestCase {
    var cdm: CoreDataModel?
    var categoryId: UUID?

    override func setUp() {
        cdm = .init()
        categoryId = cdm?.addCategory(name: "Spendings tests", color: "nord1")?.id
    }

    override func tearDown() {
        guard let categories = cdm?.savedCategories else {
            fatalError()
        }
        
        for category in categories {
            cdm?.deleteCategory(category)
        }
        
        cdm = nil
        categoryId = nil
    }

    func testAddSpendingAddsSpending() {
        let amount: Double = Double.random(in: 0..<10000)
        let amountUSD: Double = Double.random(in: 0..<10000)
        let currency: String = ["USD", "EUR", "JPY"].randomElement()!
        let date: Date = .now
        let place: String = "Place"
        let comment: String = "Comment"
        
        let local = SpendingEntityLocal(
            amount: amount,
            amountUSD: amountUSD,
            currency: currency,
            date: date,
            place: place,
            categoryId: categoryId ?? .init(),
            comment: comment
        )
        
        cdm?.addSpending(spending: local)
        
        guard let spendings = cdm?.savedSpendings else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(spendings.count, 1)
        
        for spending in spendings {
            XCTAssertEqual(spending.category?.id, categoryId)
            XCTAssertEqual(spending.amount, amount)
            XCTAssertEqual(spending.amountUSD, amountUSD)
            XCTAssertEqual(spending.currency, currency)
            XCTAssertEqual(spending.wrappedCurrency, currency)
            XCTAssertEqual(spending.place, place)
            XCTAssertEqual(spending.comment, comment)
            XCTAssertEqual(spending.amountWithReturns, amount)
            XCTAssertEqual(spending.amountUSDWithReturns, amountUSD)
        }
    }
    
    func testEditSpendingEditsSpendings() {
        let expectation = XCTestExpectation(description: "Edit spending")
//        var cancellables = Set<AnyCancellable>()
        
//        func waitForChartDataUpdate() {
//            cdm?.$updateCharts
//                .dropFirst(2)
//                .sink { value in
//                    if value {
//                        expectation.fulfill()
//                    }
//                }
//                .store(in: &cancellables)
//        }
//        
//        waitForChartDataUpdate()
        
        let amount = Double.random(in: 0..<10000)
        let amountUSD = Double.random(in: 0..<10000)
        let currency: String = ["USD", "EUR", "JPY"].randomElement()!
        let date: Date = .distantPast
        let place: String = "Place"
        let comment: String = "Comment"
        
        let newAmount = Double.random(in: 0..<10000)
        let newAmountUSD = Double.random(in: 0..<10000)
        let newCurrency: String = ["CNY", "GBP", "VND"].randomElement()!
        let newDate: Date = .now
        let newPlace: String = "New place"
        let newComment: String = "New comment"
        
        let spending = SpendingEntityLocal(
            amount: amount,
            amountUSD: amountUSD,
            currency: currency,
            date: date,
            place: place,
            categoryId: categoryId ?? .init(),
            comment: comment
        )
        
        let newSpending = SpendingEntityLocal(
            amount: newAmount,
            amountUSD: newAmountUSD,
            currency: newCurrency,
            date: newDate,
            place: newPlace,
            categoryId: categoryId ?? .init(),
            comment: newComment
        )
        
        cdm?.addSpending(spending: spending)
        
        guard let spendings = cdm?.savedSpendings else {
            XCTFail()
            return
        }
        
        for spending in spendings {
            cdm?.editSpending(spending: spending, newSpending: newSpending)
        }
        
        wait(for: [expectation], timeout: 5)
        
        guard let newSpendings = cdm?.savedSpendings else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(newSpendings.count, 1)
        
        for spending in newSpendings {
            XCTAssertEqual(spending.amount, newAmount, accuracy: 0.01)
            XCTAssertEqual(spending.amountUSD, newAmountUSD, accuracy: 0.01)
            XCTAssertEqual(spending.currency, newCurrency)
            XCTAssertEqual(spending.date, newDate)
            XCTAssertEqual(spending.place, newPlace)
            XCTAssertEqual(spending.comment, newComment)
            XCTAssertNotEqual(spending.amount, amount, accuracy: 0.01)
            XCTAssertNotEqual(spending.amountUSD, amountUSD, accuracy: 0.01)
            XCTAssertNotEqual(spending.currency, currency)
            XCTAssertNotEqual(spending.date, date)
            XCTAssertNotEqual(spending.place, place)
            XCTAssertNotEqual(spending.comment, comment)
        }
    }

    func testDeleteSpendingRemovesSpeningsStress() {
        for _ in 0..<20 {
            let local = SpendingEntityLocal(
                amount: Double.random(in: 0..<10000),
                amountUSD: Double.random(in: 0..<10000),
                currency: ["USD", "EUR", "JPY"].randomElement()!,
                date: .now,
                place: "Place",
                categoryId: categoryId ?? .init(),
                comment: "Comment"
            )
            
            cdm?.addSpending(spending: local)
        }
        
        guard let spendings = cdm?.savedSpendings else {
            XCTFail()
            return
        }
        
        for spending in spendings {
            cdm?.deleteSpending(spending)
        }
        
        XCTAssertEqual(cdm?.savedSpendings.count, 0)
    }
    
    func testOperationSumCounts() {
        var sum: [Double] = []
        
        for _ in 0..<20 {
            let random = Double.random(in: 0..<10000)
            sum.append(random)
            
            let local = SpendingEntityLocal(
                amount: random,
                amountUSD: random,
                currency: ["USD", "EUR", "JPY"].randomElement()!,
                date: .now,
                place: "Place",
                categoryId: categoryId ?? .init(),
                comment: "Comment"
            )
            
            cdm?.addSpending(spending: local)
        }
        
        XCTAssertEqual(cdm!.operationsSum(), sum.reduce(0, +), accuracy: 0.01)
    }
    
    func testOperationsForListReturnsRightValue() {
        func dateFormat(_ date: Date) -> String {
            if Calendar.current.isDateInToday(date) {
                return NSLocalizedString("Today", comment: "")
            } else if Calendar.current.isDate(date, inSameDayAs: .now.previousDay) {
                return NSLocalizedString("Yesterday", comment: "")
            } else {
                let dateFormatter: DateFormatter = .init()
                dateFormatter.dateStyle = .long
                dateFormatter.timeStyle = .none
                
                return dateFormatter.string(from: date)
            }
        }
        
        for index in 0..<8 {
            let local = SpendingEntityLocal(
                amount: Double.random(in: 0..<10000),
                amountUSD: Double.random(in: 0..<10000),
                currency: ["USD", "EUR", "JPY"].randomElement()!,
                date: Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: -index, to: .now)!),
                place: "Place",
                categoryId: categoryId ?? .init(),
                comment: "Comment"
            )
            
            cdm?.addSpending(spending: local)
        }
        
        let data = cdm?.statsListData
        
        for index in 0..<8 {
            let key = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: -index, to: .now)!)
            
            let element = data?[key]
            
            XCTAssertNotNil(element)
            XCTAssertEqual(element?.count, 1)
        }
    }
    
}
