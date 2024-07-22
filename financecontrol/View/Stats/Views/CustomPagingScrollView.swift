//
//  CustomPagingScrollView.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/05/08.
//

import SwiftUI
import ApplePie
import Combine

#if DEBUG
import OSLog
let logger = Logger(subsystem: Vars.appIdentifier, category: #fileID)
#endif

struct CustomPagingScrollView: View {
    @Binding var selection: Int
    let data: [ChartData]
    let invert: Bool
    let viewScale: CGFloat
    
    init(selection: Binding<Int>, data: [ChartData], invert: Bool = false, viewScale: CGFloat = 0.5) {
        self._selection = selection
        self.data = data
        self.invert = invert
        
        if viewScale > 1 {
            self.viewScale = 1
        } else if viewScale < 0 {
            self.viewScale = 0
        } else {
            self.viewScale = viewScale
        }
        
//        print("ParentView \(selection.wrappedValue) init") // TODO: Remove
    }
    
    var body: some View {
        GeometryReader { geometry in
            InternalCustomPagingScrollView(
                selection: $selection,
                data: data,
                geometry: geometry,
                invert: invert,
                viewScale: viewScale
            )
        }
        .invertLayoutDirection(invert)
    }
}

fileprivate struct InternalCustomPagingScrollView: View {
    @Environment(\.layoutDirection) private var layoutDirection
    @EnvironmentObject private var fvm: FiltersViewModel
    
    @Binding private var selection: Int
    @StateObject private var scrollManager: PagingScrollViewManager
    @State private var reset: Bool = false
    let data: [ChartData]
    
    let scrollAnimation: Animation = .smooth(duration: 0.3)
    
    init(selection: Binding<Int>, data: [ChartData], geometry: GeometryProxy, invert: Bool, viewScale: CGFloat) {
        self._selection = selection
        self.data = data
        self._scrollManager = StateObject(wrappedValue: PagingScrollViewManager(geometry: geometry, viewScale: viewScale, invertedViewScale: 1 - viewScale, invert: invert))
        
//        print("ChildView \(selection.wrappedValue) init") // TODO: Remove
    }
    
    var body: some View {
        VStack {
            HStack(spacing: scrollManager.geometry.size.width * scrollManager.invertedViewScale) {
                ForEach(data, id: \.id) { element in
                    if (selection > -element.id - 2 && selection < -element.id + 2) {
                        PieChartCompleteView(data: element, size: self.scrollManager.geometry.size.width * self.scrollManager.viewScale)
                            .frame(width: scrollManager.geometry.size.width * scrollManager.viewScale, height: scrollManager.geometry.size.height)
                            .invertLayoutDirection(scrollManager.invert)
                    } else {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: scrollManager.geometry.size.width * scrollManager.viewScale, height: scrollManager.geometry.size.height)
                            .invertLayoutDirection(scrollManager.invert)
                    }
                }
            }
            .padding(.horizontal, scrollManager.geometry.size.width * scrollManager.invertedViewScale * 0.5)
//            .background(Color.red)
            .offset(x: scrollManager.hOffset)
            .onAppear {
//                print("Appeared") // TODO: Remove
                let viewOffset = self.countViewOffset(selection + 1)
                if abs(viewOffset) > (self.scrollManager.geometry.size.width * CGFloat(data.count - 1)) {
                    resetOffsets()
                } else {
                    self.scrollManager.hOffset = viewOffset
                    self.scrollManager.oldHOffset = self.scrollManager.hOffset
                }
            }
            .onChange(of: data) { newValue in
//                print("CHANGED") // TODO: Remove
                let maxOffset = self.scrollManager.geometry.size.width * CGFloat(newValue.count - 1)
//                print("Max offset: \(maxOffset), current offset: \(self.scrollManager.hOffset), data count: \(data.count), new data count: \(newValue.count)") // TODO: Remove
                if abs(self.scrollManager.hOffset) > (maxOffset) {
                    setLastOffset(count: newValue.count)
                }
            }
            .onChange(of: fvm.applyFilters) { newValue in
                if newValue, scrollManager.hOffset != 0 {
                    scrollManager.resetOffsets()
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        changedDragGesture(value: value)
                    }
                    .onEnded { value in
                        endDragGesture(value: value)
                    }
            )
            .gesture(
                RotationGesture()
                    .onChanged{ _ in
                        breakGesture()
                    }
            )
            .gesture(
                MagnificationGesture()
                    .onChanged { _ in
                        breakGesture()
                    }
            )
            .gesture(
                TapGesture()
                    .onEnded { _ in
                        breakGesture()
                    }
            )
        }
        .overlay(alignment: .center) {
            HStack {
                Button {
                    scrollToPrevious()
                } label: {
                    ZStack {
                        getGradient(isLeading: layoutDirection == .leftToRight)
                            .frame(width: scrollManager.geometry.size.width * scrollManager.invertedViewScale * 0.5)
                        
                        Image(systemName: "chevron.backward")
                            .foregroundColor(.accentColor)
                    }
                }
                .disabled(selection < 1)
                .buttonStyle(.plain)
                
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: scrollManager.geometry.size.width * scrollManager.viewScale)
                
                Button {
                    scrollToNext()
                } label: {
                    ZStack {
                        getGradient(isLeading: layoutDirection != .leftToRight)
                            .frame(width: scrollManager.geometry.size.width * scrollManager.invertedViewScale * 0.5)
                        
                        Image(systemName: "chevron.forward")
                            .foregroundColor(.accentColor)
                    }
                }
                .disabled(selection >= data.count - 1)
                .buttonStyle(.plain)
            }
            .font(.largeTitle.bold())
            .offset(x: (-scrollManager.geometry.size.width * CGFloat(data.count) * 0.5 + scrollManager.geometry.size.width * 0.5))
        }
    }
}

extension InternalCustomPagingScrollView {
    private func getGradient(isLeading: Bool) -> LinearGradient {
        return LinearGradient(
            colors: [
                .init(uiColor: .secondarySystemGroupedBackground),
                .init(uiColor: .secondarySystemGroupedBackground).opacity(0)
            ],
//            colors: [
//                .init(uiColor: .red),
//                .init(uiColor: .yellow).opacity(10)
//            ],
            startPoint: isLeading ? .leading : .trailing,
            endPoint: isLeading ? .trailing : .leading
        )
    }
    
    private func countViewOffset(_ count: Int) -> CGFloat {
        return -scrollManager.geometry.size.width * CGFloat(count - 1)
    }
    
    private func changedDragGesture(value: DragGesture.Value) {
        let trueValue = layoutDirection == .leftToRight ? value.translation.width : -value.translation.width
        let currentOffset = scrollManager.oldHOffset + trueValue
        
        let isFirst = currentOffset > 0
        let isLast = currentOffset < countViewOffset(data.count)
        
        if isFirst || isLast {
            scrollManager.hOffset = scrollManager.oldHOffset + trueValue * 0.5
        } else {
            scrollManager.hOffset = scrollManager.oldHOffset + trueValue
        }
    }
    
    private func endDragGesture(value: _EndedGesture<DragGesture>.Value) {
        let width = scrollManager.geometry.size.width
        let trueValue = layoutDirection == .leftToRight ? value.translation.width : -value.translation.width
        let truePredictedValue = layoutDirection == .leftToRight ? value.predictedEndTranslation.width : -value.predictedEndTranslation.width
        let currentValue = scrollManager.oldHOffset + truePredictedValue
        
        let isFirst = trueValue + scrollManager.oldHOffset > 0
        
        if isFirst {
            resetOffsets()
            
            return
        }
        
        let isLast = trueValue + scrollManager.oldHOffset < countViewOffset(data.count)
        
        if isLast {
            withAnimation(scrollAnimation) {
                scrollManager.hOffset = scrollManager.oldHOffset
            }
            
            return
        }
        
        var multiplier = abs(truePredictedValue/trueValue)
        
        if multiplier > 2.5 {
            multiplier = 2.5
        } else if multiplier < 0.5 {
            multiplier = 0.5
        }
        
        var divider = (currentValue / width).rounded()
        
        #if DEBUG
        logger.debug("Divider: \(divider)")
        #endif
        
        if divider < CGFloat(-selection - 1) {
            divider = CGFloat(-selection - 1)
        } else if divider > CGFloat(-selection + 1) {
            divider = CGFloat(-selection + 1)
        }
        
        #if DEBUG
        logger.debug("Rounded divider: \(divider)")
        #endif
        
        if selection != abs(Int(divider)) {
            selection = abs(Int(divider))
            
            HapticManager.shared.impact(.light)
        }
        
        #if DEBUG
        logger.debug("Selection: \(selection), should be: \(abs(divider))")
        #endif
        
        withAnimation(.smooth.speed(Double(multiplier))) {
            scrollManager.hOffset = divider * width
        }
        
        scrollManager.sync()
        
        scrollManager.gestureEnded()
    }
    
    private func breakGesture() {
        withAnimation {
//            self.hOffset = geometry.size.width * CGFloat(selection) * (layoutDirection == .leftToRight ? 1 : -1)
            self.scrollManager.hOffset = scrollManager.oldHOffset
        }
    }
    
    private func resetOffsets() {
        withAnimation(scrollAnimation) {
            scrollManager.hOffset = 0
        }
        
        if selection != 0 {
            selection = 0
        }
        
        scrollManager.sync()
    }
    
    private func setLastOffset(count: Int) {
//        print("\(#function) called") // TODO: Remove
        let lastOffset = countViewOffset(count)
//        print(lastOffset)
        
        withAnimation(scrollAnimation) {
            scrollManager.hOffset = lastOffset
        }
        
        if selection != count - 1 {
            selection = count - 1
        }
        
        scrollManager.sync()
    }
    
    private func scrollToNext() {
        withAnimation(scrollAnimation) {
            scrollManager.hOffset = scrollManager.geometry.size.width * -CGFloat(selection + 1)
        }
        
        selection += 1
        
        HapticManager.shared.impact(.light)
        
        scrollManager.sync()
    }
    
    private func scrollToPrevious() {
        withAnimation(scrollAnimation) {
            scrollManager.hOffset = scrollManager.geometry.size.width * -CGFloat(selection - 1)
        }
        
        selection -= 1
        
        HapticManager.shared.impact(.light)
        
        scrollManager.sync()
    }
}

final class PagingScrollViewManager: ObservableObject {
    @Published var hOffset: CGFloat
    var oldHOffset: CGFloat
    let geometry: GeometryProxy
    let viewScale: CGFloat
    let invertedViewScale: CGFloat
    let invert: Bool
    var cancellables = Set<AnyCancellable>()
    
    init(geometry: GeometryProxy, viewScale: CGFloat, invertedViewScale: CGFloat, invert: Bool) {
        self.hOffset = 0
        self.oldHOffset = 0
        self.geometry = geometry
        self.viewScale = viewScale
        self.invertedViewScale = invertedViewScale
        self.invert = invert
        subscribeToOffset()
        
//        print("Scroll manager init") // TODO: Remove
    }
    
    deinit {
//        print("Scroll manager deinit") // TODO: Remove
    }
    
    func resetOffsets() {
        withAnimation(.smooth(duration: 0.3)) {
            hOffset = 0
        }
        
        oldHOffset = 0
    }
    
    func sync() {
        self.oldHOffset = hOffset
        
        self.gestureEnded()
    }
    
    private func subscribeToOffset() {
        self.$hOffset
            .debounce(for: 1, scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                
                if self.hOffset != self.oldHOffset {
                    withAnimation(.smooth(duration: 0.3)) {
                        self.hOffset = self.oldHOffset
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func gestureEnded() {
        for item in cancellables {
            item.cancel()
        }
        
        subscribeToOffset()
    }
}

//fileprivate struct CustomPagingScrollPreview: View {
//    @State private var selection: Int = 0
//    
//    var body: some View {
//        CustomPagingScrollView(
//            selection: $selection,
//            data: Array(repeating: [.init(10, .blue), .init(15, .teal)], count: 11),
//            invert: true,
//            viewScale: 0.6
//        )
//    }
//}
//
//struct CustomAPChart: View {
//    let data: [APChartSectorData]
//    let index: Int
//    
//    init(data: [APChartSectorData], index: Int) {
//        self.data = data
//        self.index = index
//        print("\(index) initialized")
//    }
//    
//    var body: some View {
//        ZStack {
//            APChart(separators: 0, innerRadius: 0.7, data: data)
//            
//            Text("\(index)")
//        }
//    }
//}
//
//#Preview {
//    CustomPagingScrollPreview()
//}
