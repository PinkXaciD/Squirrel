//
//  OtherExtensions.swift
//  Squirrel
//
//  Created by PinkXaciD on 2022/08/24.
//

import SwiftUI
import Combine

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    
    static let mainIdentifier: String = Bundle.main.bundleIdentifier ?? "dev.squirrelapp.squirrel"
    
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }
}

extension CodingUserInfoKey {
    static let moc = CodingUserInfoKey(rawValue: "managedObjectContext")!
}

extension UIDevice {
    var isIPad: Bool {
        self.userInterfaceIdiom == .pad
    }
    
    var isIPhone: Bool {
        self.userInterfaceIdiom == .phone
    }
}

extension UIApplication {
    var keyWindow: UIWindow? {
        return self.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
      }
}

extension Calendar {
    static let gmt: Calendar = {
        var calendar: Calendar = .init(identifier: .gregorian)
        calendar.locale = .current
        var timeZone: TimeZone {
            if #available(iOS 16.0, *) {
                return .gmt
            }
            
            return .init(secondsFromGMT: 0) ?? .current
        }
        calendar.timeZone = timeZone
        return calendar
    }()
}

extension TimeInterval {
    static let hour: Self = 3600
    
    static let day: Self = 86_400
}

extension DateFormatter {
    static let forRatesTimestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .init(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

extension NumberFormatter {
    static let standard = NumberFormatter()
    
    static var currency: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.decimalSeparator = Locale.current.decimalSeparator ?? "."
        return formatter
    }
}

extension NSNotification.Name {
    static let UpdatePieChart = NSNotification.Name("UpdatePieChart")
}

extension Set<AnyCancellable> {
    func cancelAll() {
        for item in self {
            item.cancel()
        }
    }
}

extension String {
    func normalize() -> String {
        return self.lowercased().folding(options: .diacriticInsensitive, locale: .autoupdatingCurrent)
    }
}
