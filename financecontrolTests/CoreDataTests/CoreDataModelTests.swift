//
//  CoreDataModelTests.swift
//  financecontrolTests
//
//  Created by PinkXaciD on R 5/12/28.
//

import XCTest
@testable import financecontrol

final class CoreDataModelTests: XCTestCase {
    
    var cdm: CoreDataModel? = nil
    
    override func setUp() {
        super.setUp()
        cdm = CoreDataModel()
    }
    
    override func tearDown() {
        super.tearDown()
        
        cdm = nil
    }

    func testInitSettingUpProperties() {
        if let currencies = cdm?.savedCurrencies, let currency = currencies.first {
            XCTAssertEqual(currency.tag, Locale.current.currencyCode)
        } else {
            XCTFail("Currency not setted up")
        }
        
        XCTAssertTrue(cdm?.savedSpendings == [])
        XCTAssertTrue(cdm?.savedCategories == [])
        XCTAssertTrue(cdm?.shadowedCategories == [])
    }

}
