//
//  BigCard.swift
//  aic
//
//  Created by David Bireta on 2/18/26.
//  Copyright © 2026 Art Institute of Chicago. All rights reserved.
//

import SwiftUI

struct BigCard<OverlayContent: View>: View {
    let title: String
    let subtitle: LocalizedStringKey
    let imageURL: URL?
    @ViewBuilder let bottomOverlay: OverlayContent?
    
    @ScaledMetric private var leading = 22.0
    
    init(title: String, subtitle: LocalizedStringKey, imageURL: URL?, bottomOverlay: OverlayContent?) {
        self.title = title
        self.subtitle = subtitle
        self.imageURL = imageURL
        self.bottomOverlay = bottomOverlay
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Rectangle()
                .fill(.red)
                .frame(height: 200)
                .overlay {
                    RemoteImage(imageID: title, imageURL: imageURL, height: 200)
                }
                .clipped()
                .overlay(alignment: .bottom) {
                    if let bottomOverlay {
                        bottomOverlay
                            .aicOldFontStyle(.overlay)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(.black.opacity(0.5))
                    }
                }

            Text(title)
                .aicOldFontStyle(.title)
                .multilineTextAlignment(.leading)
            
            Text(subtitle)
                .aicOldFontStyle(.subtitle)
                .requestTightLineHeight(points: leading)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
        }
    }
}
