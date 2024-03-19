//
//  OnboardingGesturesTemplateView.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/03/13.
//

import SwiftUI

struct OnboardingGesturesTemplateView: View {
    @State private var categoryIsFavorite: Bool = false
    @State private var spendingDeleted: Bool = false
    
    var body: some View {
        List {
            categorySection
                .normalizePadding()
                .padding(.vertical, 1)
            
            if !spendingDeleted {
                spendingSection
                    .normalizePadding()
                    .padding(.vertical, 1)
            }
        }
    }
    
    private var categorySectionHeader: some View {
        VStack(alignment: .leading) {
            Text("Gestures")
                .font(.system(.largeTitle).bold())
                .foregroundColor(.primary)
            
            Text("You can perform quick actions like editing or deleting via swipe actions or by holding row")
                .font(.footnote)
                .foregroundColor(.secondary)
                .lineLimit(3)
        }
        .textCase(nil)
        .listRowInsets(.init(top: 50, leading: 0, bottom: 70, trailing: 0))
    }
    
    private var categorySection: some View {
        Section {
            HStack {
                Image(systemName: categoryIsFavorite ? "star.circle.fill" : "circle.fill")
                    .font(.title)
                    .foregroundColor(.nordRed)
                
                VStack(alignment: .leading) {
                    Text("Some category")
                        .foregroundColor(.primary)
                    
                    Text("\(spendingDeleted ? 9 : 10) expenses")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .swipeActions(edge: .trailing) {
                archiveButton
            }
            .swipeActions(edge: .leading) {
                favoriteButton
            }
            .contextMenu {
                favoriteButton
                
                archiveButton
            }
        } header: {
            categorySectionHeader
        }
    }
    
    private var archiveButton: some View {
        Button {} label: {
            Label("Archive", systemImage: "archivebox.fill")
        }
        .tint(.gray)
    }
    
    private var favoriteButton: some View {
        Button {
            withAnimation {
                categoryIsFavorite.toggle()
            }
        } label: {
            Label(
                categoryIsFavorite ? "Remove from favorites" : "Add to favorites",
                systemImage: categoryIsFavorite ? "star.slash.fill" : "star.fill"
            )
        }
        .tint(.yellow)
    }
    
    private var spendingSection: some View {
        var sum: Double {
            let sum = (10 * (Rates.fallback.rates[UserDefaults.standard.string(forKey: UDKeys.defaultCurrency) ?? Locale.current.currencyCode ?? "USD"] ?? 1))
            return sum.rounded(.toNearestOrAwayFromZero)
        }
        
        return Section {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Some category")
                        .font(.caption)
                        .foregroundColor(Color.secondary)
                    
                    Text("Some place")
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 5) {
                    Text(Date(), format: .dateTime.hour().minute())
                        .font(.caption)
                        .foregroundColor(Color.secondary)
                    
                    Text(sum.formatted(.currency(code: UserDefaults.standard.string(forKey: UDKeys.defaultCurrency) ?? Locale.current.currencyCode ?? "USD")))
                        .foregroundColor(.primary)
                }
            }
            .swipeActions(edge: .trailing) {
                deleteButton
                
                addReturnButton
            }
            .swipeActions(edge: .leading) {
                editButton
            }
            .contextMenu {
                editButton
                
                addReturnButton
                
                deleteButtonWithAnimation
            }
        } header: {
            Rectangle()
                .fill(Color(uiColor: .systemGroupedBackground))
                .frame(height: 30)
        }
    }
    
    private var deleteButtonWithAnimation: some View {
        Button(role: .destructive) {
            withAnimation {
                spendingDeleted = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    spendingDeleted = false
                }
            }
        } label: {
            Label("Delete", systemImage: "trash.fill")
        }
        .tint(.red)
    }
    
    private var deleteButton: some View {
        Button(role: .destructive) {
            spendingDeleted = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    spendingDeleted = false
                }
            }
        } label: {
            Label("Delete", systemImage: "trash.fill")
        }
        .tint(.red)
    }
    
    private var addReturnButton: some View {
        Button {} label: {
            Label("Add return", systemImage: "arrow.uturn.backward")
        }
        .tint(.yellow)
    }
    
    private var editButton: some View {
        Button {} label: {
            Label("Edit", systemImage: "pencil")
        }
        .tint(.orange)
    }
}

#if DEBUG
struct OnboardingGesturesTemplateViewPreviews: PreviewProvider {
    static var previews: some View {
        OnboardingPreview()
    }
}

fileprivate struct OnboardingPreview: View {
    @State var showSheet: Bool = true
    
    var body: some View {
        NavigationView {
            Button {
                showSheet.toggle()
            } label: {
                Rectangle()
                    .foregroundColor(.secondary)
            }
        }
        .sheet(isPresented: $showSheet) {
            OnboardingView()
                .environmentObject(CoreDataModel())
                .accentColor(.orange)
        }
    }
}
#endif
