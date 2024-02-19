//
//  AddExpenseWidgetProvider.swift
//  financecontrolWidgetExtension
//
//  Created by PinkXaciD on R 6/01/13.
//

import WidgetKit
import SwiftUI
import OSLog

struct AddExpenseWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> AddExpenseEntry {
        AddExpenseEntry(date: Date(), image: { Image(.squirrelLogo) }, url: URLs.addExpenseAction)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (AddExpenseEntry) -> Void) {
        let entry = AddExpenseEntry(date: Date(), image: { Image(.squirrelLogo) }, url: URLs.addExpenseAction)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<AddExpenseEntry>) -> Void) {
        var entries: [AddExpenseEntry] = []
        let logger: Logger = .init(subsystem: Vars.widgetIdentifier, category: "Add expence timeline")
        
        for _ in 0..<2 {
            let entryDate = Calendar.current.startOfDay(for: .init())
            let entryImage = Image(.squirrelLogo)
            let entryURL = URLs.addExpenseAction
            let entry = AddExpenseEntry(date: entryDate, image: { entryImage }, url: entryURL)
            entries.append(entry)
            logger.debug("Generating entry... Date: \(entryDate), image name: \("squirrelLogo"), URL: \(entryURL?.absoluteString ?? "No URL")")
        }
        
        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
}

struct AddExpenseEntry: TimelineEntry {
    let date: Date
    let image: () -> Image
    let url: URL!
}
