//
//  StatsRow.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/24.
//

import SwiftUI

struct StatsRow: View {
    @EnvironmentObject var vm: CoreDataViewModel
    
    let entity: SpendingEntity
    
    @State var editSpending: Bool = false
    @State private var showSheet: Bool = false
    
    var body: some View {
        
        Button {
            showSheet.toggle()
        } label: {
            buttonLabel
        }
        .swipeActions(edge: .leading) {
            editButton
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            deleteButton
        }
        .contextMenu {
            editButton
            
            deleteButton
        }
        .sheet(isPresented: $showSheet) {
            if #available(iOS 16.0, *) {
                SpendingCompleteView(edit: $editSpending, entity: entity)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.hidden)
            } else {
                SpendingCompleteView(edit: $editSpending, entity: entity)
            }
        }
    }
    
    // MARK: Variables
    
    var buttonLabel: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                if let place = entity.place, !place.isEmpty {
                    
                    Text(entity.category?.name ?? "Error")
                        .font(.caption)
                        .foregroundColor(Color.secondary)
                    
                    Text(place)
                        .foregroundColor(.primary)
                } else {
                    Text(entity.category?.name ?? "Error")
                        .foregroundColor(.primary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 5) {
                Text("\(dateFormat(date: entity.wrappedDate, time: false))")
                    .font(.caption)
                    .foregroundColor(Color.secondary)
                
                Text("\((entity.amount * -1.0).formatted(.currency(code: entity.wrappedCurrency)))")
                    .foregroundColor(.primary)
            }
        }
    }
    
    var editButton: some View {
        Button {
            editSpending.toggle()
            showSheet.toggle()
        } label: {
            Label {
                Text("Edit")
            } icon: {
                Image(systemName: "pencil")
            }
        }
        .tint(Color.yellow)
    }
    
    var deleteButton: some View {
        Button(role: .destructive) {
            deleteSpending(entity)
        } label: {
            Label {
                Text("Delete")
            } icon: {
                Image(systemName: "trash.fill")
            }
        }
        .tint(Color.red)
    }
    
    // MARK: Functions
    
    func deleteSpending(_ entity: SpendingEntity) {
        vm.deleteSpending(entity)
    }
}

struct StatsRow_Previews: PreviewProvider {
    static var previews: some View {
        StatsRow(entity: SpendingEntity())
            .environmentObject(CoreDataViewModel())
    }
}
