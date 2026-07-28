//
//  TimeZone+Extensions.swift
//  Squirrel
//
//  Created by PinkXaciD on 2025/01/17.
//

import Foundation

extension TimeZone {
    enum Format: RawRepresentable, CaseIterable {
        case gmt, name, location
        
        var rawValue: Int {
            switch self {
            case .gmt:
                0
            case .name:
                1
            case .location:
                2
            }
        }
        
        init(rawValue: Int) {
            switch rawValue {
            case 0:
                self = .gmt
            case 1:
                self = .name
            default:
                self = .location
            }
        }
        
        var localizedName: String {
            switch self {
            case .gmt:
                String(localized: "timezone-offset-from-gmt", comment: "Timezone ofset from GMT")
            case .name:
                String(localized: "timezone-name", comment: "Timezone name")
            case .location:
                String(localized: "timezone-location", comment: "Timezone location")
            }
        }
        
        var formatStyle: Date.FormatStyle.Symbol.TimeZone {
            switch self {
            case .gmt:
                    .localizedGMT(.short)
            case .name:
                    .specificName(.long)
            case .location:
                    .genericLocation
            }
        }
    }
    
    func formatted(_ style: Self.Format, for date: Date = Date()) -> String {
        var formatStyle = Date.FormatStyle()
        formatStyle.timeZone = self
        
        return date.formatted(formatStyle.timeZone(style.formatStyle))
    }
    
    func getImage() -> String {
        if #available(iOS 16.0, *) {
            let offset = self.hoursFromGMT()
            
            switch offset {
            case ...(-3):
                return "globe.americas.fill"
            case ...3:
                return "globe.europe.africa.fill"
            case ...7:
                return "globe.central.south.asia.fill"
            default:
                return "globe.asia.australia.fill"
            }
        } else {
            return "clock.fill"
        }
    }
}

extension TimeZone {
    func hoursFromGMT() -> Double {
        return Double(self.secondsFromGMT() / 3600)
    }
}

extension TimeZone: @retroactive Comparable {
    public static func < (lhs: TimeZone, rhs: TimeZone) -> Bool {
        lhs.formatted(.name) < rhs.formatted(.name)
    }
}
