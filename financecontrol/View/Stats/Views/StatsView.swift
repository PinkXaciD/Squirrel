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
//            .overlay {
//                if isSearching {
//                    List {
//                        StatsListView(entityToEdit: $entityToEdit, entityToAddReturn: $entityToAddReturn, edit: $edit)
//                    }
//                }
//            }
            .toolbar {
                toolbar
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
    
    private var toolbar: ToolbarItemGroup<some View> {
        ToolbarItemGroup(placement: .topBarTrailing) {
            if fvm.applyFilters {
                Button {
                    clearFilters()
                } label: {
                    Label("Clear filters", systemImage: "xmark.circle")
                }
                .disabled(!fvm.applyFilters)
            }
            
            Button {
                showFilters.toggle()
            } label: {
                Label("Filter", systemImage: fvm.applyFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
            }
        }
    }
    
    private var filters: some View {
        FiltersView()
            .environmentObject(fvm)
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
            fvm.pcvm.selectedCategory = nil
            fvm.pcvm.updateData()
            fvm.clearFilters()
        }
    }
}

//struct StatsSearchOverlayView: View {
//    @EnvironmentObject private var vm: StatsSearchViewModel
//    
//    var body: some View {
//        EmptyView()
//    }
//}

//struct StatsView_Previews: PreviewProvider {
//    static var previews: some View {
//        StatsView()
//            .environmentObject(CoreDataModel())
//            .environmentObject(RatesViewModel())
//            .environmentObject(FiltersViewModel(pcvmSelectionPublisher: ))
//    }
//}
