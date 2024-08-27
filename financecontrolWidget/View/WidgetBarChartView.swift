//
//  WidgetBarChartView.swift
//  SquirrelWidgetExtension
//
//  Created by PinkXaciD on R 6/07/26.
//

import SwiftUI
import WidgetKit

struct WidgetBarChartView: View {
    @Environment(\.widgetFamily) private var widgetFamily
    @Environment(\.redactionReasons) private var redactionReasons
    
    @AppStorage(UDKeys.color.rawValue, store: UserDefaults(suiteName: Vars.groupName))
    private var tint: String = "Orange"
    
    let data: [Date:Double]
    let showWeekdays: Bool
    let isAccessory: Bool
    
    init(data: [Date : Double], showWeekdays: Bool = true, isAccessory: Bool = false) {
        self.data = data
        self.showWeekdays = showWeekdays
        self.isAccessory = isAccessory
    }
    
    var body: some View {
        GeometryReader { geometry in
            if redactionReasons.contains(.privacy) {
                privateChart(width: ((geometry.size.width - 10 * Double(data.count - 1)) / Double(data.count)), max: data.values.sorted(by: >).first ?? 1)
            } else {
                chart(width: ((geometry.size.width - 10 * Double(data.count - 1)) / Double(data.count)), max: data.values.sorted(by: >).first ?? 1)
            }
        }
    }
    
    private var isLarge: Bool {
        let largeWidgets: [WidgetFamily] = [.systemMedium, .systemLarge, .systemExtraLarge]
        return largeWidgets.contains(widgetFamily)
    }
    
    private func chart(width: CGFloat, max: Double) -> some View {
        VStack {
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    Line()
                        .stroke(style: StrokeStyle(lineWidth: (1), dash: [5]))
                        .frame(height: 1)
                        .offset(y: -countAverage(height: geometry.size.height, max: max))
                        .foregroundColor(.secondary.opacity(isAccessory ? 0.5 : 0.3))
                        .frame(width: width * 7 + 60)
                        .opacity(max == 0 ? 0 : 1)
                    
                    HStack(alignment: .bottom, spacing: 10) {
                        ForEach(generateData(geometry.size.height, max: max), id: \.key) { key, value in
                            ZStack(alignment: .bottom) {
                                RoundedRectangle(cornerRadius: isLarge ? 5 : 3)
                                    .frame(width: width, height: geometry.size.height)
                                    .foregroundColor(.secondary)
                                    .opacity(isAccessory ? 0.3 : 0.1)
                                    
                                
                                RoundedRectangle(cornerRadius: isLarge ? 5 : 3)
                                    .frame(width: width, height: value)
                                    .foregroundColor(colorIdentifier(color: tint))
                            }
                            .clipShape(RoundedRectangle(cornerRadius: isLarge ? 5 : 3))
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
            }
            
            if showWeekdays || isLarge {
                HStack(spacing: 10) {
                    ForEach(Array(data.keys).sorted(by: <), id: \.self) { key in
                        Text(key, format: .dateTime.weekday(.narrow))
                            .font(.system(size: isLarge ? 10 : 8))
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                            .frame(width: width)
                    }
                }
            }
        }
    }
    
    private func privateChart(width: CGFloat, max: Double) -> some View {
        let blankChartValues = [7,5,3,5,7,5,3]
        return VStack {
            GeometryReader { geometry in
                HStack(alignment: .bottom, spacing: 10) {
                    ForEach(blankChartValues.indices, id: \.self) { index in
                        let key = CGFloat(blankChartValues[index])
                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: isLarge ? 5 : 3)
                                .frame(width: width, height: geometry.size.height)
                                .foregroundColor(.secondary)
                                .opacity(isAccessory ? 0.3 : 0.1)
                            
                            RoundedRectangle(cornerRadius: isLarge ? 5 : 3)
                                .frame(width: width, height: geometry.size.height * key * 0.1 )
                                .foregroundColor(.secondary.opacity(0.3))
                        }
                        .clipShape(RoundedRectangle(cornerRadius: isLarge ? 5 : 3))
                    }
                }
                .frame(maxHeight: .infinity)
            }
            
            if showWeekdays || isLarge {
                HStack(spacing: 10) {
                    ForEach(0..<data.count, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 2)
                            .foregroundColor(.secondary.opacity(0.3))
                            .padding(.horizontal, width * 0.15)
                            .frame(width: width, height: 7)
                    }
                }
            }
        }
    }
    
    private func countAverage(height: CGFloat, max: Double) -> Double {
        let sum = data.values.reduce(0, +)
        let avg = sum / Double(data.count)
        return max == 0 ? 0 : (height / max) * avg
    }
    
    private func generateData(_ height: CGFloat, max: Double) -> [(key: Date, value: Double)] {
        var result = [(key: Date, value: Double)]()
        for key in data.keys.sorted(by: <) {
            let value = max == 0 ? 0 : (height / max * (data[key] ?? 1))
            result.append((key: key, value: value))
        }
        return result
    }
}
