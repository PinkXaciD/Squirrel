//
//  SpendingView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/12.
//

import SwiftUI

struct SpendingView: View {
    
    @EnvironmentObject private var vm: CoreDataViewModel
    @EnvironmentObject private var rvm: RatesViewModel
    
    @State var entity: SpendingEntity
    @Binding var edit: Bool
    @Binding var editFocus: String
    var categoryColor: Color
    
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("defaultCurrency") var defaultCurrency: String = "USD"
    
    @State private var tabbarIsHidden: Bool = false
    
    var body: some View {
              
        Form {
            infoSection
            
            commentSection
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
                Text(entity.categoryName)
                    .foregroundColor(.secondary)
            }
            .onTapGesture {
                editAction()
            }
            
            HStack {
                Text("Date")
                Spacer()
                Text(entity.wrappedDate.formatted(date: .long, time: .shortened))
                    .foregroundColor(.secondary)
            }
            .onTapGesture {
                editAction()
            }
        }
    }
    
    private var infoHeader: some View {
        VStack(alignment: .center, spacing: 8) {
            if let place = entity.place, !place.isEmpty {
                Text(place)
                    .font(.system(.title2, weight: .bold))
                    .onTapGesture {
                        editAction("place")
                    }
            }
            
            Text(entity.amount.formatted(.currency(code: entity.wrappedCurrency)))
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .onTapGesture {
                    editAction("amount")
                }
            
            if entity.wrappedCurrency != defaultCurrency {
                Text(
                    (entity.amountUSD * (rvm.rates[defaultCurrency] ?? 1))
                        .formatted(.currency(code: defaultCurrency))
                )
                .font(.system(.body, design: .rounded))
            }
        }
        .padding(.bottom, 20)
        .textCase(nil)
        .foregroundColor(categoryColor)
        .frame(maxWidth: .infinity)
    }
    
    private var commentSection: some View {
        Section(header: Text("Comment")) {
            if let comment = entity.comment, !comment.isEmpty {
                Text(comment)
            } else {
                Text("No comment provided")
                    .foregroundColor(.secondary)
            }
        }
        .onTapGesture {
            editAction("comment")
        }
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
        withAnimation {
            edit.toggle()
        }
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
