//
//  SmallCard.swift
//  aic
//
//  Created by David Bireta on 2/18/26.
//  Copyright © 2026 Art Institute of Chicago. All rights reserved.
//

import SwiftUI

struct SmallCard: View {
    let title: String
    let subtitle: String
    let imageURL: URL?
    let bottomOverlay: String?
    
    var body: some View {
        VStack(alignment: .leading) {
            RemoteImage(imageID: title, imageURL: imageURL, height: 100)

            Text(title)
                .aicOldFontStyle(.title)
                .lineLimit(2, reservesSpace: true)
                .multilineTextAlignment(.leading)
            
            if let bottomOverlay {
                Text(bottomOverlay)
                    .aicOldFontStyle(.overlay)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
            
            Text(subtitle)
                .aicOldFontStyle(.subtitle)
                .requestTightLineHeight(points: 20)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
        }
    }
}

#Preview {
    SmallCard(title: "Title", subtitle: "Subtitle", imageURL: nil, bottomOverlay: nil)
}
