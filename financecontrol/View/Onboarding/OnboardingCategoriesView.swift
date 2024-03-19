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
            List {
                addSection
                
                categoriesSection
            }
            .fileImporter(isPresented: $presentImportSheet, allowedContentTypes: [.json]) { result in
                importJSON(result)
            }
            .navigationBarHidden(true)
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading) {
            Text("Add categories")
                .font(.largeTitle.bold())
            
            Text("You can add categories later in settings")
                .font(.footnote)
                .foregroundColor(.secondary)
                .lineLimit(3)
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
            }
        } header: {
            header
        }
    }
    
    private var categoriesSection: some View {
        Section {
            if cdm.savedCategories.isEmpty {
                Button("Import existing data") {
                    presentImportSheet.toggle()
                }
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
        } footer: {
            Rectangle()
                .fill(Color(uiColor: .systemGroupedBackground))
                .frame(height: 80)
        }
    }
    
    private func getRow(name: String) -> some View {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]
        
        return HStack {
            Image(systemName: "circle.fill")
                .font(.title)
                .foregroundStyle(.tertiary)
            
            Text(name)
                .foregroundStyle(.primary)
                .padding(.vertical)
        }
        .foregroundStyle(Color.primary, Color.secondary, colors.randomElement()!)
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
