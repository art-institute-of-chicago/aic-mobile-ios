//
//  AICButtonStyle.swift
//  aic
//
//  Created by David Bireta on 4/10/26.
//  Copyright © 2026 Art Institute of Chicago. All rights reserved.
//

import SwiftUI

struct AICButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .aicOldFontStyle(.actionButton)
            .padding()
            .padding(.horizontal)
            .foregroundStyle(.white)
            .background(configuration.isPressed ? Color.infoBackground.opacity(0.3) : Color.infoBackground)
    }
}

struct AICTealButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .aicOldFontStyle(.actionButton)
            .padding()
            .padding(.horizontal)
            .foregroundStyle(.white)
            .background(configuration.isPressed ? Color.teal.opacity(0.3) : Color.teal)
    }
}
