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
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], predicate: NSPredicate(format: "isShadowed == false"))
    var categories: FetchedResults<CategoryEntity>
    
    @State private var presentImportSheet: Bool = false
    
    private var topPadding: CGFloat {
        if #available(iOS 26.0, *) {
            return 50
        }
        
        return 40
    }
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack(spacing: 0) {
                    header
                        .padding(.horizontal)
                        .padding(.top)
                        .padding(.top, topPadding)
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
                        .frame(width: geometry.size.width - 20, height: 20)
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
    }
    
    private var header: some View {
        OnboardingHeaderView(header: "Add categories", description: "You can add categories later in settings")
    }
    
    private var addSection: some View {
        Section {
            NavigationLink("Add category") {
                AddCategoryView(selectedCategory: .constant(.init()), insert: false)
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
            if categories.isEmpty {
                Button("Import existing data") {
                    presentImportSheet.toggle()
                }
                .tint(.orange)
            }
            
            ForEach(categories) { category in
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
