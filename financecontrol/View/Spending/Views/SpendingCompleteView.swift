//
//  SpendingCompleteView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/11.
//

import SwiftUI

struct SpendingCompleteView: View {
    @AppStorage(UDKeys.color.rawValue)
    private var tint: String = "Orange"
    @AppStorage(UDKeys.privacyScreen.rawValue)
    private var privacyScreenIsEnabled: Bool = false
    @EnvironmentObject
    private var privacyMonitor: PrivacyMonitor
    
    @Binding var edit: Bool
    
    @State var entity: SpendingEntity
    @State var editFocus: String = "nil"
    @State private var entityToAddReturn: SpendingEntity? = nil
    @State private var returnToEdit: ReturnEntity? = nil
    @State private var toDismiss: Bool = false
    @State private var hideContent: Bool = false
    
//    @StateObject
//    private var vm: EditSpendingViewModel
    @EnvironmentObject private var cdm: CoreDataModel
    @EnvironmentObject private var rvm: RatesViewModel
    
    var body: some View {
        let categoryColor = CustomColor.nordAurora[entity.category?.color ?? ""] ?? .primary
        
        Group {
            if edit {
                NavigationView {
                    EditSpendingView(
                        entity: $entity,
                        edit: $edit,
                        categoryColor: categoryColor,
                        focus: editFocus,
                        entityToAddReturn: $entityToAddReturn,
                        returnToEdit: $returnToEdit,
                        toDismiss: $toDismiss,
                        cdm: cdm,
                        rvm: rvm
                    )
                    .tint(categoryColor)
                    .accentColor(categoryColor)
                    .sheet(item: $entityToAddReturn, onDismiss: dismissAction) { entity in
                        AddReturnView(spending: entity, cdm: cdm, rvm: rvm)
                            .accentColor(colorIdentifier(color: tint))
                            .tint(colorIdentifier(color: tint))
                    }
    // TODO: EditReturnView
    //                .sheet(item: $returnToEdit) { returnEntity in
    //                    EditReturnView(returnEntity: returnEntity, spending: entity, cdm: cdm, rvm: rvm)
    //                        .smallSheet(0.5)
    //                        .tint(colorIdentifier(color: tint))
    //                        .accentColor(colorIdentifier(color: tint))
    //                }
                }
                .navigationViewStyle(.stack)
                .transition(.opacity)
            } else {
                NavigationView {
                    SpendingView(
                        entity: entity,
                        edit: $edit,
                        editFocus: $editFocus,
                        categoryColor: categoryColor,
                        entityToAddReturn: $entityToAddReturn,
                        returnToEdit: $returnToEdit
                    )
                    .tint(categoryColor)
                    .accentColor(categoryColor)
                    .sheet(item: $entityToAddReturn, onDismiss: dismissAction) { entity in
                        AddReturnView(spending: entity, cdm: cdm, rvm: rvm)
                            .accentColor(colorIdentifier(color: tint))
                            .tint(colorIdentifier(color: tint))
                    }
                }
                .navigationViewStyle(.stack)
                .transition(.opacity)
            }
        }
        .blur(radius: hideContent ? Vars.privacyBlur : 0)
        .onChange(of: privacyMonitor.privacyScreenIsEnabled) { value in
            let animation: Animation = value ? .default : .easeOut(duration: 0.2)
            
            if privacyScreenIsEnabled {
                withAnimation(animation) {
                    hideContent = value
                }
            }
        }
        .sheet(item: $returnToEdit) { returnEntity in
            EditReturnView(returnEntity: returnEntity, spending: entity, cdm: cdm, rvm: rvm)
                .smallSheet(0.5)
                .tint(colorIdentifier(color: tint))
                .accentColor(colorIdentifier(color: tint))
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

//struct SpendingCompleteView_Previews: PreviewProvider {
//    static var previews: some View {
//        SpendingCompleteView()
//    }
//}
