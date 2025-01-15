//
//  StatsRow.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/24.
//

import SwiftUI

#if DEBUG
import OSLog
#endif

struct StatsRow: View {
    @Environment(\.managedObjectContext)
    private var viewContext
    @EnvironmentObject
    private var rvm: RatesViewModel
    @EnvironmentObject
    private var vm: StatsViewModel
    
    @AppStorage(UDKey.formatWithoutTimeZones.rawValue)
    private var formatWithoutTimeZones: Bool = false
    
    let entity: SpendingEntity
    
    #if DEBUG
    let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
    #endif
    
    var body: some View {
        button
    }
    
    // MARK: Variables
    private var button: some View {
        return Button(action: buttonAction) {
            buttonLabel
        }
        .normalizePadding()
        .swipeActions(edge: .trailing) {
            deleteButton
            
            returnButon
        }
        .swipeActions(edge: .leading) {
            editButton
        }
        .contextMenu {
            editButton
            
            returnButon
            
            deleteButton
        }
    }
    
    private var buttonLabel: some View {
        return HStack {
            VStack(alignment: .leading, spacing: 5) {
                if let place = entity.place, !place.isEmpty {
                    Text(entity.categoryName)
                        .font(.caption)
                        .foregroundColor(Color.secondary)
                    
                    Text(place)
                        .foregroundColor(.primary)
                } else {
                    Text(entity.categoryName)
                        .foregroundColor(.primary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 5) {
                HStack(spacing: 3) {
                    if !formatWithoutTimeZones, let timeZone = TimeZone(identifier: entity.timeZoneIdentifier ?? ""), timeZone.secondsFromGMT() != TimeZone.autoupdatingCurrent.secondsFromGMT() {
                        Image(systemName: "clock")
                            .foregroundColor(.secondary)
                            .font(.caption2)
                        
                        Text(entity.dateAdjustedToTimeZoneDate.formatted(date: .omitted, time: .shortened))
                            .font(.caption)
                            .foregroundColor(Color.secondary)
                    } else {
                        Text(entity.wrappedDate.formatted(date: .omitted, time: .shortened))
                            .font(.caption)
                            .foregroundColor(Color.secondary)
                    }
                }
                
                HStack {
                    if !(entity.returns?.allObjects.isEmpty ?? true) {
                        Image(systemName: "arrow.uturn.backward")
                            .foregroundColor(.secondary)
                            .font(.caption.bold())
                    }
                    
                    Text("\((-entity.amountWithReturns).formatted(.currency(code: entity.wrappedCurrency)))")
                }
                .foregroundColor(entity.amountWithReturns != 0 ? .primary : .secondary)
            }
        }
    }
    
    private var editButton: some View {
        Button {
            vm.edit.toggle()
            vm.entityToEdit = entity
        } label: {
            Label {
                Text("Edit")
            } icon: {
                Image(systemName: "pencil")
            }
        }
        .tint(.accentColor)
    }
    
    private var deleteButton: some View {
        Button(role: .destructive) {
            deleteSpending(entity)
        } label: {
            Label {
                Text("Delete")
            } icon: {
                Image(systemName: "trash.fill")
            }
        }
        .tint(.red)
    }
    
    private var returnButon: some View {
        Button {
            vm.entityToAddReturn = entity
        } label: {
            Label("Add return", systemImage: "arrow.uturn.backward")
        }
        .tint(.yellow)
        .disabled(entity.amountWithReturns == 0)
    }
    
    // MARK: Functions
    
    private func buttonAction() {
        if vm.entityToEdit == nil {
            vm.entityToEdit = entity
        }
    }
    
    private func deleteSpending(_ entity: SpendingEntity) {
        viewContext.delete(entity)
        try? viewContext.save()
    }
}

//#Preview {
//    let row = StatsRow(
//        entity: .init(
//            amount: 1000,
//            amountUSD: 6.87,
//            comment: "",
//            currency: "JPY",
//            date: .now,
//            timeZoneIdentifier: "Asia/Tokyo",
//            id: .init(),
//            place: "Some place",
//            categoryID: .init(),
//            categoryName: "Category",
//            categoryColor: "",
//            returns: []
//        )
//    )
//    
//    return List {
//        row
//    }
//}
