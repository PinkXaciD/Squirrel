//
//  OnboardingView.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/03/13.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var cdm: CoreDataModel
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], predicate: NSPredicate(format: "isShadowed = false"))
    private var categories: FetchedResults<CategoryEntity>
    
    @State private var screen: Int = 0
    @State private var selectedCurrency: String = UserDefaults.standard.string(forKey: UDKey.defaultCurrency.rawValue) ?? Locale.current.currencyCode ?? "USD"
    @State private var showOverlay: Bool = false
    @State private var transition: AnyTransition = .horizontalMoveForward
    
    let finalScreenNumber: Int = 4
    let addSampleData: Bool = false
    
    var continueButtonText: LocalizedStringKey {
        if screen == finalScreenNumber {
            return "Done"
        }
        
        if screen ==   2 && categories.isEmpty && addSampleData {
            return "Continue with sample data"
        }
        
        return "Continue"
    }
    
    var body: some View {
        Group {
            switch screen {
            case 0:
                screen0
                    .transition(transition)
                    .animation(.smooth, value: screen)
            case 1:
                screen1
                    .transition(transition)
                    .animation(.smooth, value: screen)
            case 2:
                screen2
                    .transition(transition)
                    .animation(.smooth, value: screen)
            case 3:
                screen3
                    .transition(transition)
                    .animation(.smooth, value: screen)
            case 4:
                screen4
                    .transition(transition)
                    .animation(.smooth, value: screen)
            default:
                EmptyView()
            }
        }
        .overlay(alignment:.topLeading) {
            if screen > 1, showOverlay {
                if #available(iOS 26.0, *) {
                    newBackButton
                } else {
                    backButton
                }
            }
        }
        .overlay(alignment: .bottom) {
            ZStack(alignment: .bottom) {
                if showOverlay {
                    gradient
                        .frame(maxHeight: 80)
                        .transition(.move(edge: .bottom))
                        .zIndex(0)
                    
                    continueButton
                        .padding(.horizontal, 30)
                        .zIndex(1)
                        .padding(.bottom, 30)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.smooth, value: showOverlay)
            .ignoresSafeArea(.keyboard)
        }
        .ignoresSafeArea(.container)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                showOverlay = true
            }
        }
    }
    
    private var gradient: LinearGradient {
        let colors = [
            Color(uiColor: .systemGroupedBackground).opacity(0),
            Color(uiColor: .systemGroupedBackground)
        ]
        
//        let debugColors = [
//            Color.red,
//            Color.purple
//        ]
        
        return LinearGradient(colors: colors, startPoint: .top, endPoint: .center)
    }
    
    private var skipButton: some View {
        Button("Skip") {
            dismiss()
        }
        .padding(.vertical, 5)
    }
    
    private var backButton: some View {
        Button("Back") {
            backButtonAction()
        }
        .tint(.orange)
        .accentColor(.orange)
        .transition(.opacity)
        .padding(.vertical, 9)
        .padding(.horizontal, 10)
        .contentShape(.hoverEffect, RoundedRectangle(cornerRadius: 5))
        .hoverEffect(.automatic)
        .background(Color(uiColor: .systemGroupedBackground).opacity(0.0001))
        .padding(8)
    }
    
    @available(iOS 26.0, *)
    private var newBackButton: some View {
        Button("Back") {
            backButtonAction()
        }
        .tint(.orange)
        .accentColor(.orange)
        .transition(.opacity)
        .padding(.vertical, 9)
        .padding(.horizontal, 10)
        .buttonStyle(.glass)
        .hoverEffect(.automatic)
        .padding(12)
    }
    
    private var continueButton: some View {
        Button {
            continueButtonAction()
        } label: {
            continueButtonLabel
        }
        .frame(maxHeight: 50)
        .contentShape(.hoverEffect, Capsule())
        .hoverEffect(.automatic)
        .addLiquidGlass()
    }
    
    private var continueButtonLabel: some View {
        ZStack {
            Capsule()
                .foregroundColor(.orange)
            
            Text(continueButtonText)
                .foregroundColor(.white)
                .font(.body.bold())
        }
    }
    
    private func continueButtonAction() {
        transition = .horizontalMoveForward
        
        if screen == 1 {
            UserDefaults.standard.addCurrency(selectedCurrency)
            
            UserDefaults.standard.set(selectedCurrency, forKey: UDKey.defaultCurrency.rawValue)
            UserDefaults.standard.set(selectedCurrency, forKey: UDKey.defaultSelectedCurrency.rawValue)
            UserDefaults.standard.set(false, forKey: UDKey.separateCurrencies.rawValue)
            
            if let defaults = UserDefaults(suiteName: Vars.groupName) {
                defaults.set(selectedCurrency, forKey: "defaultCurrency")
                cdm.passSpendingsToSumWidget()
            }
        }
        
        if screen == 2 && categories.isEmpty && addSampleData {
            DispatchQueue.main.async {
                cdm.addTemplateData()
            }
        }
        
        if screen < finalScreenNumber {
            withAnimation {
                screen += 1
            }
        } else {
            dismiss()
        }
    }
    
    private func backButtonAction() {
        if screen > 1 {
            transition = .horizontalMoveBackward
            
            withAnimation {
                screen -= 1
            }
        }
    }
    
    private var screen0: some View {
        OnboardingWelcomeView()
    }
    
    private var screen1: some View {
        OnboardingCurrencyView(showOverlay: $showOverlay, selectedCurrency: $selectedCurrency)
    }
    
    private var screen2: some View {
        OnboardingCategoriesView(showOverlay: $showOverlay, screen: $screen)
            .environmentObject(cdm)
    }
    
    private var screen3: some View {
        OnboardingCloudSyncView()
            .tint(.orange)
    }
    
    private var screen4: some View {
        OnboardingGesturesTemplateView()
    }
}

fileprivate extension View {
    @ViewBuilder
    func addLiquidGlass() -> some View {
        if #available(iOS 26, *) {
            self.glassEffect(.clear.interactive())
        } else {
            self
        }
    }
}

#if DEBUG
struct OnboardingViewPreviews: PreviewProvider {
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
