//
//  ExhibitionCard.swift
//  aic
//
//  Created by David Bireta on 2/13/26.
//  Copyright © 2026 Art Institute of Chicago. All rights reserved.
//

import SwiftUI

struct ExhibitionCard: View {
    let title: String
    let shortDescription: String
    let endDate: Date
    let imageURL: URL?
    
    @ScaledMetric private var leadingAmount = 20.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RemoteImage(imageID: title, imageURL: imageURL, height: 200)
            
            Text("Exhibition".uppercased())
                .fontWeight(.light)

            Text(title)
                .requestTightLineHeight(points: leadingAmount)
                .multilineTextAlignment(.leading)
                .padding(.bottom)
            
            Text(endDate.formatted(date: .abbreviated, time: .omitted))
                .fontWeight(.light)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            Rectangle()
                .fill(.background)
                .shadow(radius: 3)
        )
    }
}

#Preview {
    ExhibitionCard(title: "Carroll Dunham: Drawings, 1974–2024", shortDescription: "alkdsfj", endDate: .now, imageURL: nil)
}
