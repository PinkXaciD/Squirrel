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
    @State private var selectedCurrency: String = UserDefaults.standard.string(forKey: UDKeys.defaultCurrency) ?? Locale.current.currencyCode ?? "USD"
    @State private var showOverlay: Bool = true
    
    let finalScreenNumber: Int = 3
    
    var body: some View {
        Group {
            switch screen {
            case 0:
                screen0
                    .transition(.horizontalMove)
                    .animation(.smooth, value: screen)
            case 1:
                screen1
                    .transition(.horizontalMove)
                    .animation(.smooth, value: screen)
            case 2:
                screen2
                    .transition(.horizontalMove)
                    .animation(.smooth, value: screen)
            case 3:
                screen3
                    .transition(.horizontalMove)
                    .animation(.smooth, value: screen)
            default:
                EmptyView()
            }
        }
        .overlay(alignment: .bottom) {
//            if showOverlay {
                ZStack(alignment: .bottom) {
                    if showOverlay {
                        gradient
                            .frame(maxHeight: 80)
                            .transition(.move(edge: .bottom))
                            .zIndex(0)
                        
                        VStack {
                            continueButton
                                .padding(.horizontal, 30)
                            
    //                        if screen > 1 && screen < finalScreenNumber {
    //                            skipButton
    //                        }
                        }
                        .zIndex(1)
                        .padding(.bottom, 30)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
//                .transition(.move(edge: .bottom).combined(with: .scale))
                .animation(.smooth, value: showOverlay)
                
//            }
        }
        .ignoresSafeArea(.container)
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
    
    private var continueButton: some View {
        Button {
            if screen == 1 {
                if selectedCurrency != Locale.current.currencyCode {
                    UserDefaults.standard.setValue(selectedCurrency, forKey: UDKeys.defaultCurrency)
                }
                
                if cdm.savedCurrencies.isEmpty {
                    cdm.addCurrency(tag: selectedCurrency, isFavorite: true)
                }
                
                if let defaults = UserDefaults(suiteName: Vars.groupName) {
                    defaults.set(selectedCurrency, forKey: "defaultCurrency")
                    cdm.passSpendingsToSumWidget()
                }
            }
            
            if screen < finalScreenNumber {
                withAnimation {
                    screen += 1
                }
            } else {
                dismiss()
            }
        } label: {
            ZStack {
                Capsule()
                    .foregroundColor(.orange)
                    .frame(maxHeight: 50)
                
                Text(screen == finalScreenNumber ? "Done" : "Continue")
                    .foregroundColor(.white)
                    .font(.body.bold())
            }
        }
    }
    
    private var screen0: some View {
        OnboardingWelcomeView()
    }
    
    private var screen1: some View {
        OnboardingCurrencyView(selectedCurrency: $selectedCurrency, showOverlay: $showOverlay)
    }
    
    private var screen2: some View {
        OnboardingCategoriesView(showOverlay: $showOverlay)
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
