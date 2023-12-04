//
//  SpendingCompleteView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/11.
//

import SwiftUI

struct SpendingCompleteView: View {
    @Binding var edit: Bool
    
    @State var entity: SpendingEntity
    @State var editFocus: String = "nil"
    @State private var entityToAddReturn: SpendingEntity? = nil
    @State private var toDismiss: Bool = false
    
    @StateObject
    private var vm: EditSpendingViewModel
    private var cdm: CoreDataModel
    private var rvm: RatesViewModel
    
    var body: some View {
        let categoryColor = CustomColor.nordAurora[entity.category?.color ?? ""] ?? .primary
        
        if edit {
            NavigationView {
                SpendingEditView(
                    vm: vm,
                    entity: $entity,
                    edit: $edit,
                    categoryColor: categoryColor,
                    focus: editFocus,
                    entityToAddReturn: $entityToAddReturn,
                    toDismiss: $toDismiss
                )
                .tint(categoryColor)
                .accentColor(categoryColor)
                .sheet(item: $entityToAddReturn, onDismiss: dismissAction) { entity in
                    AddReturnView(spending: entity, cdm: cdm, rvm: rvm)
                }
            }
        } else {
            NavigationView {
                SpendingView(
                    entity: entity,
                    edit: $edit,
                    editFocus: $editFocus,
                    categoryColor: categoryColor,
                    entityToAddReturn: $entityToAddReturn
                )
                .tint(categoryColor)
                .accentColor(categoryColor)
                .sheet(item: $entityToAddReturn, onDismiss: dismissAction) { entity in
                    AddReturnView(spending: entity, cdm: cdm, rvm: rvm)
                }
            }
        }
    }
    
    func editToggle() {
        withAnimation {
            edit.toggle()
        }
    }
    
    func dismissAction() {
        toDismiss.toggle()
    }
}

extension SpendingCompleteView {
    internal init(
        edit: Binding<Bool>,
        entity: SpendingEntity,
        editFocus: String = "nil",
        coreDataModel cdm: CoreDataModel,
        ratesViewModel rvm: RatesViewModel
    ) {
        self._edit = edit
        self.entity = entity
        self.editFocus = editFocus
        self._vm = StateObject(wrappedValue: .init(ratesViewModel: rvm, coreDataModel: cdm, entity: entity))
        self.cdm = cdm
        self.rvm = rvm
    }
}

//struct SpendingCompleteView_Previews: PreviewProvider {
//    static var previews: some View {
//        SpendingCompleteView()
//    }
//}
