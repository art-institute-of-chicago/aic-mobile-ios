//
//  EventsGridView.swift
//  aic
//
//  Created by David Bireta on 2/18/26.
//  Copyright © 2026 Art Institute of Chicago. All rights reserved.
//

import SwiftUI

struct EventsGridView: View {
    let events: [AICEventModel]
    
    @State private var selectedEvent: AICEventModel?
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                .init(.flexible(minimum: 100, maximum: 400), alignment: .top),
                .init(.flexible(minimum: 100, maximum: 400))
            ], spacing: 64) {
                ForEach(events, id: \.eventId) { event in
                    Button {
                        selectedEvent = event
                    } label: {
                        SmallCard(title: event.title, subtitle: event.shortDescription, imageURL: event.imageUrl, bottomOverlay: event.startDate.formatted(.dateTime.month().day().hour()))
                    }
                    .foregroundStyle(.primary)
                }
            }
        }
        .scrollIndicators(.hidden)
        .padding(.horizontal)
        .navigationTitle("Events")
        .navigationDestination(for: AICEventModel.self) { event in
            EventDetailView(event: event)
        }
        .sheet(item: $selectedEvent) { event in
            EventDetailView(event: event)
                .padding(.top)
        }
    }
}
