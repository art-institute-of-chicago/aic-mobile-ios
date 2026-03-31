//
//  Backports.swift
//  aic
//
//  Created by David Bireta on 3/17/26.
//  Copyright © 2026 Art Institute of Chicago. All rights reserved.
//

import SwiftUI

extension View {
    @ViewBuilder
    func requestTightLineHeight(points: Double) -> some View {
        if #available(iOS 26.0, *) {
            self.lineHeight(.exact(points: points))
        } else {
            self
        }
    }
    
    @ViewBuilder
    func requestScrollTargetLayout() -> some View {
        if #available(iOS 17.0, *) {
            self.scrollTargetLayout()
        } else {
            self
        }
    }
    
    @ViewBuilder
    func requestScrollTargetBehavior() -> some View {
        if #available(iOS 17.0, *) {
            self.scrollTargetBehavior(.viewAligned)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func requestContentMargins() -> some View {
        if #available(iOS 17.0, *) {
            self.contentMargins(.horizontal, 24)
        } else {
            self
        }
    }
}
