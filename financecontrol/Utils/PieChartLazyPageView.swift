//
//  LazyPageView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 6/01/31.
//

import SwiftUI

#if DEBUG
import OSLog
#endif

struct PieChartLazyPageView<Content: View>: View {
    @Environment(\.layoutDirection) private var layoutDirection
    @EnvironmentObject private var vm: PieChartViewModel
    let size: CGFloat
    
    init(viewSize: CGFloat) {
        self.size = viewSize
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $vm.selection) {
                ForEach(vm.content.indices, id: \.self) { index in
                    LazyTab(content: vm.content[index], selection: $vm.selection, count: index)
                        .invertLayoutDirection()
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            buttons
        }
    }
    
    private var buttons: some View {
        HStack {
            getButton(isLeading: true)
            
            Spacer(minLength: size)
            
            getButton(isLeading: false)
        }
        .foregroundColor(.accentColor)
        .buttonStyle(.plain)
        .font(.largeTitle)
    }
    
    private func getButton(isLeading: Bool) -> some View {
        ZStack(alignment: .center) {
            getGradient(isLeading: layoutDirection == .leftToRight ? isLeading : !isLeading)
                .frame(width: 50)
            
            Button {
                isLeading ? decreaseSelected() : increaseSelected()
            } label: {
                Image(systemName: isLeading ? "chevron.backward" : "chevron.forward")
            }
            .disabled(isLeading ? vm.selection <= 0 : vm.selection >= vm.content.count - 1)
        }
    }
    
    private func increaseSelected() {
        withAnimation {
            vm.selection += 1
        }
    }
    
    private func decreaseSelected() {
        withAnimation {
            vm.selection -= 1
        }
    }
    
    private func getGradient(isLeading: Bool) -> LinearGradient {
        return LinearGradient(
            colors: [
                .init(uiColor: .secondarySystemGroupedBackground),
                .init(uiColor: .secondarySystemGroupedBackground).opacity(0)
            ],
            startPoint: isLeading ? .leading : .trailing,
            endPoint: isLeading ? .trailing : .leading
        )
    }
}

fileprivate struct LazyTab<Content: View>: View {
    var content: Content
    @Binding var selection: Int
    let count: Int
    
    #if DEBUG
    let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
    #endif
    
    enum ViewState {
        case inactive, active
        
        #if DEBUG
        var rawValue: String {
            switch self {
            case .inactive:
                "Inactive"
            case .active:
                "Active"
            }
        }
        #endif
    }
    
    @State
    private var viewState: ViewState = .inactive
    
    var body: some View {
        let range: ClosedRange<Int> = count - 1...count + 1
        
        VStack {
            switch viewState {
            case .inactive:
                EmptyView()
            case .active:
                content
            }
        }
        .onAppear {
            if range.contains(selection) {
                viewState = .active
            }
        }
        .onChange(of: selection) { newValue in
            if range.contains(newValue) {
                withAnimation {
                    viewState = .active
                }
            } else {
                viewState = .inactive
            }
        }
    }
}
