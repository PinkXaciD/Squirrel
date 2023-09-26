//
//  Formatters.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/13.
//

import SwiftUI

private let currentCalendar = Calendar.current.identifier

func dateFormat(date: Date, time: Bool) -> String {
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        if time {
            dateFormatter.timeStyle = .short
        } else {
            dateFormatter.timeStyle = .none
        }
        dateFormatter.locale = Locale(languageCode: Locale.LanguageCode("en"), languageRegion: Locale.autoupdatingCurrent.region)
        dateFormatter.calendar = Calendar.autoupdatingCurrent
        return dateFormatter
    }()
    return dateFormatter.string(from: date)
}

func dateConvertFromString(_ date: String) -> Date {
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(languageCode: Locale.LanguageCode("en"), languageRegion: Locale.autoupdatingCurrent.region)
        return dateFormatter
    }()
    return dateFormatter.date(from: date) ?? Date.distantPast
}

func dateConvertFromDate(_ date: Date) -> String {
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(languageCode: Locale.LanguageCode("en"), languageRegion: Locale.autoupdatingCurrent.region)
        return dateFormatter
    }()
    return dateFormatter.string(from: date)
}

func dateFormatForBar(_ date: Date) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "y-M-d"
    return dateFormatter.date(from: dateFormatter.string(from: date)) ?? Date.distantFuture
}
 
/// Formats dates into the displayable form
/// - Parameter date: Date as Date
/// - Returns: Date as String (Month, Era (Optional) Year)
func dateFormatForSort(date: Date) -> String {
    var result: String = ""
    let dateFormatter = DateFormatter()
    let calendar = dateFormatter.calendar
    dateFormatter.locale = Locale(identifier: "en")
    
    let monthsWithFullName: [String] = dateFormatter.monthSymbols
    // ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"] in en locale
    
    let monthString = monthsWithFullName[(calendar?.component(.month, from: date) ?? 1)-1]
    
    switch currentCalendar {
        
    case Calendar.Identifier.japanese:
        let jpDateFormatter = DateFormatter()
        jpDateFormatter.locale = Locale.init(identifier: "en_JP")
        jpDateFormatter.calendar = Calendar(identifier: .japanese)

        jpDateFormatter.dateFormat = "G y"
        
        var year: String = ""
        let dateYear = jpDateFormatter.string(from: date)
        if dateYear != jpDateFormatter.string(from: Date.now) {
            year = "\(dateYear), "
        }
        
        result = year + monthString
        
    default:
        dateFormatter.dateFormat = "y"
        
        var year: String = ""
        let dateYear = dateFormatter.string(from: date)
        if dateYear != dateFormatter.string(from: Date.now) {
            year = "\(dateYear), "
        }
        
        result = year + monthString
    }
    return result
}

/// Converts a date to a comparable format
/// - Parameter str: Date as String
/// - Returns: Date as Date
func asDate(_ str: String) -> Date {
    let dateFormatter = DateFormatter()
    
    var result: Date = Date()
    
    switch currentCalendar {
        
    case Calendar.Identifier.japanese:
        dateFormatter.calendar = Calendar(identifier: .japanese)
        dateFormatter.dateFormat = "G y, M"
        let preResult = dateFormatter.date(from: str)
        if preResult == nil {
            dateFormatter.dateFormat = "G y"
            let withYear = dateFormatter.string(from: Date.now) + ", " + str
            dateFormatter.dateFormat = "G y, M"
            result = dateFormatter.date(from: withYear) ?? Date.distantPast
        } else {
            result = preResult ?? Date.distantPast
        }
        
    default:
        dateFormatter.calendar = Calendar.current
        dateFormatter.dateFormat = "y, M"
        let preResult = dateFormatter.date(from: str)
        if preResult == nil {
            dateFormatter.dateFormat = "y"
            let withYear = dateFormatter.string(from: Date.now) + ", " + str
            dateFormatter.dateFormat = "y, M"
            result = dateFormatter.date(from: withYear) ?? Date.distantPast
        } else {
            result = preResult ?? Date.distantPast
        }
    }
    
    return result
}

func lastWeekOperations(vm: CoreDataViewModel, currency: String) -> String {
    return (vm.operationsSumWeek()/(RatesViewModel().rates[currency] ?? 1))
        .formatted(.currency(code: currency))
}

func colorIdentifier(color: String) -> Color {
    switch color {
    case "Blue":
        return Color.blue
    case "Red":
        return Color.red
    case "Pink":
        return Color.pink
    case "Mint":
        return Color.mint
    case "Orange":
        return Color.orange
    case "Purple":
        return Color.purple
    case "Indigo":
        return Color.indigo
    case "Teal":
        return Color.teal
    default:
        return Color.accentColor
    }
}

func themeConvert(_ theme: String) -> ColorScheme? {
    switch theme {
    case "light":
        return ColorScheme.light
    case "dark":
        return ColorScheme.dark
    default:
        return nil
    }
}
