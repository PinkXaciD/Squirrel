//
//  TemplateData.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/07/03.
//

import Foundation

extension CoreDataModel {
    func addTemplateData() {
        context.perform { [weak self] in
            guard let self else { return }
            
            let restaurantsID = addCategory(name: "Restaurants", color: "nord1")
            let groceriesID = addCategory(name: "Groceries", color: "nord4")
            let subscriptionsID = addCategory(name: "Subscriptions", color: "nord6")
            let transportID = addCategory(name: "Transport", color: "nord94")
            let travelID = addCategory(name: "Travel", color: "nord7")
            
            let components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            
            func getDate(days: Int) -> Date {
                var localComponents = components
                localComponents.calendar = .current
                localComponents.day = (localComponents.day ?? 1) - days
                localComponents.hour = (8...23).randomElement() ?? 6
                localComponents.minute = (0..<60).randomElement() ?? 24
                return localComponents.date ?? Date()
            }
            
            let restaurantsSpendings: [SpendingEntityLocal] = [
                .init(amount: 15, amountUSD: 15, currency: "USD", date: getDate(days: 5), place: "McDonald's", categoryId: restaurantsID, comment: ""),
                .init(amount: 10, amountUSD: 10, currency: "USD", date: getDate(days: 7), place: "KFC", categoryId: restaurantsID, comment: ""),
                .init(amount: 12, amountUSD: 12, currency: "USD", date: getDate(days: 12), place: "Some Restaurant", categoryId: restaurantsID, comment: ""),
                .init(amount: 9, amountUSD: 9, currency: "USD", date: getDate(days: 13), place: "McDonald's", categoryId: restaurantsID, comment: ""),
                .init(amount: 22, amountUSD: 22, currency: "USD", date: getDate(days: 28), place: "Some Restaurant", categoryId: restaurantsID, comment: ""),
                .init(amount: 15, amountUSD: 15, currency: "USD", date: getDate(days: 37), place: "Dominos", categoryId: restaurantsID, comment: "")
            ]
            
            let groceriesSpendings: [SpendingEntityLocal] = [
                .init(amount: 1500, amountUSD: 10, currency: "JPY", date: Date(), place: "7 Eleven", categoryId: groceriesID, comment: ""),
                .init(amount: 3.90, amountUSD: 3.90, currency: "USD", date: getDate(days: 5), place: "7 Eleven", categoryId: groceriesID, comment: ""),
                .init(amount: 25, amountUSD: 25, currency: "USD", date: getDate(days: 12), place: "Costco", categoryId: groceriesID, comment: ""),
                .init(amount: 2.50, amountUSD: 2.50, currency: "USD", date: getDate(days: 20), place: "Walmart", categoryId: groceriesID, comment: ""),
                .init(amount: 18, amountUSD: 18, currency: "USD", date: getDate(days: 23), place: "Walmart", categoryId: groceriesID, comment: ""),
                .init(amount: 1.99, amountUSD: 1.99, currency: "USD", date: getDate(days: 28), place: "7 Eleven", categoryId: groceriesID, comment: ""),
                .init(amount: 16, amountUSD: 16, currency: "USD", date: getDate(days: 35), place: "", categoryId: groceriesID, comment: ""),
                .init(amount: 35, amountUSD: 35, currency: "USD", date: getDate(days: 44), place: "Target", categoryId: groceriesID, comment: ""),
                .init(amount: 12, amountUSD: 12, currency: "USD", date: getDate(days: 51), place: "", categoryId: groceriesID, comment: ""),
                .init(amount: 7.70, amountUSD: 7.70, currency: "USD", date: getDate(days: 60), place: "7 Eleven", categoryId: groceriesID, comment: ""),
            ]
            
            let subscriptionsSpendings: [SpendingEntityLocal] = [
                .init(amount: 9.99, amountUSD: 9.99, currency: "USD", date: getDate(days: 1), place: "Apple Music", categoryId: subscriptionsID, comment: ""),
                .init(amount: 2.99, amountUSD: 2.99, currency: "USD", date: getDate(days: 11), place: "iCloud Plus", categoryId: subscriptionsID, comment: ""),
                .init(amount: 20, amountUSD: 20, currency: "USD", date: getDate(days: 2), place: "Mobile network", categoryId: subscriptionsID, comment: ""),
                .init(amount: 9.99, amountUSD: 9.99, currency: "USD", date: getDate(days: 31), place: "Apple Music", categoryId: subscriptionsID, comment: ""),
                .init(amount: 2.99, amountUSD: 2.99, currency: "USD", date: getDate(days: 42), place: "iCloud Plus", categoryId: subscriptionsID, comment: ""),
                .init(amount: 20, amountUSD: 20, currency: "USD", date: getDate(days: 33), place: "Mobile network", categoryId: subscriptionsID, comment: ""),
                .init(amount: 9.99, amountUSD: 9.99, currency: "USD", date: getDate(days: 62), place: "Apple Music", categoryId: subscriptionsID, comment: ""),
                .init(amount: 2.99, amountUSD: 2.99, currency: "USD", date: getDate(days: 72), place: "iCloud Plus", categoryId: subscriptionsID, comment: ""),
                .init(amount: 20, amountUSD: 20, currency: "USD", date: getDate(days: 64), place: "Mobile network", categoryId: subscriptionsID, comment: ""),
            ]
            
            let transportSpendings: [SpendingEntityLocal] = [
                .init(amount: 1000, amountUSD: 6.30, currency: "JPY", date: getDate(days: 1), place: "Taxi", categoryId: transportID, comment: ""),
                .init(amount: 2.90, amountUSD: 2.90, currency: "USD", date: getDate(days: 4), place: "Subway", categoryId: transportID, comment: ""),
                .init(amount: 1.90, amountUSD: 1.90, currency: "USD", date: getDate(days: 10), place: "Bus", categoryId: transportID, comment: ""),
                .init(amount: 2.90, amountUSD: 2.90, currency: "USD", date: getDate(days: 20), place: "Subway", categoryId: transportID, comment: ""),
                .init(amount: 1.90, amountUSD: 1.90, currency: "USD", date: getDate(days: 25), place: "Bus", categoryId: transportID, comment: ""),
                .init(amount: 1.90, amountUSD: 1.90, currency: "USD", date: getDate(days: 32), place: "Bus", categoryId: transportID, comment: ""),
                .init(amount: 2.90, amountUSD: 2.90, currency: "USD", date: getDate(days: 41), place: "Subway", categoryId: transportID, comment: ""),
                .init(amount: 2.90, amountUSD: 2.90, currency: "USD", date: getDate(days: 50), place: "Subway", categoryId: transportID, comment: ""),
            ]
            
            let travelSpendings: [SpendingEntityLocal] = [
                .init(amount: 39500, amountUSD: 150, currency: "JPY", date: getDate(days: 9), place: "Plane tickets", categoryId: travelID, comment: ""),
                .init(amount: 130, amountUSD: 130, currency: "USD", date: getDate(days: 78), place: "Train tickets", categoryId: travelID, comment: "")
            ]
            
            for spending in restaurantsSpendings {
                addSpending(spending: spending, playHaptic: false)
            }
            
            for spending in groceriesSpendings {
                addSpending(spending: spending, playHaptic: false)
            }
            
            for spending in subscriptionsSpendings {
                addSpending(spending: spending, playHaptic: false)
            }
            
            for spending in transportSpendings {
                addSpending(spending: spending, playHaptic: false)
            }
            
            for spending in travelSpendings {
                addSpending(spending: spending, playHaptic: false)
            }
        }
        
        HapticManager.shared.notification(.success)
    }
}
