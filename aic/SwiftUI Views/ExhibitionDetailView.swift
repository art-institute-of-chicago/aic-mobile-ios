//
//  ExhibitionDetailView.swift
//  aic
//
//  Created by David Bireta on 2/19/26.
//  Copyright © 2026 Art Institute of Chicago. All rights reserved.
//

import SwiftUI

struct ExhibitionDetailView: View {
    let exhibition: AICExhibitionModel
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var coordinator: HomeNavigationCoordinator
    @ScaledMetric private var leading = 20.0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text(exhibition.title)
                        .aicOldFontStyle(.title)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    RemoteImage(imageID: exhibition.id.formatted(), imageURL: exhibition.imageUrl, height: 400)
                    
                    HStack {
                        if exhibition.location != nil {
                            Button {
                                handleShowOnMap(with: exhibition)
                            } label: {
                                Label(.Base.contentShowOnMapAction, image: "buttonMapIcon")
                            }
                            .buttonStyle(AICTealButtonStyle())
                        }
                        
                        Button(action: handleBuyTickets) {
                            Label(.Base.eventBuyTicketsAction, image: "buttonTicketIcon")
                        }
                        .buttonStyle(AICTealButtonStyle())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    
                    Text(LocalizedStringKey(exhibition.shortDescription))
                        .aicOldFontStyle(.subtitle)
                        .requestTightLineHeight(points: leading)
                        .padding([.horizontal, .bottom])
                    
                    if let galleryID = exhibition.galleryId, let galleryName = galleryName(for: galleryID) {
                        Text(galleryName)
                            .aicOldFontStyle(.subtitle)
                            .padding([.horizontal, .bottom])
                    }
                    
                    if let endDate = exhibition.endDate {
                        Text(.Base.contentThroughDate(endDate.formatted(date: .long, time: .omitted)))
                            .aicOldFontStyle(.subtitle).italic()
                            .padding(.horizontal)
                    } else {
                        // TODO: Missing translation
                        Text(.Base.ongoing)
                            .aicOldFontStyle(.subtitle).italic()
                            .padding(.horizontal)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
            .toolbar {
                ToolbarItem {
                    if #available(iOS 26.0, *) {
                        Button(role: .close) {
                            dismiss()
                        }
                    } else {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle")
                                .imageScale(.large)
                        }
                    }
                }
            }
        }
    }
}

extension ExhibitionDetailView {
    private func galleryName(for id: Int) -> String? {
        AppDataManager.sharedInstance.getGallery(with: id)?.title
    }
    
    private func handleBuyTickets() {
        // Log analytics
        AICAnalytics.sendExhibitionBuyLinkEvent(exhibition: exhibition)
        
        if let ticketURLString = AppDataManager.sharedInstance.app.dataSettings[.ticketsUrl], let url = URL(string: ticketURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func handleShowOnMap(with exhibition: AICExhibitionModel) {
        dismiss()
        coordinator.showExhibitionOnMap(exhibition)
    }
}
