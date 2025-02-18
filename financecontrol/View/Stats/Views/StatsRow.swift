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
    @Environment(\.managedObjectContext)
    private var viewContext
    @EnvironmentObject
    private var rvm: RatesViewModel
    @EnvironmentObject
    private var listVM: StatsViewModel
    @EnvironmentObject
    private var vm: StatsRowViewModel
    
    @AppStorage(UDKey.formatWithoutTimeZones.rawValue)
    private var formatWithoutTimeZones: Bool = false
    
    @GestureState
    var rowDragging: UUID?
    
    let entity: SpendingEntity
    
    var isDragging: Bool {
        rowDragging == entity.id
    }
    
    let buttonWidth: CGFloat = 70
    let leadingTreshhold: CGFloat = ((UIApplication.shared.keyWindow?.bounds.width) ?? 300) * 0.5 - 10
    let trailingTreshhold: CGFloat = ((UIApplication.shared.keyWindow?.bounds.width) ?? 300) * -(2/3) + 10
    
    #if DEBUG
    let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
    #endif
    
    init(test: GestureState<UUID?>, entity: SpendingEntity) {
        self._rowDragging = test
        self.entity = entity
    }
    
    var body: some View {
        button
    }
    
    // MARK: Variables
    private var button: some View {
        Button(action: mainButtonAction) {
            mainButtonLabel
        }
        .buttonStyle(ListButtonStyle())
        .contextMenu {
            editButton
            
            returnButton
            
            deleteButton
        }
        .offset(x: offset)
        .background(alignment: .trailing) {
            if isDragging || vm.showTrailingButtons == entity.id, vm.hOffset < 0 {
                HStack(spacing: 0) {
                    if vm.triggerTrailingAction != self.entity.id {
                        returnButton
                            .buttonStyle(SwipeButtonStyle(alignment: .trailing))
                            .transition(.move(edge: .leading))
                    }
                    
                    deleteButton
                        .buttonStyle(SwipeButtonStyle(alignment: .trailing))
                }
                .frame(width: abs(offset))
                .transition(.move(edge: .trailing))
                .clipped()
            }
        }
        .background(alignment: .leading) {
            if isDragging || vm.showLeadingButtons == entity.id, vm.hOffset > 0 {
                editButton
                    .frame(width: abs(offset), alignment: .trailing)
                    .transition(.move(edge: .leading))
                    .buttonStyle(SingleSwipeButtonStyle(alignment: .leading, isActive: vm.triggerLeadingAction == self.entity.id))
            }
        }
        .animation(.default, value: isDragging)
        .animation(.default, value: vm.triggerLeadingAction)
        .animation(.default, value: vm.triggerTrailingAction)
        .highPriorityGesture(dragGesture)
        .onDisappear {
            withAnimation {
                self.vm.hOffset = .zero
                
                self.vm.showLeadingButtons = nil
                self.vm.showTrailingButtons = nil
            }
        }
    }
    
    private var mainButtonLabel: some View {
        return HStack {
            VStack(alignment: .leading, spacing: 5) {
                if let place = entity.place, !place.isEmpty {
                    Text(entity.categoryName)
                        .font(.caption)
                        .foregroundColor(Color.secondary)
                    
                    Text(place)
                        .foregroundColor(.primary)
                } else {
                    Text(entity.categoryName)
                        .foregroundColor(.primary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 5) {
                HStack(spacing: 3) {
                    if !formatWithoutTimeZones, let timeZone = TimeZone(identifier: entity.timeZoneIdentifier ?? ""), timeZone.secondsFromGMT() != TimeZone.autoupdatingCurrent.secondsFromGMT() {
                        Image(systemName: "clock")
                            .foregroundColor(.secondary)
                            .font(.caption2)
                        
                        Text(entity.dateAdjustedToTimeZoneDate.formatted(date: .omitted, time: .shortened))
                            .font(.caption)
                            .foregroundColor(Color.secondary)
                    } else {
                        Text(entity.wrappedDate.formatted(date: .omitted, time: .shortened))
                            .font(.caption)
                            .foregroundColor(Color.secondary)
                    }
                }
                
                HStack {
                    if !(entity.returns?.allObjects.isEmpty ?? true) {
                        Image(systemName: "arrow.uturn.backward")
                            .foregroundColor(.secondary)
                            .font(.caption.bold())
                    }
                    
                    Text("\((-entity.amountWithReturns).formatted(.currency(code: entity.wrappedCurrency)))")
                }
                .foregroundColor(entity.amountWithReturns != 0 ? .primary : .secondary)
            }
        }
    }
    
    private var editButton: some View {
        Button {
            editButtonAction()
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
            deleteButtonAction()
        } label: {
            Label {
                Text("Delete")
            } icon: {
                Image(systemName: "trash.fill")
            }
        }
        .tint(.red)
    }
    
    private var returnButton: some View {
        Button {
            listVM.entityToAddReturn = entity
            
            breakGesture()
        } label: {
            Label("Add return", systemImage: "arrow.uturn.backward")
        }
        .tint(.yellow)
        .disabled(entity.amountWithReturns == 0)
    }
    
    // MARK: Functions
    
    private func mainButtonAction() {
        guard rowDragging == nil else {
            return
        }
        
        if listVM.entityToEdit == nil {
            listVM.entityToEdit = entity
        }
        
        breakGesture()
    }
    
    private func editButtonAction() {
        listVM.edit.toggle()
        listVM.entityToEdit = entity
        
        breakGesture()
    }
    
    private func deleteButtonAction() {
        deleteSpending(entity)
        
        breakGesture()
    }
    
    private func deleteSpending(_ entity: SpendingEntity) {
        viewContext.delete(entity)
        try? viewContext.save()
    }
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 30)
            .updating($rowDragging) { value, state, _ in
                handleGesture(value: value, state: &state)
            }
            .onEnded { value in
                endGesture(value: value)
            }
    }
    
    private func handleGesture(value: DragGesture.Value, state: inout UUID?) {
        guard state == nil || state == entity.id else {
            return
        }
        
        state = entity.id
        vm.lastDragged = entity.id
        
        if vm.showLeadingButtons != nil, vm.showLeadingButtons != self.entity.id {
            withAnimation {
                vm.showLeadingButtons = nil
            }
        }
        
        if vm.showTrailingButtons != nil, vm.showTrailingButtons != self.entity.id {
            withAnimation {
                vm.showTrailingButtons = nil
            }
        }
        
        let translatedValue = value.translation.width + (vm.showLeadingButtons == self.entity.id ? buttonWidth : 0) + (vm.showTrailingButtons == self.entity.id ? -buttonWidth * 2 : 0)
        
        self.vm.hOffset = translatedValue
        
        if translatedValue < 0 {
            if self.vm.triggerLeadingAction != nil {
                self.vm.triggerLeadingAction = nil
            }
            
            if translatedValue < trailingTreshhold, vm.triggerTrailingAction != self.entity.id {
                self.vm.triggerTrailingAction = self.entity.id
                HapticManager.shared.impact(.light)
            } else if translatedValue >= trailingTreshhold, vm.triggerTrailingAction == self.entity.id {
                self.vm.triggerTrailingAction = nil
                HapticManager.shared.impact(.light)
            }
        } else {
            if self.vm.triggerTrailingAction != nil {
                self.vm.triggerTrailingAction = nil
            }
            
            if translatedValue > leadingTreshhold, vm.triggerLeadingAction != self.entity.id {
                self.vm.triggerLeadingAction = self.entity.id
                HapticManager.shared.impact(.light)
            } else if translatedValue <= leadingTreshhold, vm.triggerLeadingAction == self.entity.id {
                self.vm.triggerLeadingAction = nil
                HapticManager.shared.impact(.light)
            }
        }
    }
    
    private func endGesture(value: DragGesture.Value) {
        guard vm.lastDragged == entity.id else {
            return
        }
        
        vm.lastDragged = nil
        
        let translatedValue = value.translation.width + (vm.showLeadingButtons == self.entity.wrappedId ? buttonWidth : 0) + (vm.showTrailingButtons == self.entity.wrappedId ? -buttonWidth * 2 : 0)
        
        if translatedValue < trailingTreshhold {
            breakGesture()
            
            self.vm.triggerTrailingAction = nil
            
            deleteButtonAction()
            
            return
        }
        
        if translatedValue > leadingTreshhold {
            breakGesture()
            
            self.vm.triggerLeadingAction = nil
            
            editButtonAction()
            
            return
        }
        
        if translatedValue < -buttonWidth {
            self.vm.showTrailingButtons = self.entity.id
            
            withAnimation {
                self.vm.hOffset = -buttonWidth * 2
            }
            
            return
        }
        
        if translatedValue > buttonWidth/2 {
            self.vm.showLeadingButtons = self.entity.id
            
            withAnimation {
                self.vm.hOffset = buttonWidth
            }
            
            return
        }
        
        breakGesture()
    }
    
    private func breakGesture() {
        withAnimation {
            self.vm.hOffset = .zero
            
            self.vm.showLeadingButtons = nil
            self.vm.showTrailingButtons = nil
        }
    }
    
    private var offset: CGFloat {
        var result: CGFloat = self.vm.hOffset
        
        if vm.triggerLeadingAction == self.entity.id {
            let valueAfter = self.vm.hOffset - leadingTreshhold
            result = leadingTreshhold + valueAfter * 0.2
        }
        
        if vm.triggerTrailingAction == self.entity.id {
            let valueAfter = self.vm.hOffset + 250
            result = -250 + valueAfter * 0.2 - 30
        }
        
        guard isDragging || vm.showLeadingButtons == self.entity.wrappedId || vm.showTrailingButtons == self.entity.wrappedId else {
            return 0
        }
        
        return result
    }
    
    private struct SwipeButtonStyle: ButtonStyle {
        let alignment: Self.Alignment
        
        func makeBody(configuration: Configuration) -> some View {
            ZStack(alignment: alignment.trueAligniment) {
                Rectangle()
                    .fill(.tint)
                
                ZStack {
                    Rectangle()
                        .fill(.clear)
                        .frame(width: 70)
                    
                    configuration.label
                }
                .labelStyle(.iconOnly)
                .font(.title2)
                .frame(minWidth: .zero, alignment: alignment.trueAligniment)
                .foregroundStyle(.white)
            }
        }
        
        enum Alignment {
            case leading, trailing
            
            var trueAligniment: SwiftUI.Alignment {
                switch self {
                case .leading:
                    .trailing
                case .trailing:
                    .leading
                }
            }
        }
    }
    
    private struct SingleSwipeButtonStyle: ButtonStyle {
        let alignment: Self.Alignment
        let isActive: Bool
        
        func makeBody(configuration: Configuration) -> some View {
            ZStack(alignment: isActive ? .trailing : .leading) {
                Rectangle()
                    .fill(.tint)
                
                ZStack {
                    Rectangle()
                        .fill(.clear)
                        .frame(width: 70)
                    
                    configuration.label
                }
                .labelStyle(.iconOnly)
                .font(.title2)
                .foregroundStyle(.white)
            }
        }
        
        enum Alignment {
            case leading, trailing
            
            var trueAligniment: SwiftUI.Alignment {
                switch self {
                case .leading:
                    .trailing
                case .trailing:
                    .leading
                }
            }
        }
    }
    
    private struct ListButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding(.vertical, 10)
                .padding(.horizontal)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
        }
    }
}

//#Preview {
//    let row = StatsRow(
//        entity: .init(
//            amount: 1000,
//            amountUSD: 6.87,
//            comment: "",
//            currency: "JPY",
//            date: .now,
//            timeZoneIdentifier: "Asia/Tokyo",
//            id: .init(),
//            place: "Some place",
//            categoryID: .init(),
//            categoryName: "Category",
//            categoryColor: "",
//            returns: []
//        )
//    )
//    
//    return List {
//        row
//    }
//}
