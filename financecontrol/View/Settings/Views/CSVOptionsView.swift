//
//  CSVOptionsView.swift
//  Squirrel
//
//  Created by PinkXaciD on 2025/06/06.
//

import SwiftUI

struct CSVOptionsView: View {
    @Environment(\.dismiss)
    private var dismiss
    @EnvironmentObject
    private var vm: ExportCSVViewModel
    
    var formatter: NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyDecimalSeparator = vm.decimalSeparator.rawValue
        f.currencyGroupingSeparator = vm.groupingSeparator.rawValue
        f.maximumFractionDigits = 2
        f.currencySymbol = ""
        return f
    }
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Delimiter")
                    
                    Menu {
                        Picker("Delimiter", selection: $vm.delimiter) {
                            ForEach(ExportCSVViewModel.Delimiter.allCases, id: \.self) { delimiter in
                                Text(delimiter.displayDescription)
                                    .tag(delimiter)
                            }
                        }
                    } label: {
                        HStack {
                            Spacer()
                            
                            Text(vm.delimiter.displayDescription)
                        }
                    }
                }
                .animation(.default, value: vm.delimiter)
            } header: {
                Text("File Options")
            }
            
            Section {
                HStack {
                    Text("Decimal Separator")
                    
                    Menu {
                        Picker("Decimal Separator", selection: $vm.decimalSeparator) {
                            ForEach([ExportCSVViewModel.Separator.comma, ExportCSVViewModel.Separator.dot], id: \.self) { delimiter in
                                Text(delimiter.displayDescription)
                                    .tag(delimiter)
                            }
                        }
                    } label: {
                        HStack {
                            Spacer()
                            
                            Text(vm.decimalSeparator.displayDescription)
                        }
                    }
                }
                .animation(.default, value: vm.delimiter)
                
                HStack {
                    Text("Grouping Separator")
                    
                    Menu {
                        Picker("Grouping Separator", selection: $vm.groupingSeparator) {
                            ForEach(ExportCSVViewModel.Separator.allCases, id: \.self) { delimiter in
                                Text(delimiter.displayDescription)
                                    .tag(delimiter)
                            }
                        }
                    } label: {
                        HStack {
                            Spacer()
                            
                            Text(vm.groupingSeparator.displayDescription)
                        }
                    }
                }
                .animation(.default, value: vm.delimiter)
            } header: {
                Text("Number Formatting")
            } footer: {
                Text("Format Example: \(formatter.string(from: 1234.56) ?? "")")
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.primary)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.vertical)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .font(.body.bold())
            }
        }
        .navigationTitle("CSV Options")
        .onChange(of: vm.groupingSeparator) { newValue in
            if newValue == vm.decimalSeparator {
                withAnimation(.default.speed(2)) {
                    vm.decimalSeparator = vm.decimalSeparator == .dot ? .comma : .dot
                }
            }
        }
        .onChange(of: vm.decimalSeparator) { newValue in
            if newValue == vm.groupingSeparator {
                withAnimation(.default.speed(2)) {
                    vm.groupingSeparator = vm.groupingSeparator == .dot ? .comma : .dot
                }
            }
        }
        .animation(.default.speed(2), value: vm.delimiter)
        .animation(.default.speed(2), value: vm.decimalSeparator)
        .animation(.default.speed(2), value: vm.groupingSeparator)
    }
}
