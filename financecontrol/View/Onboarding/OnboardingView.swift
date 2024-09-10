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
    
    @State private var screen: Int = 0
    @State private var selectedCurrency: String = UserDefaults.standard.string(forKey: UDKeys.defaultCurrency.rawValue) ?? Locale.current.currencyCode ?? "USD"
    @State private var showOverlay: Bool = false
    @State private var transition: AnyTransition = .horizontalMoveForward
    
    let finalScreenNumber: Int = 3
    let addSampleData: Bool = true
    
    var continueButtonText: LocalizedStringKey {
        if screen == finalScreenNumber {
            return "Done"
        }
        
        if screen ==   2 && cdm.savedCategories.isEmpty && addSampleData {
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
            default:
                EmptyView()
            }
        }
        .overlay(alignment:.topLeading) {
            if screen > 1, showOverlay {
                backButton
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
    
    private var continueButton: some View {
        Button {
            continueButtonAction()
        } label: {
            continueButtonLabel
        }
        .frame(maxHeight: 50)
        .contentShape(.hoverEffect, Capsule())
        .hoverEffect(.automatic)
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
            
            UserDefaults.standard.set(selectedCurrency, forKey: UDKeys.defaultCurrency.rawValue)
            UserDefaults.standard.set(selectedCurrency, forKey: UDKeys.defaultSelectedCurrency.rawValue)
            UserDefaults.standard.set(false, forKey: UDKeys.separateCurrencies.rawValue)
            
            if let defaults = UserDefaults(suiteName: Vars.groupName) {
                defaults.set(selectedCurrency, forKey: "defaultCurrency")
                cdm.passSpendingsToSumWidget(data: cdm.statsListData)
            }
        }
        
        if screen == 2 && cdm.savedCategories.isEmpty && addSampleData {
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
        OnboardingGesturesTemplateView()
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
