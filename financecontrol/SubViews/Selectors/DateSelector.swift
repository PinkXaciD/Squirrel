//
//  DateSelector.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/06/27.
//

import SwiftUI

struct DateSelector: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var spendingDate: Date
    
    var body: some View {
        List {
            DatePicker("Date selection", selection: $spendingDate, in: Date.distantPast...Date.now)
                .datePickerStyle(.automatic)
                .navigationTitle("Select Date")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing, content: {
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .font(Font.body.weight(.semibold))
                }
            })
        }
    }
}

//struct DateSelector_Previews: PreviewProvider {
//    static var previews: some View {
//        DateSelector()
//    }
//}
