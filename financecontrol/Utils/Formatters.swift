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
