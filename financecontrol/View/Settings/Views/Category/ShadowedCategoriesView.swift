//
//  ShadowedCategoriesView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/30.
//

import SwiftUI

struct ShadowedCategoriesView: View {
    @EnvironmentObject var cdm: CoreDataModel
    
    @State private var alertIsShowing: Bool = false
    
    var body: some View {
        if !cdm.shadowedCategories.isEmpty {
            List {
                ForEach(cdm.shadowedCategories) { category in
                    ShadowedCategoriesRow(category: category)
                }
            }
            .navigationTitle("Archived categories")
            
        } else {
            Text("No archived categories")
                .font(.title2)
                .fontWeight(.semibold)
                .navigationTitle("Archived categories")
        }
    }
}

struct ShadowedCategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        ShadowedCategoriesView()
            .environmentObject(CoreDataModel())
    }
}
