//
//  SettingsFormattingView.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/09/03.
//

import SwiftUI

struct SettingsFormattingView: View {
    @EnvironmentObject
    private var cdm: CoreDataModel
    
    @AppStorage(UDKeys.formatWithoutTimeZones.rawValue)
    private var formatWithoutTimeZones: Bool = false
    
    @State
    private var isToggled: Bool = false
    
    var body: some View {
        List {
            Section {
                Toggle("Always format without timezones", isOn: $formatWithoutTimeZones)
            } footer: {
                Text("If the time zone of the expense differs from the current one, the date will be formatted with the time zone of the expense. You can change this behavior by enabling this option.")
            }
        }
        .navigationTitle("Formatting")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: formatWithoutTimeZones) { _ in
            if !isToggled {
                isToggled = true
            }
        }
        .onDisappear {
            if isToggled {
                cdm.fetchSpendings()
            }
        }
    }
}
