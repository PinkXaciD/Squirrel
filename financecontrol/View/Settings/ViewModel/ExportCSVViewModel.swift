//
//  ExportCSVViewModel.swift
//  Squirrel
//
//  Created by PinkXaciD on 2024/10/16.
//

import SwiftUI

final class ExportCSVViewModel: ViewModel {
    @Published
    var items: [Item]
    @Published
    var withReturns: Bool
    @Published
    var delimiter: Delimiter
    @Published
    var decimalSeparator: Separator
    @Published
    var groupingSeparator: Separator
    @Published
    var timeZoneFormat: TimeZone.Format
    @Published
    var selectedFieldsCount: Int
    @Published
    var isTimeZoneSelected: Bool
    
    let predicate: NSPredicate?
    let cdm: CoreDataModel
    
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
    
    enum Delimiter: CaseIterable, RawRepresentable {
        init?(rawValue: String) {
            switch rawValue {
            case ",":
                self = .comma
            case ";":
                self = .semicolon
            default:
                return nil
            }
        }
        
        case comma, semicolon
        
        var rawValue: String {
            switch self {
            case .comma:
                ","
            case .semicolon:
                ";"
            }
        }
        
        var displayDescription: String {
            switch self {
            case .comma:
                NSLocalizedString("Comma ( , )", comment: "")
            case .semicolon:
                NSLocalizedString("Semicolon ( ; )", comment: "")
            }
        }
    }
    
    enum Separator: CaseIterable, RawRepresentable {
        case comma, dot, space, none
        
        var rawValue: String {
            switch self {
            case .comma:
                ","
            case .dot:
                "."
            case .space:
                " "
            case .none:
                ""
            }
        }
        
        init?(rawValue: String) {
            switch rawValue {
            case ",":
                self = .comma
            case ".":
                self = .dot
            case " ":
                self = .space
            default:
                self = .none
            }
        }
        
        var displayDescription: String {
            switch self {
            case .comma:
                "Comma"
            case .dot:
                "Dot"
            case .space:
                "Space"
            case .none:
                "None"
            }
        }
    }
    
    init(cdm: CoreDataModel, predicate: NSPredicate? = nil) {
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
        self.delimiter = .comma
        self.decimalSeparator = .init(rawValue: Locale.autoupdatingCurrent.decimalSeparator ?? ",") ?? .comma
        self.groupingSeparator = .init(rawValue: Locale.autoupdatingCurrent.groupingSeparator ?? ".") ?? .dot
        self.timeZoneFormat = TimeZone.Format(rawValue: UserDefaults.standard.integer(forKey: UDKey.timeZoneFormat.rawValue))
        self.selectedFieldsCount = items.count(where: { $0.isActive })
        self.isTimeZoneSelected = false
        self.predicate = predicate
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
    
    func export(predicate: NSPredicate? = nil) -> URL? {
        do {
            return try cdm.exportCSV(
                items: items.filter({ $0.isActive }),
                delimiter: delimiter,
                decimalSeparator: decimalSeparator,
                groupingSeparator: groupingSeparator,
                withReturns: withReturns,
                timeZoneFormat: timeZoneFormat,
                predicate: predicate
            )
        } catch {
            ErrorType(error: error).publish()
            return nil
        }
    }
}
