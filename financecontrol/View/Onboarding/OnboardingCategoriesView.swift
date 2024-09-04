//
//  OnboardingCategoriesView.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/03/13.
//

import SwiftUI

struct OnboardingCategoriesView: View {
    @Binding var showOverlay: Bool
    @Binding var screen: Int
    @EnvironmentObject private var cdm: CoreDataModel
    
    @State private var presentImportSheet: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                header
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.top, 30)
                    .padding(.bottom, 10)
                
                List {
                    addSection
                    
                    categoriesSection
                }
                .fileImporter(isPresented: $presentImportSheet, allowedContentTypes: [.json]) { result in
                    importJSON(result)
                }
                .navigationBarHidden(true)
                .overlay(alignment: .top) {
                    LinearGradient(
                        colors: [Color(uiColor: .systemGroupedBackground), Color(uiColor: .systemGroupedBackground).opacity(0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(width: UIScreen.main.bounds.width - 20, height: 20)
                }
                .safeAreaInset(edge: .bottom) {
                    EmptyView()
                        .frame(height: 60)
                }
            }
            .background {
                Color(uiColor: .systemGroupedBackground)
            }
        }
        .tint(.orange)
    }
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Add categories")
                    .font(.largeTitle.bold())
                
                Text("You can add categories later in settings")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            Spacer()
        }
        .textCase(nil)
        .foregroundColor(.primary)
        .listRowInsets(.init(top: 50, leading: 0, bottom: 20, trailing: 0))
    }
    
    private var addSection: some View {
        Section {
            NavigationLink("Add category") {
                AddCategoryView(id: .constant(.init()), insert: false)
                    .onAppear {
                        withAnimation {
                            showOverlay = false
                        }
                    }
                    .onDisappear {
                        withAnimation {
                            showOverlay = true
                        }
                    }
                    .tint(.orange)
            }
        }
    }
    
    private var categoriesSection: some View {
        Section {
            if cdm.savedCategories.isEmpty {
                Button("Import existing data") {
                    presentImportSheet.toggle()
                }
                .tint(.orange)
            }
            
            ForEach(cdm.savedCategories) { category in
                HStack {
                    Image(systemName: "circle.fill")
                        .font(.title)
                        .foregroundColor(Color[category.color ?? ""])
                    
                    Text(category.name ?? "Error")
                        .padding(.vertical)
                }
            }
        }
    }
    
    private func importJSON(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            if let imported = cdm.importJSON(url) {
                switch imported {
                case 0:
                    HapticManager.shared.notification(.error)
                default:
                    HapticManager.shared.notification(.success)
                    withAnimation {
                        screen += 1
                    }
                }
            }
        case .failure(let failure):
            ErrorType(error: failure).publish()
        }
    }
}
