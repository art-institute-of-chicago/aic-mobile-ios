//
//  ObservableScrollView.swift
//  aic
//
//  Created by David Bireta on 3/6/26.
//  Copyright © 2026 Art Institute of Chicago. All rights reserved.
//

import SwiftUI

/// Displays the given `content` inside a `ScrollView`, and provides an observable `contentOffset` property.
struct ObservableScrollView<Content: View>: View {
    let content: Content
    @Binding var contentOffset: CGFloat

    init(contentOffset: Binding<CGFloat>, @ViewBuilder content: () -> Content) {
        self._contentOffset = contentOffset
        self.content = content()
    }

    var body: some View {
        ScrollView {
            content
                .background {
                    GeometryReader { geometry in
                        Color.clear
                            .preference(key: ContentOffsetKey.self, value: geometry.frame(in: .named("scrollView")).minY)
                    }
                }
        }
        .coordinateSpace(name: "scrollView")
        .onPreferenceChange(ContentOffsetKey.self) { value in
            self.contentOffset = value
        }
    }
}

struct ContentOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}
