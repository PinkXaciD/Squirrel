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
    @EnvironmentObject
    private var vm: StatsViewModel
    
//    let entity: SpendingEntity?
    let localEntity: TSSpendingEntity
    
    #if DEBUG
    let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
    #endif
    
    var body: some View {
        button
    }
    
    // MARK: Variables
    private var button: some View {
//        print(localEntity.amount, localEntity.currency, localEntity.categoryName, "Button called")
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
//        print(localEntity.amount, localEntity.currency, localEntity.categoryName, "Button called")
        return HStack {
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
                    if !localEntity.returns.isEmpty {
                        Image(systemName: "arrow.uturn.backward")
                            .foregroundColor(.secondary)
                            .font(.caption.bold())
                    }
                    
                    Text("\((-localEntity.amountWithReturns).formatted(.currency(code: localEntity.wrappedCurrency)))")
                }
                .foregroundColor(localEntity.amountWithReturns != 0 ? .primary : .secondary)
            }
        }
    }
    
    private var editButton: some View {
        Button {
            if  let entity = try? localEntity.unsafeObject(in: cdm.context){
                vm.edit.toggle()
                vm.entityToEdit = entity
            }
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
            if let entity = try? localEntity.unsafeObject(in: cdm.context) {
                deleteSpending(entity)
            }
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
            if let entity = try? localEntity.unsafeObject(in: cdm.context) {
                vm.entityToAddReturn = entity
            }
        } label: {
            Label("Add return", systemImage: "arrow.uturn.backward")
        }
        .tint(.yellow)
        .disabled(localEntity.amountWithReturns == 0)
    }
    
    // MARK: Functions
    
    init(entity: TSSpendingEntity) {
        self.localEntity = entity
        
//        #if DEBUG
//        logger.log("Sum: \(entity.amountWithReturns), date: \(entity.wrappedDate) initialized")
//        print(entity.amount, entity.currency, entity.categoryName, "Initialized")
//        #endif
    }
    
    private func buttonAction() {
        if vm.entityToEdit == nil, let entity = try? localEntity.unsafeObject(in: cdm.context) {
            vm.entityToEdit = entity
        }
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
