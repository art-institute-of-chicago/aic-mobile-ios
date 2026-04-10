//
//  TwoColumnGridView.swift
//  aic
//
//  Created by David Bireta on 2/18/26.
//  Copyright © 2026 Art Institute of Chicago. All rights reserved.
//

import SwiftUI

struct ToursGridView: View {
    let tours: [AICTourModel]
    
    @State private var selectedTour: AICTourModel?
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                .init(.flexible(minimum: 100, maximum: 400), alignment: .top),
                .init(.flexible(minimum: 100, maximum: 400))
            ], spacing: 64) {
                ForEach(tours, id: \.nid) { tour in
                    Button {
                        selectedTour = tour
                    } label: {
                        SmallCard(title: tour.title, subtitle: tour.shortDescription, imageURL: tour.imageUrl, bottomOverlay: "\(tour.stops.count) Stops \(tour.durationInMinutes ?? "")")
                    }
                    .foregroundStyle(.primary)
                }
            }
        }
        .padding(.horizontal)
        .navigationTitle("Tours")
        .sheet(item: $selectedTour) { tour in
            TourDetailView(tour: tour)
        }
    }
}

#Preview {
    ToursGridView(tours: [])
}
