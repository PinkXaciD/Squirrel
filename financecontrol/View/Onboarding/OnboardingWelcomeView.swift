//
//  OnboardingWelcomeView.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/03/13.
//

import SwiftUI

struct OnboardingWelcomeView: View {
    @State private var showIcon: Bool = false
    @State private var showUpperText: Bool = false
    @State private var showBottomText: Bool = false
    @State private var rotateIcon: Bool = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                if showIcon {
                    Image(.onboarding)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .overlay {
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(lineWidth: 1)
                                .foregroundColor(.primary)
                                .opacity(0.3)
                        }
                        .hoverEffect(.lift)
                        .padding(.vertical)
                        .transition(.moveFromBottom)
                        .rotationEffect(.degrees(rotateIcon ? 720 : 0), anchor: .center)
                        .onTapGesture(count: 3) {
                            withAnimation(.bouncy(duration: 1)) {
                                rotateIcon.toggle()
                            }
                            
                            HapticManager.shared.impact(.rigid)
                        }
                }
                
                if showUpperText {
                    Text("Welcome to")
                        .font(.system(size: 50, weight: .heavy))
                        .transition(.moveFromBottom)
                }
                
                if showBottomText {
                    Text("Squirrel")
                        .foregroundColor(.orange)
                        .font(.system(size: 60, weight: .black))
                        .padding(.vertical, -10)
                        .transition(.moveFromBottom)
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 70)
            
            Spacer()
        }
        .frame(maxHeight: .infinity)
        .background {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea(.all)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            }
        }
        .onAppear {
            playAnimation()
        }
    }
    
    private func playAnimation() {
        withAnimation(.smooth) {
            showIcon = true
        }
        
        withAnimation(.smooth.delay(0.5)) {
            showUpperText = true
        }
            
        withAnimation(.smooth.delay(0.6)) {
            showBottomText = true
        }
        
        HapticManager.shared.impact(.light)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            HapticManager.shared.impact(.light)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            HapticManager.shared.impact(.light)
        }
    }
}

struct OnboardingWelcomeViewPreviews: PreviewProvider {
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
