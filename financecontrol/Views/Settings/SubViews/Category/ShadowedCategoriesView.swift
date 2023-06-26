//
//  ShadowedCategoriesView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/30.
//

import SwiftUI

struct ShadowedCategoriesView: View {
    
    @EnvironmentObject var vm: CoreDataViewModel
    
    @State private var alertIsShowing: Bool = false
    
    var body: some View {
        
        List {
            
            if vm.shadowedCategories != [] {
                
                ForEach(vm.shadowedCategories) { category in
                    
                    HStack {
                        
                        Image(systemName: "circle.fill")
                            .foregroundColor(Color[category.color ?? ""])
                        
                        Text(category.name ?? "Error")
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        
                        Button(role: .destructive) {
                            vm.deleteCategory(category)
                        } label: {
                            Label("Delete", systemImage: "trash.fill")
                        }
                        .tint(Color.red)
                    }
                    .swipeActions(edge: .leading) {
                        
                        Button {
                            vm.changeShadowStateOfCategory(category)
                        } label: {
                            Label("Restore", systemImage: "arrow.uturn.backward")
                        }
                        .tint(Color.green)
                    }
                }
                
            } else {
                
                Text("No deleted categories")
                    .font(Font.body.weight(.semibold))
            }
        }
        .navigationTitle("Deleted categories")
    }
}

struct ShadowedCategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        ShadowedCategoriesView()
            .environmentObject(CoreDataViewModel())
    }
}
