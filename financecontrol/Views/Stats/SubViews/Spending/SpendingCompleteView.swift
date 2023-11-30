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
    
    @StateObject
    private var vm: EditSpendingViewModel
    
    var body: some View {
        
        let categoryColor = CustomColor.nordAurora[entity.category?.color ?? ""] ?? .primary
        
        if edit {
            NavigationView {
                SpendingEditView(vm: vm, entity: $entity, edit: $edit, categoryColor: categoryColor, focus: editFocus)
                    .tint(categoryColor)
                    .accentColor(categoryColor)
            }
        } else {
            NavigationView {
                SpendingView(entity: entity, edit: $edit, editFocus: $editFocus, categoryColor: categoryColor)
                    .tint(categoryColor)
                    .accentColor(categoryColor)
            }
        }
    }
    
    func editToggle() {
        withAnimation {
            edit.toggle()
        }
    }
}

extension SpendingCompleteView {
    internal init(edit: Binding<Bool>, entity: SpendingEntity, editFocus: String = "nil", coreDataModel cdm: CoreDataModel, ratesViewModel rvm: RatesViewModel) {
        self._edit = edit
        self.entity = entity
        self.editFocus = editFocus
        self._vm = StateObject(wrappedValue: .init(ratesViewModel: rvm, coreDataModel: cdm, entity: entity))
    }
}

//struct SpendingCompleteView_Previews: PreviewProvider {
//    static var previews: some View {
//        SpendingCompleteView()
//    }
//}
