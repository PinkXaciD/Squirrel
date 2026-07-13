//
//  CategoriesEditView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/27.
//

import SwiftUI
import Beige

struct CategoriesEditView: View {
    @Environment(\.colorScheme)
    private var colorScheme
    @Environment(\.colorSchemeContrast)
    private var colorSchemeContrast
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], predicate: NSPredicate(format: "isShadowed == false"), animation: .default)
    private var categories: FetchedResults<CategoryEntity>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], predicate: NSPredicate(format: "isShadowed == true"), animation: .default)
    private var shadowedCategories: FetchedResults<CategoryEntity>
    
    private var usedColors: [OKLCH] {
        var result = Set<OKLCH>()
        
        for category in categories {
            if let categoryColor = category.color, let hueValue = Double(categoryColor) {
                result.insert(.init(lightness: colorScheme == .light ? CategoryColorValues.lightModeLightness : CategoryColorValues.darkModeLightness, chroma: CategoryColorValues.chroma, hue: hueValue))
            }
        }
        
        let resultArray = result.sorted { val1, val2 in
            val1.h < val2.h
        }
        
        return resultArray
    }
    
    private var unusedColors: [Double] {
        if usedColors.isEmpty {
            return []
        }
        
        var lastHue: Double = 0
        var result: [Double] = []
        
        for color in usedColors {
            guard color.h != lastHue, color.h - lastHue > 5 else {
                continue
            }
            
            result.append((color.h - lastHue) / 2 + lastHue)
            lastHue = color.h
        }
        
        if lastHue <= 355, !result.isEmpty {
            result.append((360 - lastHue) / 2 + lastHue)
        }
        
        return result
    }
    
    var body: some View {
        if #available(iOS 26.0, *) {
            content
                .toolbar {
                    ToolbarItem {
                        shadowedCategoriesToolbarButton
                    }
                    
                    ToolbarSpacer(.fixed)

                    ToolbarItem {
                        addNewToolbarButton
                    }
                }
        } else {
            content
                .toolbar {
                    ToolbarItem {
                        shadowedCategoriesToolbarButton
                    }

                    ToolbarItem {
                        addNewToolbarButton
                    }
                }
        }
    }
    
    private var content: some View {
        List {
            if !categories.isEmpty {
                Section {
                    ForEach(categories) { entity in
                        CategoryRow(category: entity, usedColors: usedColors, unusedColors: unusedColors)
                    }
                }
            } else {
                CustomContentUnavailableView(
                    "No Categories",
                    imageName: "list.bullet",
                    description: "You can add categories below."
                )
                .listRowInsets(.init(top: 20, leading: 0, bottom: 20, trailing: 0))
                .frame(maxWidth: .infinity)
                .listRowBackground(EmptyView())
            }
            
            manageCategoriesSection
        }
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var manageCategoriesSection: some View {
        Section {
            NavigationLink("Add New") {
                AddCategoryView(selectedCategory: .constant(.init()), insert: false, colors: usedColors, unusedColors: unusedColors)
            }
            
            NavigationLink {
                ShadowedCategoriesView(categories: shadowedCategories)
            } label: {
                HStack {
                    Text("Archived Categories")
                    Spacer()
                    Text(shadowedCategories.count.formatted())
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private var addNewToolbarButton: some View {
        NavigationLink {
            AddCategoryView(selectedCategory: .constant(.init()), insert: false, colors: usedColors, unusedColors: unusedColors)
        } label: {
            Label("Add new category", systemImage: "plus")
        }
    }
    
    private var shadowedCategoriesToolbarButton: some View {
        NavigationLink {
            ShadowedCategoriesView(categories: shadowedCategories)
        } label: {
            Label("Archived categories", systemImage: "archivebox")
        }
    }
}

struct CategoriesEditView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesEditView()
            .environmentObject(CoreDataModel())
    }
}
