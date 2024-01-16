//
//  CategoriesCoreDataModelTests.swift
//  financecontrolTests
//
//  Created by PinkXaciD on R 5/12/29.
//

import XCTest
@testable import financecontrol

final class CategoriesCoreDataModelTests: XCTestCase {

    var cdm: CoreDataModel? = nil
    var categoryNames: [String] = ["First", "Second", "Third", "Fourth", "Fifth"]
    var categoryColors: [String] = ["nord1", "nord2", "nord3", "nord4", "nord5"]
    
    override func setUp() {
        super.setUp()
        cdm = .init()
    }
    
    override func tearDown() {
        super.tearDown()
        
        guard
            let categories = cdm?.savedCategories,
            let shadowedCategories = cdm?.shadowedCategories
        else {
            return
        }
        
        for category in categories + shadowedCategories {
            cdm?.deleteCategory(category)
        }
        
        cdm = nil
    }
    
    func testAddCategoryAddsValueStress() {
        let count: Int = Int.random(in: 1..<20)
        var addedIds: [UUID] = []
        
        for _ in 0..<count {
            let catId = cdm?.addCategory(name: categoryNames.randomElement()!, color: categoryColors.randomElement()!)
            
            if let catId {
                addedIds.append(catId)
            }
        }
        
        guard let categories = cdm?.savedCategories else {
            XCTFail()
            return
        }
        
        let categoriesIds = categories.map { $0.id }
        
        XCTAssertEqual(count, categories.count)
        
        for id in addedIds {
            XCTAssertTrue(categoriesIds.contains(id))
        }
    }
    
    func testDeleteCategoryDeletesCategoryStress() {
        let count: Int = Int.random(in: 1..<20)
        
        for _ in 0..<count {
            let _ = cdm?.addCategory(name: categoryNames.randomElement()!, color: categoryColors.randomElement()!)
        }
        
        guard let categories = cdm?.savedCategories else {
            return
        }
        
        for category in categories {
            cdm?.deleteCategory(category)
        }
        
        XCTAssertEqual(cdm?.savedCategories.count, 0)
    }
    
    func testEditCategoryEditsCategoryStress() {
        let categoryNames2: [String] = ["Sixth", "Seventh", "Eighth", "Ninth", "Tenth"]
        let categoryColors2: [String] = ["nord6", "nord7", "nord8", "nord9", "nord91"]
        
        let count: Int = Int.random(in: 1..<20)
        
        for _ in 0..<count {
            let _ = cdm?.addCategory(name: categoryNames.randomElement()!, color: categoryColors.randomElement()!)
        }
        
        guard let categories = cdm?.savedCategories else {
            return
        }
        
        for category in categories {
            cdm?.editCategory(category, name: categoryNames2.randomElement()!, color: categoryColors2.randomElement()!)
        }
        
        guard let newCategories = cdm?.savedCategories else {
            XCTFail()
            return
        }
        
        for category in newCategories {
            XCTAssertTrue(categoryNames2.contains(category.name ?? ""))
            XCTAssertTrue(categoryColors2.contains(category.color ?? ""))
            XCTAssertFalse(categoryNames.contains(category.name ?? ""))
            XCTAssertFalse(categoryColors.contains(category.color ?? ""))
        }
    }
    
    func testFavoriteStateOfCategorySetsToFalseStress() {
        let count: Int = Int.random(in: 0..<20)
        
        for _ in 0..<count {
            let _ = cdm?.addCategory(name: categoryNames.randomElement()!, color: categoryColors.randomElement()!)
        }
        
        guard let categories = cdm?.savedCategories else {
            return
        }
        
        for category in categories {
            XCTAssertFalse(category.isFavorite)
        }
    }
    
    func testToggleFavoriteStateOfCategorySetsToTrueStress() {
        let count: Int = Int.random(in: 0..<20)
        
        for _ in 0..<count {
            let _ = cdm?.addCategory(name: categoryNames.randomElement()!, color: categoryColors.randomElement()!)
        }
        
        guard let categories = cdm?.savedCategories else {
            return
        }
        
        for category in categories {
            cdm?.changeFavoriteStateOfCategory(category)
        }
        
        guard let editedCategories = cdm?.savedCategories else {
            XCTFail("Deleted after changing favorite state")
            return
        }
        
        for category in editedCategories {
            XCTAssertTrue(category.isFavorite)
        }
    }
    
    func testShadowStateOfCategorySetsToFalseStress() {
        let count: Int = Int.random(in: 0..<20)
        
        for _ in 0..<count {
            let _ = cdm?.addCategory(name: categoryNames.randomElement()!, color: categoryColors.randomElement()!)
        }
        
        guard let categories = cdm?.savedCategories else {
            return
        }
        
        for category in categories {
            XCTAssertFalse(category.isShadowed)
        }
    }
    
    func testToggleShadowStateOfCategorySetsToTrueStress() {
        let count: Int = Int.random(in: 0..<20)
        
        for _ in 0..<count {
            let _ = cdm?.addCategory(name: categoryNames.randomElement()!, color: categoryColors.randomElement()!)
        }
        
        guard let categories = cdm?.savedCategories else {
            return
        }
        
        for category in categories {
            cdm?.changeShadowStateOfCategory(category)
        }
        
        XCTAssertEqual(cdm?.savedCategories.count, 0)
        XCTAssertEqual(cdm?.shadowedCategories.count, count)
        
        guard let editedCategories = cdm?.shadowedCategories else {
            XCTFail()
            return
        }
        
        for category in editedCategories {
            XCTAssertTrue(category.isShadowed)
        }
    }
    
    func testFindCategoryReturnsCategory() {
        let name = categoryNames.randomElement()!
        let color = categoryColors.randomElement()!
        
        let id = cdm?.addCategory(name: name, color: color)
        
        let fetchedCategory = cdm?.findCategory(id ?? .init())
        
        guard let category = fetchedCategory else {
            XCTFail("Returned nil")
            return
        }
        
        XCTAssertEqual(category.name, name)
        XCTAssertEqual(category.color, color)
        XCTAssertEqual(category.id, id)
    }

}
