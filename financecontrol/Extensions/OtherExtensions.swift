//
//  OtherExtensions.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/24.
//

import SwiftUI

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

extension TimeZone {
    func hoursFromGMT() -> Double {
        return Double(self.secondsFromGMT() / 3600)
    }
}
