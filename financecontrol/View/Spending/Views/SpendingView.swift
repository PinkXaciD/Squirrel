//
//  SpendingView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/12.
//

import SwiftUI

struct SpendingView: View {
    
    @EnvironmentObject 
    private var cdm: CoreDataModel
    @EnvironmentObject
    private var rvm: RatesViewModel
    
    var entity: SpendingEntity
    let safeEntity: TSSpendingEntity
    @Binding
    var edit: Bool
    @Binding
    var editFocus: String
    var categoryColor: Color
    
    @Binding
    var entityToAddReturn: SpendingEntity?
    @Binding
    var returnToEdit: ReturnEntity? 
    
    @Environment(\.dismiss) 
    private var dismiss
    
    @AppStorage(UDKey.defaultCurrency.rawValue) 
    var defaultCurrency: String = Locale.current.currencyCode ?? "USD"
    @AppStorage(UDKey.formatWithoutTimeZones.rawValue)
    private var formatWithoutTimeZones: Bool = false
    @AppStorage(UDKey.timeZoneFormat.rawValue)
    private var timeZoneFormat: Int = 0
    
    @State
    private var alertIsPresented: Bool = false
    
    var dateFormatStyle: Date.FormatStyle {
        var formatStyle = Date.FormatStyle.dateTime
            .year(.extended())
            .month(.wide).day()
            .hour()
            .minute()
        
        if !formatWithoutTimeZones, let timeZone = safeEntity.timeZone {
            formatStyle.timeZone = timeZone
        }
        
        return formatStyle
    }
    
    var body: some View {
        List {
            infoSection
            
            commentSection
            
            if !safeEntity.returns.isEmpty {
                returnsSection
            }
            
            #if DEBUG
            debugSection
            #endif
        }
        .confirmationDialog("Delete this expense?", isPresented: $alertIsPresented, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                dismiss()
                cdm.deleteSpending(entity)
            }
        } message: {
            Text("You can't undo this action.")
        }
        .toolbar {
            closeToolbar
            editToolbar
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: Variables
    
    private var infoSection: some View {
        Section(header: infoHeader) {
            HStack {
                Text("Category")
                
                Spacer()
                
                Text(safeEntity.categoryName)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.trailing)
            }
            .onTapGesture {
                editAction()
            }
            
            HStack {
                Text("Date")
                
                Spacer()
                
                Text(safeEntity.wrappedDate.formatted(dateFormatStyle))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.trailing)
            }
            .onTapGesture {
                editAction()
            }
            
            if !formatWithoutTimeZones, let timeZone = safeEntity.timeZone, timeZone.identifier != TimeZone.autoupdatingCurrent.identifier {
                HStack {
                    Text("Timezone")
                    
                    Spacer()
                    
                    Text(timeZone.formatted(.init(rawValue: timeZoneFormat), for: self.entity.wrappedDate))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.trailing)
                }
                .onTapGesture {
                    editAction()
                }
            }
        }
    }
    
    private var infoHeader: some View {
        VStack(alignment: .center, spacing: 8) {
            if let place = safeEntity.place, !place.isEmpty {
                Text(place)
                    .font(.title2.bold())
                    .onTapGesture {
                        editAction("place")
                    }
                    .multilineTextAlignment(.center)
            }
            
            if safeEntity.returns.isEmpty {
                amountWithoutReturns
                    .frame(width: UIScreen.main.bounds.width)
            } else {
                amountWithReturns
                    .transition(.identity)
                    .frame(width: UIScreen.main.bounds.width)
            }
            
            if safeEntity.wrappedCurrency != defaultCurrency {
                if safeEntity.returns.isEmpty {
                    defaultCurrencyAmountWithoutReturns
                } else {
                    defaultCurrencyAmountWithReturns
                }
            }
        }
        .textCase(nil)
        .foregroundColor(categoryColor)
        .frame(maxWidth: .infinity)
        .listRowInsets(.init(top: 10, leading: 20, bottom: 40, trailing: 20))
    }
    
    private var amountWithoutReturns: some View {
        VStack {
            Text(safeEntity.amountWithReturns.formatted(.currency(code: safeEntity.wrappedCurrency)))
                .font(.system(.largeTitle, design: .rounded).bold())
                .scaledToFit()
                .minimumScaleFactor(0.01)
                .onTapGesture {
                    editAction("amount")
                }
        }
    }
    
    private var amountWithReturns: some View {
        VStack(alignment: .center) {
            Text(safeEntity.amount.formatted(.currency(code: safeEntity.wrappedCurrency)))
                .font(.system(.title, design: .rounded).bold())
                .foregroundStyle(.secondary)
                .roundedStrikeThrough(categoryColor)
                .padding(.bottom, 3) /// Normalize spacing between arrow and amount
                .onTapGesture {
                    editAction("amount")
                }
            
            Image(systemName: "arrow.down")
                .font(.system(.caption, design: .rounded).bold())
                .foregroundStyle(.secondary)
                .onTapGesture {
                    editAction("amount")
                }
            
            Text(safeEntity.amountWithReturns.formatted(.currency(code: safeEntity.wrappedCurrency)))
                .font(.system(.largeTitle, design: .rounded).bold())
                .onTapGesture {
                    editAction("amount")
                }
        }
        .scaledToFit()
        .minimumScaleFactor(0.01)
    }
    
    private var defaultCurrencyAmountWithoutReturns: some View {
        Text(
            (entity.amountUSDWithReturns * (rvm.rates[defaultCurrency] ?? 1))
                .formatted(.currency(code: defaultCurrency))
        )
        .font(.system(.body, design: .rounded))
    }
    
    private var defaultCurrencyAmountWithReturns: some View {
        HStack {
            Text(
                (entity.amountUSD * (rvm.rates[defaultCurrency] ?? 1))
                    .formatted(.currency(code: defaultCurrency))
            )
            .font(.system(.body, design: .rounded))
            .foregroundStyle(.secondary)
            .roundedStrikeThrough(categoryColor, thickness: 1)
            .onTapGesture {
                editAction("amount")
            }
            
            Image(systemName: "arrow.forward")
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.secondary)
                .onTapGesture {
                    editAction("amount")
                }
            
            Text(
                (entity.amountUSDWithReturns * (rvm.rates[defaultCurrency] ?? 1))
                    .formatted(.currency(code: defaultCurrency))
            )
            .font(.system(.body, design: .rounded))
            .onTapGesture {
                editAction("amount")
            }
        }
    }
    
    private var commentSection: some View {
        Section(header: Text("Comment"), footer: returnAndDeleteButtons) {
            if let comment = safeEntity.comment, !comment.isEmpty {
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(.init(uiColor: .secondarySystemGroupedBackground))
                    
                    Text(comment)
                }
            } else {
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(.init(uiColor: .secondarySystemGroupedBackground))
                    
                    Text("No comment provided")
                        .foregroundColor(.secondary)
                }
            }
        }
        .onTapGesture {
            editAction("comment")
        }
    }
    
    #if DEBUG
    private var debugSection: some View {
        Section {
            HStack {
                Text(verbatim: "Date adjusted to tz")
                
                Spacer()
                
                Text(entity.dateAdjustedToTimeZone.formatted(.dateTime.day().month(.defaultDigits).year(.defaultDigits).hour().minute()))
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                Text(verbatim: "Amount in USD:")
                
                Spacer()
                
                Text("\(entity.amountUSD.formatted(.currency(code: "USD")))")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text(verbatim: "Amount in USD with returns:")
                
                Spacer()
                
                Text("\(entity.amountUSDWithReturns.formatted(.currency(code: "USD")))")
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading) {
                Text(verbatim: "ID:")
                
                Text("\(entity.wrappedId.uuidString)")
                    .foregroundColor(.secondary)
                    .font(.system(size: 14))
            }
            
            VStack(alignment: .leading) {
                Text(verbatim: "Context")
                
                Text("\(entity.managedObjectContext?.name ?? "Error")")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Time zone")
                
                Spacer()
                
                Text(entity.timeZoneIdentifier ?? "nil")
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Debug")
        }
    }
    #endif
    
    private var returnsSection: some View {
        Section {
            ForEach(entity.returnsArr.sorted { $0.date ?? .distantPast > $1.date ?? .distantPast }) { returnEntity in
                ReturnRow(returnToEdit: $returnToEdit, returnEntity: returnEntity, spendingCurrency: entity.wrappedCurrency)
            }
        } header: {
            Text("\(safeEntity.returns.count) returns")
        }
    }
    
    private var returnAndDeleteButtons: some View {
        HStack(spacing: 15) {
            Button {
                entityToAddReturn = entity
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color(uiColor: .secondarySystemGroupedBackground))
                    
                    Text(entity.amountWithReturns == 0 ? "Returned" : "Add return")
                        .padding(10)
                        .font(.body)
                }
            }
            .foregroundColor(entity.amountWithReturns == 0 ? .secondary : .green)
            .disabled(entity.amountWithReturns == 0)
            .frame(maxWidth: .infinity)
            .contentShape(.hoverEffect, RoundedRectangle(cornerRadius: 10))
            .hoverEffect()
            .padding(.top, 10)
            
            Button(role: .destructive) {
                alertIsPresented.toggle()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color(uiColor: .secondarySystemGroupedBackground))
                    
                    Text("Delete")
                        .padding(10)
                        .font(.body)
                }
            }
            .frame(maxWidth: .infinity)
            .contentShape(.hoverEffect, RoundedRectangle(cornerRadius: 10))
            .hoverEffect()
            .padding(.top, 10)
        }
        .listRowInsets(.init(top: 15, leading: 0, bottom: 15, trailing: 0))
        .frame(height: 30)
    }
    
    private var editToolbar: ToolbarItem<(), some View> {
        ToolbarItem {
            Button {
                editAction()
            } label: {
                Text("Edit")
            }
        }
    }
    
    private var closeToolbar: ToolbarItem<(), some View> {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Close") {
                dismiss()
            }
        }
    }
}

extension SpendingView {
    private func editAction(_ field: String = "nil") {
        editFocus = field
        edit.toggle()
    }
}

//struct SpendingView_Previews: PreviewProvider {
//    static var previews: some View {
//        SpendingView(
//            amount: 0.00,
//            currency: "USD",
//            comment: "Comment",
//            date: Date.now,
//            place: "Place",
//            category: "Category"
//        )
//    }
//}
