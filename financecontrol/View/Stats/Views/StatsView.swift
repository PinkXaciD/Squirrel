//
//  StatsView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/06.
//

import SwiftUI
#if DEBUG
import OSLog
#endif

struct StatsView: View {
    @Environment(\.isSearching)
    private var isSearching
    @EnvironmentObject
    private var cdm: CoreDataModel
    @EnvironmentObject
    private var rvm: RatesViewModel
    @EnvironmentObject
    private var pcvm: PieChartViewModel
    @EnvironmentObject
    private var fvm: FiltersViewModel
//    @EnvironmentObject
//    private var searchModel: StatsSearchViewModel
    
    @State
    var entityToEdit: SpendingEntity? = nil
    @State
    var entityToAddReturn: SpendingEntity? = nil
    @State
    private var edit: Bool = false
    
    @State
    private var showFilters: Bool = false
    
    private var sheetFraction: CGFloat = 0.7
    
    private var size: CGFloat
    
    #if DEBUG
    let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
    #endif
    
    var body: some View {
        NavigationView {
            List {
                if !isSearching {
                    PieChartView(size: size)
//                        .id(0)
                }
                
                StatsListView(
                    entityToEdit: $entityToEdit,
                    entityToAddReturn: $entityToAddReturn,
                    edit: $edit
                )
            }
            .toolbar {
                trailingToolbar
                
                ToolbarItem(placement: .topBarLeading) {
                    if fvm.applyFilters {
                        Button {
                            clearFilters()
                        } label: {
                            Label("Clear filters", systemImage: "xmark")
                        }
                        .disabled(!fvm.applyFilters)
                        .buttonStyle(BorderedButtonStyle())
                    }
                }
            }
            .sheet(item: $entityToEdit) { entity in
                SpendingCompleteView(
                    edit: $edit,
                    entity: entity,
                    coreDataModel: cdm,
                    ratesViewModel: rvm
                )
                .smallSheet(sheetFraction)
            }
            .sheet(isPresented: $showFilters) {
                filters
            }
            .sheet(item: $entityToAddReturn) { entity in
                AddReturnView(spending: entity, cdm: cdm, rvm: rvm)
                    .accentColor(.accentColor)
            }
            .navigationTitle("Stats")
        }
        .navigationViewStyle(.stack)
    }
    
    private var trailingToolbar: ToolbarItemGroup<some View> {
        ToolbarItemGroup(placement: .topBarTrailing) {
            if fvm.applyFilters {
                Button {
                    showFilters.toggle()
                } label: {
                    HStack(spacing: 5) {
                        if Calendar.current.isDate(fvm.startFilterDate, equalTo: fvm.endFilterDate, toGranularity: .year) {
                            Text(fvm.startFilterDate, format: .dateTime.day(.defaultDigits).month(.defaultDigits))
                            
                            Text(verbatim: "-")
                            
                            Text(fvm.endFilterDate, format: .dateTime.day(.defaultDigits).month(.defaultDigits))
                        } else {
                            Text(fvm.startFilterDate, format: .dateTime.month(.defaultDigits).year(.defaultDigits))
                            
                            Text(verbatim: "-")
                            
                            Text(fvm.endFilterDate, format: .dateTime.month(.defaultDigits).year(.defaultDigits))
                        }
                    }
                    .font(.footnote)
                }
                .buttonStyle(BorderedButtonStyle())
            } else {
                Button {
                    showFilters.toggle()
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease")
                }
                .buttonStyle(BorderedButtonStyle())
            }
            
//            Button {
//                showFilters.toggle()
//            } label: {
//                if fvm.applyFilters {
//                    HStack {
//                        Text(fvm.startFilterDate, format: .dateTime.day(.defaultDigits).month(.defaultDigits).year(.defaultDigits))
//                        
//                        Text(verbatim: "-")
//                        
//                        Text(fvm.endFilterDate, format: .dateTime.day(.defaultDigits).month(.defaultDigits).year(.defaultDigits))
//                    }
//                    .font(.footnote)
//                } else {
//                    Label("Filter", systemImage: "line.3.horizontal.decrease")
//                }
//            }
//            .buttonStyle(BorderedButtonStyle())
        }
    }
    
    private var filters: some View {
        FiltersView()
            .environmentObject(fvm)
            .environmentObject(pcvm)
    }
}

extension StatsView {
    init() {
        var size: CGFloat {
            let currentScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let windowBounds = currentScene?.windows.first(where: { $0.isKeyWindow })?.bounds
            let width = windowBounds?.width ?? UIScreen.main.bounds.width
            let height = windowBounds?.height ?? UIScreen.main.bounds.height
            return width > height ? (height / 1.7) : (width / 1.7)
        }
        
        self.size = size
    }
    
    private func clearFilters() {
        #if DEBUG
        let startDate: Date = Date()
        
        defer {
            logger.log("\(#fileID) \(#function) completed within \(Date().timeIntervalSince(startDate)) seconds")
        }
        #endif
        
        withAnimation {
            pcvm.selectedCategory = nil
            fvm.clearFilters()
        }
        
        pcvm.updateData()
        pcvm.isScrollDisabled = false
    }
}

//struct StatsView_Previews: PreviewProvider {
//    static var previews: some View {
//        StatsView()
//            .environmentObject(CoreDataModel())
//            .environmentObject(RatesViewModel())
//            .environmentObject(FiltersViewModel(pcvmSelectionPublisher: ))
//    }
//}
