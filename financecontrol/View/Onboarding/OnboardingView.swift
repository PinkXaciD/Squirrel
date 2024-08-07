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
    @State private var showOverlay: Bool = true
    
    let finalScreenNumber: Int = 3
    let addSampleData: Bool = false
    
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
            ZStack(alignment: .bottom) {
                if showOverlay {
                    gradient
                        .frame(maxHeight: 80)
                        .transition(.move(edge: .bottom))
                        .zIndex(0)
                    
                    VStack {
                        continueButton
                            .padding(.horizontal, 30)
                    }
                    .zIndex(1)
                    .padding(.bottom, 30)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.smooth, value: showOverlay)
            .ignoresSafeArea(.keyboard)
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
                UserDefaults.standard.addCurrency(selectedCurrency)
                
                UserDefaults.standard.setValue(selectedCurrency, forKey: UDKeys.defaultCurrency.rawValue)
                
                UserDefaults.standard.setValue(selectedCurrency, forKey: UDKeys.defaultSelectedCurrency.rawValue)
                
                UserDefaults.standard.setValue(false, forKey: UDKeys.separateCurrencies.rawValue)
                
                if let defaults = UserDefaults(suiteName: Vars.groupName) {
                    defaults.set(selectedCurrency, forKey: "defaultCurrency")
                    cdm.passSpendingsToSumWidget()
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
        } label: {
            ZStack {
                Capsule()
                    .foregroundColor(.orange)
                    .frame(maxHeight: 50)
                
                HStack(spacing: 0) {
                    Text(screen == finalScreenNumber ? "Done" : "Continue")
                        .foregroundColor(.white)
                        .font(.body.bold())
                    
                    if screen == 2 && cdm.savedCategories.isEmpty && addSampleData {
                        Text(verbatim: " with sample data")
                            .foregroundColor(.white)
                            .font(.body.bold())
                            .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
                            .animation(.easeInOut.speed(1.5), value: screen)
                    }
                }
            }
            .hoverEffect(.highlight)
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
    
    private func getButtonText() -> LocalizedStringKey {
        switch screen {
        case finalScreenNumber:
            "Done"
        default:
            "Continue"
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
