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
    
    var body: some View {
        
        let categoryColor = CustomColor.nordAurora[entity.category?.color ?? ""] ?? .primary
        
        if !edit {
            NavigationView {
                SpendingView(entity: entity, edit: $edit, editFocus: $editFocus, categoryColor: categoryColor)
                    .tint(categoryColor)
            }
        } else {
            NavigationView {
                SpendingEditView(entity: $entity, update: true, edit: $edit, categoryColor: categoryColor, focus: editFocus)
                    .tint(categoryColor)
            }
        }
    }
    
    func editToggle() {
        withAnimation {
            edit.toggle()
        }
    }
}

//struct SpendingCompleteView_Previews: PreviewProvider {
//    static var previews: some View {
//        SpendingCompleteView()
//    }
//}
