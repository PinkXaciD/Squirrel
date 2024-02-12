//
//  RatesViewModelTests.swift
//  financecontrolTests
//
//  Created by PinkXaciD on R 5/12/28.
//

import XCTest
@testable import Squirrel

final class FallbackRatesTests: XCTestCase {
    
    var isoDateFormatter: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFallbackRatesTimestampParsing() {
        let fallbackDate = isoDateFormatter.date(from: Rates.fallback.timestamp)
        
        XCTAssertNotNil(fallbackDate)
    }
    
    func testFallbackRatesIsUpToDate() {
        let fallbackDate = isoDateFormatter.date(from: Rates.fallback.timestamp)!
        let minimalAcceptDate = Calendar.current.date(byAdding: .day, value: -7, to: .now)!
        
        XCTAssertLessThan(minimalAcceptDate, fallbackDate)
    }
    
    func testFallbackRatesHasAllValues() {
        let fallbackCurrencies = Rates.fallback.rates.keys
        var requiredCurrencies = Locale.customActualCommonISOCurrencyCodes
        
        for code in fallbackCurrencies {
            let index = requiredCurrencies.firstIndex(of: code)
            
            XCTAssertNotNil(index, code)
            
            if let index {
                requiredCurrencies.remove(at: index)
            }
        }
        
        XCTAssertTrue(requiredCurrencies.isEmpty, requiredCurrencies.description)
    }

}
