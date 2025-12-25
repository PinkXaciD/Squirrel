//
//  SpendingCompleteView.swift
//  financecontrol
//
//  Created by PinkXaciD on 2022/08/11.
//

import SwiftUI

struct SpendingCompleteView: View {
    @AppStorage(UDKey.color.rawValue)
    private var tint: String = "Orange"
    @AppStorage(UDKey.privacyScreen.rawValue)
    private var privacyScreenIsEnabled: Bool = false
    @EnvironmentObject
    private var privacyMonitor: PrivacyMonitor
    @EnvironmentObject
    private var cdm: CoreDataModel
    @EnvironmentObject
    private var rvm: RatesViewModel
    
    @Binding var edit: Bool
    
    var entity: SpendingEntity
    @State var editFocus: String = "nil"
    @State private var entityToAddReturn: SpendingEntity? = nil
    @State private var returnToEdit: ReturnEntity? = nil
    @State private var toDismiss: Bool = false
    @State private var hideContent: Bool = false
    
    var body: some View {
        let categoryColor = CustomColor.nordAurora[entity.category?.color ?? ""] ?? .secondary.opacity(0)
        
        Group {
            if edit {
                NavigationView {
                    EditSpendingView(
                        entity: entity,
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
                }
                .navigationViewStyle(.stack)
                .transition(.opacity)
            } else {
                NavigationView {
                    SpendingView(
                        entity: entity,
                        safeEntity: entity.safeObject(),
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
                .tint(colorIdentifier(color: tint))
                .accentColor(colorIdentifier(color: tint))
                .environmentObject(cdm)
        }
        .animation(.default, value: edit)
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("DismissEditSpendingView"))) { _ in
            edit = false
        }
        .interactiveDismissDisabled(edit)
    }
    
    func editToggle() {
        edit.toggle()
    }
    
    func dismissAction() {
        toDismiss.toggle()
    }
}

struct SpendingListRowButtonStyle: ButtonStyle {
    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass
    
    func makeBody(configuration: Configuration) -> some View {
        if dynamicTypeSize > .xLarge, horizontalSizeClass == .compact {
            accesabilityLabel(configuration)
                .overlay {
                    VStack {
                        Divider()
                        
                        Spacer()
                        
                        Divider()
                    }
                }
        } else {
            label(configuration)
        }
    }
    
    private func accesabilityLabel(_ configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .foregroundColor(Color(uiColor: .secondarySystemGroupedBackground))
            
            configuration.label
                .padding(10)
                .font(.body)
                .foregroundStyle(.tint)
        }
        .contentShape(.hoverEffect, Rectangle())
        .hoverEffect()
    }
    
    private func label(_ configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: Text.listCornerRadius)
                .foregroundColor(Color(uiColor: .secondarySystemGroupedBackground))
            
            configuration.label
                .padding(10)
                .font(.body)
                .foregroundStyle(.tint)
        }
        .contentShape(.hoverEffect, RoundedRectangle(cornerRadius: Text.listCornerRadius))
        .hoverEffect()
    }
}

//struct SpendingCompleteView_Previews: PreviewProvider {
//    static var previews: some View {
//        SpendingCompleteView()
//    }
//}
