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
    
    @AppStorage(UDKey.formatWithoutTimeZones.rawValue)
    private var formatWithoutTimeZones: Bool = false
    @AppStorage("timeZoneFormat")
    private var timeZoneFormat: Int = 0
    
    @State
    private var isToggled: Bool = false
    
    var body: some View {
        List {
            Section {
                Toggle("Always Format Without Timezones", isOn: $formatWithoutTimeZones)
            } footer: {
                Text("format-without-timezones-description-key")
            }
            
            if !formatWithoutTimeZones {
                timeZoneFormatSection
            }
        }
        .navigationTitle("Formatting")
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
        .animation(.default, value: formatWithoutTimeZones)
    }
    
    private var timeZoneFormatSection: some View {
        Section {
            HStack {
                Text("Timezone Format")
                
                Menu {
                    Picker("Timezone format", selection: $timeZoneFormat) {
                        ForEach(TimeZone.Format.allCases, id: \.rawValue) { format in
                            Button {} label: {
                                if #available(iOS 16.0, *) {
                                    Text(format.localizedName)
                                    
                                    Text(TimeZone.autoupdatingCurrent.formatted(format))
                                } else {
                                    Text("\(format.localizedName)\n\(TimeZone.autoupdatingCurrent.formatted(format))")
                                }
                            }
                            .tag(format.rawValue)
                        }
                        .pickerStyle(.inline)
                    }
                } label: {
                    HStack {
                        Spacer()
                        
                        Text("\(TimeZone.Format(rawValue: timeZoneFormat).localizedName)")
                    }
                }
            }
        }
        .animation(.default.speed(2), value: timeZoneFormat)
    }
}
