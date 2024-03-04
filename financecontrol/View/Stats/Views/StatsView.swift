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
    @EnvironmentObject
    private var pcvm: PieChartViewModel
    @EnvironmentObject
    private var searchModel: StatsSearchViewModel
    
//    @Binding
//    var search: String
    
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
                        .environmentObject(pcvm)
                        .id(0)
                }
                
                StatsListView(
                    entityToEdit: $entityToEdit,
                    entityToAddReturn: $entityToAddReturn,
                    edit: $edit,
                    vm: .init(cdm: cdm, fvm: fvm, searchModel: searchModel)
                )
            }
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
            HStack {
                Button {
                    clearFilters()
                } label: {
                    Label("Clear filters", systemImage: "xmark.circle")
                }
                .disabled(!fvm.applyFilters)
                .opacity(fvm.applyFilters ? 1.0 : 0.0)
                
                Button {
                    showFilters.toggle()
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle\(fvm.applyFilters ? ".fill" : "")")
                }
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
            pcvm.selectedCategory = nil
            pcvm.updateData()
            fvm.applyFilters = false
            fvm.updateList = true
            DispatchQueue.main.async {
                fvm.startFilterDate = .now.getFirstDayOfMonth()
                fvm.endFilterDate = .now
                fvm.filterCategories = []
            }
        }
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
