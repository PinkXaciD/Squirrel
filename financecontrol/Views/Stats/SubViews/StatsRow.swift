//
//  StatsRow.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/24.
//

import SwiftUI

struct StatsRow: View {
    @EnvironmentObject var cdm: CoreDataModel
    @EnvironmentObject var rvm: RatesViewModel
    
    let entity: SpendingEntity
    
    @Binding var entityToEdit: SpendingEntity?
    @Binding var entityToAddReturn: SpendingEntity?
    @Binding var edit: Bool
    
    var body: some View {
        Button {
            if entityToEdit == nil {
                entityToEdit = entity
            }
        } label: {
            buttonLabel
        }
        .swipeActions(edge: .leading) {
            editButton
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            deleteButton
            
            returnButon
        }
        .contextMenu {
            editButton
            
            returnButon
            
            deleteButton
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
                Text(dateFormatter.string(from: entity.wrappedDate))
                    .font(.caption)
                    .foregroundColor(Color.secondary)
                
                HStack {
                    if !entity.returnsArr.isEmpty {
                        Image(systemName: "arrow.uturn.backward")
                            .foregroundColor(.secondary)
                            .font(.caption.bold())
                    }
                    
                    Text("-\((entity.amountWithReturns).formatted(.currency(code: entity.wrappedCurrency)))")
                }
                .foregroundColor(entity.amountWithReturns != 0 ? .primary : .secondary)
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }
    
    var editButton: some View {
        Button {
            edit.toggle()
            entityToEdit = entity
        } label: {
            Label {
                Text("Edit")
            } icon: {
                Image(systemName: "pencil")
            }
        }
        .tint(.accentColor)
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
        .tint(.red)
    }
    
    private var returnButon: some View {
        Button {
            entityToAddReturn = entity
        } label: {
            Label("Add return", systemImage: "arrow.uturn.backward")
        }
        .tint(.yellow)
        .disabled(entity.amountWithReturns == 0)
    }
    
    // MARK: Functions
    
    func deleteSpending(_ entity: SpendingEntity) {
        cdm.deleteSpending(entity)
    }
}

//struct StatsRow_Previews: PreviewProvider {
//    static var previews: some View {
//        StatsRow(entity: SpendingEntity(), entityToEdit: .constant(.init(context: DataManager.shared.context)), vm: .init(ratesViewModel: <#T##RatesViewModel#>, coreDataModel: <#T##CoreDataModel#>, entity: <#T##Binding<SpendingEntity?>#>))
//            .environmentObject(CoreDataModel())
//    }
//}
