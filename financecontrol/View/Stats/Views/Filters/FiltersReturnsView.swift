//
//  FiltersReturnsView.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/06/12.
//

import SwiftUI

struct FiltersReturnsView: View {
    @Environment(\.dismiss)
    private var dismiss
    
    @Binding var withReturns: Bool?
    
    var body: some View {
        List {
            Section {
                Button {
                    if withReturns != true {
                        withReturns = true
                    }
                } label: {
                    HStack {
                        Text("With returns")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "checkmark")
                            .font(.body.bold())
                            .opacity(withReturns == true ? 1 : 0)
                            .animation(.default.speed(3), value: withReturns)
                    }
                }
                
                Button {
                    if withReturns != false {
                        withReturns = false
                    }
                } label: {
                    HStack {
                        Text("Without returns")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "checkmark")
                            .font(.body.bold())
                            .opacity(withReturns == false ? 1 : 0)
                            .animation(.default.speed(3), value: withReturns)
                    }
                }
            }
            
            Section {
                Button("Disable", role: .destructive) {
                    if withReturns != nil {
                        withReturns = nil
                    }
                }
                .disabled(withReturns == nil)
                .animation(.default.speed(3), value: withReturns)
            }
        }
        .navigationTitle("Returns")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.body.bold())
                }
            }
        }
    }
}
