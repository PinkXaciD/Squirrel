//
//  CustomAlertView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/10/24.
//

import SwiftUI

struct CustomAlertView: View {
    var data: CustomAlertData
    @StateObject private var viewModel: CustomAlertViewModel
    @State private var animate: Bool = false
    
    var body: some View {
        Group {
            if #available(iOS 26.0, *) {
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.black.opacity(0.001))
                    
                    content
                }
                .glassEffect(.regular.tint(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.5)).interactive(), in: RoundedRectangle(cornerRadius: 30))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Material.regular)
                        .shadow(color: .black.opacity(0.1), radius: 5)
                    
                    content
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 80)
        .padding(.horizontal)
        .onAppear {
            withAnimation(.bouncy) {
                self.animate = true
            }
        }
        .onTapGesture {
            withAnimation(.bouncy) {
                CustomAlertManager.shared.removeAlert(data.id)
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.predictedEndTranslation.height < -5 {
                        withAnimation(.bouncy) {
                            CustomAlertManager.shared.removeAlert(data.id)
                        }
                    }
                }
        )
        .transition(.opacity.combined(with: .scale).combined(with: .move(edge: .top)))
    }
    
    private var content: some View {
        HStack(spacing: 0) {
            Image(systemName: data.systemImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(animate ? 1 : 0.1)
                .foregroundColor(data.type.color)
                .padding()
            
            HStack {
                VStack(alignment: .leading) {
                    Text(data.title)
                        .fontWeight(.bold)
                        .minimumScaleFactor(0.5)
                    
                    if let description = data.description {
                        Text(description)
                            .lineLimit(2)
                            .minimumScaleFactor(0.5)
                    }
                }
                .padding(.vertical, 5)
                
                Spacer()
            }
        }
    }
    
    init(data: CustomAlertData) {
        self.data = data
        self._viewModel = StateObject(wrappedValue: .init(id: data.id, haptic: data.type.haptic))
    }
}

#if DEBUG
#Preview {
    VStack {
        CustomAlertView(data: .init(type: .error, title: "Error", description: "Description.", systemImage: "xmark.circle"))
        CustomAlertView(data: .init(type: .warning, title: "Warning", description: "Description.", systemImage: "exclamationmark.circle"))
        CustomAlertView(data: .init(type: .success, title: "Success", description: "Description.", systemImage: "checkmark.circle"))
        CustomAlertView(data: .init(type: .info, title: "Info", description: "Description.", systemImage: "questionmark.circle"))
    }
}
#endif
