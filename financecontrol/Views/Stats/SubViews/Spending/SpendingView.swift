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
    
    @AppStorage("defaultCurrency") var defaultCurrency: String = "USD"
    
    @State private var tabbarIsHidden: Bool = false
    
    var body: some View {
        List {
            Section(header: Text("amount")) {
                Text(entity.amount.formatted(.currency(code: entity.currency ?? "Error")))
                    .amountStyle()
                    .padding(.vertical, 10)
                
                if entity.currency != defaultCurrency {
                    Text(Double(entity.amountUSD * (rvm.rates[defaultCurrency.lowercased()] ?? 1))
                        .formatted(.currency(code: defaultCurrency))
                    )
                }
            }
            
            Section {
                
                HStack {
                    Text("Category")
                    Spacer()
                    Text(entity.categoryName)
                        .foregroundColor(Color.secondary)
                }
                
                HStack {
                    Text("Date")
                    Spacer()
                    Text(dateFormat(date:entity.wrappedDate, time: true))
                        .foregroundColor(Color.secondary)
                }
            } header: {
                Text("info")
            }
            
            Section {
                HStack {
                    Text("Place")
                    Spacer()
                    if entity.place != "" {
                        Text(entity.place ?? "No place")
                            .foregroundColor(Color.secondary)
                    } else {
                        Text("No place provided")
                            .foregroundColor(Color.secondary)
                    }
                }
                
                if entity.comment == "" {
                    Text("No comment provided")
                        .foregroundColor(Color.secondary)
                } else {
                    Text(entity.comment ?? "Error")
                }
            } header: {
                Text("Comment")
            }
            
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                Button {
                    withAnimation {
                        edit.toggle()
                    }
                } label: {
                    Text("Edit")
                }
            }
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
