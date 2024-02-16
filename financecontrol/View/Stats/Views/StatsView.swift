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
    @AppStorage("color")
    private var tint: String = "Orange"
    @StateObject
    var pcvm: PieChartViewModel
    
    @State
    var entityToEdit: SpendingEntity? = nil
    @State
    var entityToAddReturn: SpendingEntity? = nil
    @State
    private var edit: Bool = false
    
// MARK: Filters
    
    @State
    private var showFilters: Bool = false
    
    @State
    private var startFilterDate: Date = .now.getFirstDayOfMonth()
    @State
    private var endFilterDate: Date = .now
    @State
    private var filterCategories: [CategoryEntity] = []
    @State
    private var excludeCategories: Bool = false
    @State
    private var applyFilters: Bool = false
    @Binding
    var search: String
    
    private var sheetFraction: CGFloat = 0.7
    
    private var size: CGFloat
    
    #if DEBUG
    let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
    #endif
    
    var body: some View {
        NavigationView {
            ScrollViewReader { scroll in
                List {
                    if search.isEmpty && !isSearching {
                        PieChartView(
                            filterCategories: $filterCategories,
                            applyFilers: $applyFilters,
                            size: size
                        )
                        .environmentObject(pcvm)
                        .id(0)
                    }
                    
                    StatsListView(
                        entityToEdit: $entityToEdit,
                        entityToAddReturn: $entityToAddReturn,
                        edit: $edit,
                        search: $search,
                        applyFilters: $applyFilters,
                        startFilterDate: $startFilterDate,
                        endFilterDate: $endFilterDate,
                        filterCategories: $filterCategories
                    )
                }
            }
            .onChange(of: pcvm.selection) { newValue in
                onChangeFunc(-newValue)
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
                    .accentColor(colorIdentifier(color: tint))
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
                .disabled(!applyFilters)
                .opacity(applyFilters ? 1.0 : 0.0)
                
                Button {
                    showFilters.toggle()
                } label: {
                    Label("Filter", systemImage: applyFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                }
            }
        }
    }
    
    private var filters: some View {
        FiltersView(
            firstFilterDate: $startFilterDate,
            secondFilterDate: $endFilterDate,
            categories: $filterCategories,
            applyFilters: $applyFilters
        )
    }
    
    
}

extension StatsView {
    init(search: Binding<String>, cdm: CoreDataModel) {
        self._search = search
        
        var size: CGFloat {
            let currentScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let windowBounds = currentScene?.windows.first(where: { $0.isKeyWindow })?.bounds
            let width = windowBounds?.width ?? UIScreen.main.bounds.width
            let height = windowBounds?.height ?? UIScreen.main.bounds.height
            return width > height ? (height / 1.7) : (width / 1.7)
        }
        
        self.size = size
        self._pcvm = .init(wrappedValue: .init(contentSize: size, cdm: cdm))
    }
    
    private func searchFunc(_ data: StatsListData) -> StatsListData {
        if !search.isEmpty {
            let trimmedSearch = search.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let result = data.mapValues { entities in
                entities.filter { entity in
                    entity.place?.localizedCaseInsensitiveContains(trimmedSearch) ?? false
                    ||
                    entity.comment?.localizedCaseInsensitiveContains(trimmedSearch) ?? false
                }
            }
            .filter { !$0.value.isEmpty }
            
            return result
        } else {
            return data
        }
    }
    
    private func filterFunc(_ data: StatsListData) -> StatsListData {
        if applyFilters {
            let result = data.mapValues { entities in
                entities.filter { entity in
                    var filter: Bool = true
                    
                    if !filterCategories.isEmpty, let category = entity.category {
                        filter = filterCategories.contains(category)
                    }
                    
                    if filter {
                        filter = entity.wrappedDate >= startFilterDate && entity.wrappedDate <= endFilterDate
                    }
                    
                    return filter
                }
            }
            .filter { !$0.value.isEmpty }
            
            return result
        } else {
            return data
        }
    }
    
    private func onChangeFunc(_ value: Int) {
        if value == 0 {
            if filterCategories.isEmpty {
                applyFilters = false
            }
            startFilterDate = .now.getFirstDayOfMonth()
            endFilterDate = .now
        } else {
            startFilterDate = .now.getFirstDayOfMonth(value)
            endFilterDate = .now.getFirstDayOfMonth(value + 1)
            applyFilters = true
        }
        
        HapticManager.shared.impact(.soft)
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
            applyFilters = false
            startFilterDate = .now.getFirstDayOfMonth()
            endFilterDate = .now
            filterCategories = []
        }
    }
    
    private func scrollToTop(_ scroll: ScrollViewProxy) {
        scroll.scrollTo(0)
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView(search: .constant(""), cdm: .init())
            .environmentObject(CoreDataModel())
    }
}
