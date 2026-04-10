//
//  ExhibitionsGridView.swift
//  aic
//
//  Created by David Bireta on 2/18/26.
//  Copyright © 2026 Art Institute of Chicago. All rights reserved.
//

import SwiftUI

struct ExhibitionsGridView: View {
    let exhibitions: [AICExhibitionModel]
    
    @State private var selectedExhibition: AICExhibitionModel?
    
    var body: some View {
        ScrollView {
            ForEach(exhibitions, id: \.id) { exhibit in
                Button {
                    selectedExhibition = exhibit
                } label: {
                    ExhibitionCard(title: exhibit.title, shortDescription: exhibit.shortDescription, endDate: exhibit.endDate ?? .distantFuture, imageURL: exhibit.imageUrl)
                }
                .foregroundStyle(.primary)
            }
        }
        .navigationTitle("On View")
        .sheet(item: $selectedExhibition) { exhibition in
            ExhibitionDetailView(exhibition: exhibition)
        }
    }
}

#Preview {
    ExhibitionsGridView(exhibitions: [])
}
