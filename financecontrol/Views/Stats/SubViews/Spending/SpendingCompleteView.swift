//
//  SpendingCompleteView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/11.
//

import SwiftUI

struct SpendingCompleteView: View {
    @State var edit: Bool
    
    @State var entity: SpendingEntity
    
    var body: some View {
        if !edit {
            SpendingView(entity: entity, edit: $edit)
                .onTapGesture(perform: editToggle)
                .navigationTitle("Details")
        } else {
            SpendingEditView(entity: $entity, update: true, focus: "amount", edit: $edit)
                .navigationTitle("Edit")
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
