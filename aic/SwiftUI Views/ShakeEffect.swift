//
//  ShakeEffect.swift
//  aic
//
//  Created by David Bireta on 3/17/26.
//  Copyright © 2026 Art Institute of Chicago. All rights reserved.
//

import SwiftUI

// https://www.objc.io/blog/2019/10/01/swiftui-shake-animation/
// Could replace with a PhaseAnimator for iOS 17+
public struct ShakeEffect: GeometryEffect {
    private let amount: CGFloat = 24.0
    private let shakesPerUnit: CGFloat = 5.0
    public var animatableData: CGFloat

    public init(animatableData: CGFloat) {
        self.animatableData = animatableData
    }
    
    public func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(
                translationX: self.amount * sin(self.animatableData * .pi * self.shakesPerUnit),
                y: 0.0
            )
        )
    }
}
