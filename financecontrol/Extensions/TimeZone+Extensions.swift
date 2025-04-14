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
    }
    
    func formatted(_ style: Self.Format) -> String {
        switch style {
        case .gmt:
            var formatStyle = Date.FormatStyle()
            formatStyle.timeZone = self
            return Date().formatted(formatStyle.timeZone(.localizedGMT(.short)))
        case .name:
            return self.localizedName(for: .standard, locale: .autoupdatingCurrent) ?? "Error"
        case .location:
            var formatStyle = Date.FormatStyle()
            formatStyle.timeZone = self
            return Date().formatted(formatStyle.timeZone(.exemplarLocation))
        }
    }
}

extension TimeZone {
    func hoursFromGMT() -> Double {
        return Double(self.secondsFromGMT() / 3600)
    }
}

/*
 var name: String {
     switch self {
     case .identifier:
         String(localized: "timezone-identifier", comment: "Timezone identifier")
     case .gmt:
         String(localized: "timezone-offset-from-gmt", comment: "Timezone ofset from GMT")
     case .name:
         String(localized: "timezone-name", comment: "Timezone name")
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
 */
