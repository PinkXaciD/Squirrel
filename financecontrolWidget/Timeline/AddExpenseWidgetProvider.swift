//
//  AddExpenseWidgetProvider.swift
//  financecontrolWidgetExtension
//
//  Created by PinkXaciD on R 6/01/13.
//

import WidgetKit
import SwiftUI
#if DEBUG
import OSLog
#endif

struct AddExpenseWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> AddExpenseEntry {
        AddExpenseEntry(date: Date(), image: { Image(.squirrelLogo) }, url: .addExpenseAction)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (AddExpenseEntry) -> Void) {
        let entry = AddExpenseEntry(date: Date(), image: { Image(.squirrelLogo) }, url: .addExpenseAction)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<AddExpenseEntry>) -> Void) {
        var entries: [AddExpenseEntry] = []
        #if DEBUG
        let logger: Logger = .init(subsystem: Vars.widgetIdentifier, category: "Add expense timeline")
        #endif
        
        for _ in 0..<2 {
            let entryDate = Calendar.current.startOfDay(for: .init())
            let entryImage = Image(.squirrelLogo)
            let entryURL = URL.addExpenseAction
            let entry = AddExpenseEntry(date: entryDate, image: { entryImage }, url: entryURL)
            entries.append(entry)
            #if DEBUG
            logger.debug("Generating entry... Date: \(entryDate), image name: \("squirrelLogo"), URL: \(entryURL?.absoluteString ?? "No URL")")
            #endif
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
