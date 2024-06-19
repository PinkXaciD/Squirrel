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
    
    @EnvironmentObject
    private var fvm: FiltersViewModel
    
    @State
    var withReturns: Bool?
    
    var body: some View {
        List {
            Section {
                Button {
                    if fvm.withReturns != true {
                        fvm.withReturns = true
                    }
                } label: {
                    HStack {
                        Text("With returns")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "checkmark")
                            .font(.body.bold())
                            .opacity(fvm.withReturns == true ? 1 : 0)
                            .animation(.default.speed(3), value: fvm.withReturns)
                    }
                }
                
                Button {
                    if fvm.withReturns != false {
                        fvm.withReturns = false
                    }
                } label: {
                    HStack {
                        Text("Without returns")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "checkmark")
                            .font(.body.bold())
                            .opacity(fvm.withReturns == false ? 1 : 0)
                            .animation(.default.speed(3), value: fvm.withReturns)
                    }
                }
            }
            
            Section {
                Button("Disable", role: .destructive) {
                    if fvm.withReturns != nil {
                        fvm.withReturns = nil
                    }
                }
                .disabled(fvm.withReturns == nil)
                .animation(.default.speed(3), value: fvm.withReturns)
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
