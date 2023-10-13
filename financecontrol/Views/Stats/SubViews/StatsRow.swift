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
    
    @State private var editSpending: Bool = false
    @State private var showSheet: Bool = false
    
    var body: some View {
        Button {
            showSheet.toggle()
        } label: {
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
        .swipeActions(edge: .leading) {
            editButton
                .tint(Color.yellow)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            deleteButton
                .tint(Color.red)
        }
        .contextMenu {
            editButton
            
            deleteButton
        }
        .background {
            NavigationLink(isActive: $editSpending) {
                SpendingCompleteView(edit: true, entity: entity)
            } label: {
                EmptyView()
            }
            .disabled(true)
            .opacity(0)
        }
        .sheet(isPresented: $showSheet) {
            SpendingCompleteView(edit: false, entity: entity)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
    }
    
    // MARK: Variables
    
    var editButton: some View {
        Button {
            editSpending.toggle()
        } label: {
            Label {
                Text("Edit")
            } icon: {
                Image(systemName: "pencil")
            }
        }
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
