//
//  ICloudLogoAnimatedView.swift
//  Squirrel
//
//  Created by PinkXaciD on 2025/01/11.
//

import SwiftUI

struct ICloudLogoAnimatedView: View {
    @State
    private var animate: Bool = false
    let isEnabled: Bool
    
    init(isEnabled: Bool, scale: CGFloat = 1) {
        self.isEnabled = isEnabled
        self.scale = scale
        self.frameScale = scale
    }
    
    @State
    var scale: CGFloat
    let frameScale: CGFloat
    let minFrame: CGFloat = 0
    
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 50 * scale)
                .frame(
                    width: animate ? 245 * scale : minFrame,
                    height: animate ? 100 * scale : minFrame
                )
                .offset(
                    x: animate ? 0.50 * scale : 0,
                    y: animate ? 34.50 * scale : 0
                )
                .animation(.bouncy(extraBounce: 0.1), value: animate)
                .animation(.bouncy(extraBounce: 0.2), value: scale)
            
            Circle()
                .frame(
                    width: animate ? 139 * scale : minFrame,
                    height: animate ? 139 * scale : minFrame
                )
                .offset(
                    x: animate ? 21.50 * scale : 0,
                    y: animate ? -15.50 * scale : 0
                )
                .animation(.bouncy(extraBounce: 0.15), value: animate)
                .animation(.bouncy(extraBounce: 0.3).delay(0.05), value: scale)
            
            Circle()
                .frame(
                    width: animate ? 77 * scale : minFrame,
                    height: animate ? 77 * scale : minFrame
                )
                .offset(
                    x: animate ? -47.50 * scale : 0,
                    y: animate ? -17 * scale : 0
                )
                .animation(.bouncy(extraBounce: 0.2), value: animate)
                .animation(.bouncy(extraBounce: 0.35).delay(0.025), value: scale)
        }
        .overlay {
            Group {
                if isEnabled {
                    Image(systemName: "checkmark")
                        .resizable()
                        .font(.largeTitle.bold())
                        .foregroundStyle(.background)
                        .scaledToFit()
                        .frame(height: 169 * 0.5)
                        .scaleEffect(scale)
                        .padding(.top, 20 * frameScale)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.bouncy(extraBounce: 0.1).delay(0.1), value: animate)
            .animation(.bouncy(extraBounce: 0.2).delay(0.1), value: scale)
            .animation(.bouncy, value: isEnabled)
        }
        .frame(width: 244 * frameScale, height: 169 * frameScale)
        .foregroundStyle(.tint)
        .onAppear {
            animate = true
        }
        .onReceive(timer) { _ in
            scale -= 0.1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                scale += 0.1
            }
        }
        .scaleEffect(animate ? 1 : 0.5)
        .onChange(of: isEnabled) { newValue in
            if newValue {
                scale -= 0.1
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    scale += 0.1
                }
            }
        }
    }
}

#Preview {
    ICloudLogoAnimatedView(isEnabled: true, scale: 1)
}
