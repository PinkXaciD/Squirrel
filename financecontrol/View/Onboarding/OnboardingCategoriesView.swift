//
//  OnboardingCategoriesView.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/03/13.
//

import SwiftUI

struct OnboardingCategoriesView: View {
    @Binding var showOverlay: Bool
    @EnvironmentObject private var cdm: CoreDataModel
    
    var body: some View {
        NavigationView {
            List {
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
                    VStack(alignment: .leading) {
                        Text("Add categories")
                            .font(.largeTitle.bold())
                        
                        Text("You can add categories later in settings")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .textCase(nil)
                    .foregroundColor(.primary)
                    .listRowInsets(.init(top: 50, leading: 0, bottom: 20, trailing: 0))
                }
                
                Section {
                    ForEach(cdm.savedCategories) { category in
                        HStack {
                            Image(systemName: category.isFavorite ? "star.circle.fill" : "circle.fill")
                                .font(.title)
                                .foregroundColor(Color[category.color ?? ""])
                            
                            Text(category.name ?? "Error")
                                .padding(.vertical)
                        }
                    }
                } footer: {
                    Rectangle()
                        .fill(Color(uiColor: .systemGroupedBackground))
                        .frame(height: 125)
                }
            }
            .navigationBarHidden(true)
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
}
