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
        GeometryReader { geometry in
            VStack(spacing: 0) {
                header
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.top, 40)
                
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
                .overlay(alignment: .top) {
                    LinearGradient(
                        colors: [Color(uiColor: .systemGroupedBackground), Color(uiColor: .systemGroupedBackground).opacity(0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(width: geometry.size.width, height: 20)
                }
            }
            .background(Color(uiColor: .systemGroupedBackground), ignoresSafeAreaEdges: .all)
        }
    }
    
    private var header: some View {
        OnboardingHeaderView(header: "Gestures", description: "You can perform quick actions like editing or deleting via swipe actions or by holding row")
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
        var sum: Decimal {
            let sum = (10 * (Rates.fallback.rates[UserDefaults.standard.string(forKey: UDKeys.defaultCurrency.rawValue) ?? Locale.current.currencyCode ?? "USD"] ?? 1))
            let count = "\(Int(sum))".count
            return pow(10, count - 1)
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
                    
                    Text(sum.formatted(.currency(code: UserDefaults.standard.string(forKey: UDKeys.defaultCurrency.rawValue) ?? Locale.current.currencyCode ?? "USD")))
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
                .interactiveDismissDisabled()
        }
    }
}
#endif
