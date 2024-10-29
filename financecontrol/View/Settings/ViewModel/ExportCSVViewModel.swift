//
//  ExportCSVViewModel.swift
//  Squirrel
//
//  Created by PinkXaciD on 2024/10/16.
//

import SwiftUI

final class ExportCSVViewModel: ViewModel {
    @Published var items: [Item]
    @Published var withReturns: Bool
    @Published var dateFrom: Date
    @Published var dateTo: Date
    @Published var timeZoneFormat: TimeZoneFormat
    @Published var selectedFieldsCount: Int
    @Published var isTimeZoneSelected: Bool
    var cdm: CoreDataModel
    
    struct Item: Identifiable, Hashable {
        let name: String
        var isActive: Bool
        var id: String
        
        init(name: String, id: String, isActive: Bool = true) {
            self.name = name
            self.id = id
            self.isActive = isActive
        }
        
        mutating func toggleActiveStatus() {
            self.isActive.toggle()
        }
    }
    
    enum TimeZoneFormat: CaseIterable {
        case gmt, name, identifier
        
        var name: String {
            switch self {
            case .identifier:
                NSLocalizedString("timezone-identifier", comment: "Timezone identifier")
            case .gmt:
                NSLocalizedString("timezone-offset-from-gmt", comment: "Timezone ofset from GMT")
            case .name:
                NSLocalizedString("timezone-name", comment: "Timezone name")
            }
        }
        
        var example: String {
            switch self {
            case .identifier:
                TimeZone.autoupdatingCurrent.identifier
            case .gmt:
                Date().formatted(.dateTime.timeZone(.localizedGMT(.short)))
            case .name:
                TimeZone.autoupdatingCurrent.localizedName(for: .standard, locale: .autoupdatingCurrent) ?? "Error"
            }
        }
        
        func formatTimeZone(_ timeZone: TimeZone) -> String {
            switch self {
            case .identifier:
                return timeZone.identifier
            case .gmt:
                if timeZone.secondsFromGMT() != 0 {
                    return "GMT\(timeZone.hoursFromGMT().formatted(.number.sign(strategy: .always())))"
                }
                
                return "GMT"
            case .name:
                return timeZone.localizedName(for: .standard, locale: .autoupdatingCurrent) ?? timeZone.identifier
            }
        }
    }
    
    init(cdm: CoreDataModel) {
        let items = [
            Item(name: NSLocalizedString("Amount", comment: ""), id: "amount"),
            Item(name: NSLocalizedString("Currency", comment: ""), id: "currency"),
            Item(name: NSLocalizedString("Amount in USD", comment: ""), id: "amountUSD", isActive: false),
            Item(name: NSLocalizedString("Date", comment: ""), id: "date"),
            Item(name: NSLocalizedString("Timezone", comment: ""), id: "timezone", isActive: false),
            Item(name: NSLocalizedString("Category", comment: ""), id: "category"),
            Item(name: NSLocalizedString("Place", comment: ""), id: "place"),
            Item(name: NSLocalizedString("Comment", comment: ""), id: "comment")
        ]
        
        self.items = items
        self.cdm = cdm
        self.withReturns = true
        self.dateTo = Calendar.autoupdatingCurrent.startOfDay(for: Date())
        self.dateFrom = Calendar.autoupdatingCurrent.startOfDay(for: cdm.savedSpendings.last?.wrappedDate ?? .firstAvailableDate)
        self.timeZoneFormat = .gmt
        self.selectedFieldsCount = items.count(where: { $0.isActive })
        self.isTimeZoneSelected = false
    }
    
    func toggleItemActiveState(_ item: Item) {
        if let index = items.firstIndex(of: item) {
            withAnimation(.easeInOut.speed(2)) {
                items[index].toggleActiveStatus()
            }
            
            if items[index].isActive {
                selectedFieldsCount += 1
            } else {
                selectedFieldsCount -= 1
            }
            
            if item.id == "timezone" {
                withAnimation {
                    self.isTimeZoneSelected = !item.isActive
                }
            }
        }
    }
    
    func export() -> URL? {
        do {
            return try cdm.exportCSV(
                items: items.filter({ $0.isActive }),
                dateFrom: dateFrom,
                dateTo: Calendar.autoupdatingCurrent.date(byAdding: .day, value: 1, to: dateTo) ?? dateTo,
                withReturns: withReturns,
                timeZoneFormat: timeZoneFormat
            )
        } catch {
            ErrorType(error: error).publish()
            return nil
        }
    }
}
