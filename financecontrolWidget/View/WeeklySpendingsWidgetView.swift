//
//  WeeklySpendingsWidgetView.swift
//  SquirrelWidgetExtension
//
//  Created by PinkXaciD on R 6/07/26.
//

import SwiftUI
import WidgetKit

struct WeeklySpendingsWidgetView: View {
    @Environment(\.widgetFamily) private var widgetFamily
    
    let entry: WeeklySpendingsWidgetEntry
    var numberFormat: FloatingPointFormatStyle<Double> {
        if entry.todaySum > 99999 {
            return .number.notation(.compactName)
        }
        
        return .number.precision(.fractionLength(0...2))
    }
    
    var body: some View {
        if #available(iOS 17.0, *) {
            getNewWidget()
                .accentColor(.orange)
        } else {
            getOldWidget()
                .accentColor(.orange)
        }
    }
    
    @available(iOS 17, *)
    private func getNewWidget() -> some View {
        constructWidget()
            .containerBackground(.background, for: .widget)
    }
    
    private func getOldWidget() -> some View {
        ZStack {
            ContainerRelativeShape()
                .foregroundStyle(.background)
            
            constructWidget()
                .padding()
        }
    }
    
    private func constructWidget() -> some View {
        GeometryReader { geometry in
            switch widgetFamily {
            case .systemMedium:
                HStack(spacing: 20) {
                    WidgetBarChartView(data: entry.data, showWeekdays: true)
                    
                    WeeklySpendingsMediumTodaySumView(sum: entry.todaySum, avg: entry.data.values.reduce(0, +)/7, currency: entry.currency)
                        .frame(width: geometry.size.width / 3)
                }
            default:
                VStack(alignment: .leading) {
                    WeeklySpendingsSmallTodaySumView(currency: entry.currency, sum: entry.todaySum)
                    
                    WidgetBarChartView(data: entry.data, showWeekdays: true)
                }
            }
        }
    }
}

@available(iOS 16.0, *)
struct WeeklySpendingsAccessoryWidgetView: View {
    
    let entry: WeeklySpendingsWidgetEntry
    
    var body: some View {
        if #available(iOS 17.0, *) {
            getNewWidget()
        } else {
            getOldWidget()
        }
    }
    
    @available(iOS 17, *)
    private func getNewWidget() -> some View {
        VStack {
            WidgetBarChartView(data: entry.data, showWeekdays: false, isAccessory: true)
                .accentColor(.primary)
            
            HStack(alignment: .bottom, spacing: 0) {
                Text("Today: ")
                    .font(.footnote)
                
                Text(entry.todaySum.formatted(.currency(code: entry.currency).precision(.fractionLength(0))))
                    .font(.system(.footnote, design: .rounded).bold())
                
                Spacer()
            }
            .privacySensitive()
        }
        .containerBackground(.background, for: .widget)
    }
    
    private func getOldWidget() -> some View {
        VStack {
            WidgetBarChartView(data: entry.data, showWeekdays: false, isAccessory: true)
                .accentColor(.primary)
            
            HStack(alignment: .bottom, spacing: 0) {
                Text("Today: ")
                    .font(.footnote)
                
                Text(entry.todaySum.formatted(.currency(code: entry.currency).precision(.fractionLength(0))))
                    .font(.system(.footnote, design: .rounded).bold())
                
                Spacer()
            }
            .privacySensitive()
        }
    }
}

struct WeeklySpendingsWidgetPreview: PreviewProvider {
    static private let templateData: [Date:Double] = [
        Calendar.current.startOfDay(for: Date()):1100,
        Calendar.current.startOfDay(for: Date().addingTimeInterval(60*60*24)):600,
        Calendar.current.startOfDay(for: Date().addingTimeInterval((60*60*24)*2)):200,
        Calendar.current.startOfDay(for: Date().addingTimeInterval((60*60*24)*3)):900,
        Calendar.current.startOfDay(for: Date().addingTimeInterval((60*60*24)*4)):1200,
        Calendar.current.startOfDay(for: Date().addingTimeInterval((60*60*24)*5)):300,
        Calendar.current.startOfDay(for: Date().addingTimeInterval((60*60*24)*6)):800
    ]
    
    static var previews: some View {
        WeeklySpendingsWidgetView(
            entry: .init(
                date: Date(),
                data: templateData,
                currency: "AMD"
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        WeeklySpendingsWidgetView(
            entry: .init(
                date: Date(),
                data: templateData,
                currency: "AMD"
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemMedium))
        
        if #available(iOSApplicationExtension 16.0, *) {
            WeeklySpendingsAccessoryWidgetView(
                entry: .init(
                    date: Date(),
                    data: templateData,
                    currency: "AMD"
                )
            )
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
        }
    }
}
