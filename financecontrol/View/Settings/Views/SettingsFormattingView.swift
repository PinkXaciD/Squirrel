//
//  SettingsFormattingView.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/09/03.
//

import SwiftUI

struct SettingsFormattingView: View {
    @AppStorage(UDKeys.formatWithoutTimeZones.rawValue)
    private var formatWithoutTimeZones: Bool = false
    
    var body: some View {
        List {
            Section {
                Toggle("Always format without timezones", isOn: $formatWithoutTimeZones)
            } footer: {
                Text("If the time zone of the expense differs from the current one, the date will be formatted with the time zone of the expense. You can change this behavior by enabling this option.")
            }
            
//            Section {
//                Toggle("Always format in default currency", isOn: $testBool)
//            }
        }
        .navigationTitle("Formatting")
        .navigationBarTitleDisplayMode(.inline)
    }
}
