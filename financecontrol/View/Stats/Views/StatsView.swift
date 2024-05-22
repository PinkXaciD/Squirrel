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
    @EnvironmentObject
    private var listVM: StatsListViewModel
    @EnvironmentObject
    private var privacyMonitor: PrivacyMonitor
    @EnvironmentObject
    private var searchModel: StatsSearchViewModel
    
    @Binding
    var entityToEdit: SpendingEntity?
    @Binding
    var entityToAddReturn: SpendingEntity?
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
                        .id(0)
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
                .environmentObject(privacyMonitor)
            }
            .sheet(isPresented: $showFilters) {
                filters
            }
            .sheet(item: $entityToAddReturn) { entity in
                AddReturnView(spending: entity, cdm: cdm, rvm: rvm)
                    .accentColor(.accentColor)
            }
            .navigationTitle("Stats")
//            .overlay {
//                if !searchModel.search.isEmpty {
//                    List {
//                        Text(searchModel.search)
//                        Text(searchModel.search)
//                        Text(searchModel.search)
//                        Text(searchModel.search)
//                    }
//                }
//            }
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
                        let dates = formatDateForFilterButton(fvm.startFilterDate, fvm.endFilterDate)
                        Text("\(dates.0) - \(dates.1)")
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
            .environmentObject(privacyMonitor)
    }
}

extension StatsView {
    init(entity: Binding<SpendingEntity?>, entityToAddReturn: Binding<SpendingEntity?>) {
        var size: CGFloat {
            let currentScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let windowBounds = currentScene?.windows.first(where: { $0.isKeyWindow })?.bounds
            let width = windowBounds?.width ?? UIScreen.main.bounds.width
            let height = windowBounds?.height ?? UIScreen.main.bounds.height
            return width > height ? (height / 1.7) : (width / 1.7)
        }
        
        self.size = size
        self._entityToEdit = entity
        self._entityToAddReturn = entityToAddReturn
    }
    
    private func formatDateForFilterButton(_ date1: Date, _ date2: Date) -> (String, String) {
        let formatter = DateFormatter()
        formatter.locale = Locale.autoupdatingCurrent
        
        if Calendar.current.isDate(date1, equalTo: date2, toGranularity: .year) {
            formatter.setLocalizedDateFormatFromTemplate("Md")
        } else {
            formatter.setLocalizedDateFormatFromTemplate("yM")
        }
        
        return (formatter.string(from: date1), formatter.string(from: date2))
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
