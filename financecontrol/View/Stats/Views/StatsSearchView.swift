//
//  StatsSearchView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/12/07.
//

import SwiftUI
#if DEBUG
import OSLog
#endif

struct StatsSearchView: View {
    @EnvironmentObject
    private var svm: StatsSearchViewModel
    @State
    private var entityToEdit: SpendingEntity? = nil
    @State
    private var entityToAddReturn: SpendingEntity? = nil
    @State
    private var isPresented: Bool = false
    @State
    private var searchWasActive: Bool = false
    
    var body: some View {
        StatsView(entity: $entityToEdit, entityToAddReturn: $entityToAddReturn)
            .searchableWithDisable(text: $svm.search, isPresented: $isPresented, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Search by place or comment")
            // MARK: iOS 17.4 search bar bug fix
            .onChange(of: entityToEdit) { value in
                if #available(iOS 17.4, *) {
                    if value != nil {
                        searchWasActive = isPresented
                        isPresented = false
                    } else {
                        isPresented = searchWasActive
                    }
                }
            }
            .onChange(of: entityToAddReturn) { value in
                if #available(iOS 17.4, *) {
                    if value != nil {
                        searchWasActive = isPresented
                        isPresented = false
                    } else {
                        isPresented = searchWasActive
                    }
                }
            }
    }
}

// MARK: iOS 17.4 search bar bug fix
fileprivate extension View {
    func searchableWithDisable(text: Binding<String>, isPresented: Binding<Bool>, placement: SearchFieldPlacement, prompt: LocalizedStringKey) -> some View {
        if #available(iOS 17.4, *) {
            return self.searchable(text: text, isPresented: isPresented, placement: placement, prompt: prompt)
        } else {
            return self.searchable(text: text, placement: placement, prompt: prompt)
        }
    }
}
