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
    @EnvironmentObject 
    private var cdm: CoreDataModel
    @EnvironmentObject
    private var rvm: RatesViewModel
    
    let entity: SpendingEntity
    let localEntity: TSSpendingEntity
    
    @Binding 
    var entityToEdit: SpendingEntity?
    @Binding
    var entityToAddReturn: SpendingEntity?
    @Binding
    var edit: Bool
    
    #if DEBUG
    let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
    #endif
    
    var body: some View {
        Button {
            if entityToEdit == nil {
                entityToEdit = entity
            }
        } label: {
            buttonLabel
        }
    }
    
    // MARK: Variables
    
    var buttonLabel: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                if let place = localEntity.place, !place.isEmpty {
                    Text(localEntity.categoryName)
                        .font(.caption)
                        .foregroundColor(Color.secondary)
                    
                    Text(place)
                        .foregroundColor(.primary)
                } else {
                    Text(localEntity.categoryName)
                        .foregroundColor(.primary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 5) {
                Text(localEntity.wrappedDate, format: .dateTime.hour().minute())
                    .font(.caption)
                    .foregroundColor(Color.secondary)
                
                HStack {
                    if !localEntity.returnsArr.isEmpty {
                        Image(systemName: "arrow.uturn.backward")
                            .foregroundColor(.secondary)
                            .font(.caption.bold())
                    }
                    
                    Text("-\((localEntity.amountWithReturns).formatted(.currency(code: localEntity.wrappedCurrency)))")
                }
                .foregroundColor(localEntity.amountWithReturns != 0 ? .primary : .secondary)
            }
        }
    }
    
    private var editButton: some View {
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
            entityToAddReturn = entity
        } label: {
            Label("Add return", systemImage: "arrow.uturn.backward")
        }
        .tint(.yellow)
        .disabled(entity.amountWithReturns == 0)
    }
    
    // MARK: Functions
    
    init(entity: SpendingEntity, entityToEdit: Binding<SpendingEntity?>, entityToAddReturn: Binding<SpendingEntity?>, edit: Binding<Bool>) {
        self.entity = entity
        self.localEntity = entity.safeObject()
        self._entityToEdit = entityToEdit
        self._entityToAddReturn = entityToAddReturn
        self._edit = edit
        
        #if DEBUG
//        logger.log("Sum: \(entity.amountWithReturns), date: \(entity.wrappedDate) initialized")
        #endif
    }
    
    private func deleteSpending(_ entity: SpendingEntity) {
        withAnimation {
            cdm.deleteSpending(entity)
        }
    }
}

//struct StatsRow_Previews: PreviewProvider {
//    static var previews: some View {
//        StatsRow(entity: SpendingEntity(), entityToEdit: .constant(.init(context: DataManager.shared.context)), vm: .init(ratesViewModel: <#T##RatesViewModel#>, coreDataModel: <#T##CoreDataModel#>, entity: <#T##Binding<SpendingEntity?>#>))
//            .environmentObject(CoreDataModel())
//    }
//}
