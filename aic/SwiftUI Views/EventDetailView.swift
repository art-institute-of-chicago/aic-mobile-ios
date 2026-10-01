//
//  EventDetailView.swift
//  aic
//
//  Created by David Bireta on 2/19/26.
//  Copyright © 2026 Art Institute of Chicago. All rights reserved.
//

import SwiftUI

struct EventDetailView: View {
    let event: AICEventModel
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @ScaledMetric private var leading = 20.0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text(event.title)
                        .aicOldFontStyle(.title)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    RemoteImage(imageID: event.id, imageURL: event.imageUrl, height: 240)
                        .overlay(alignment: .bottom) {
                            Text(event.startDate.formatted(.dateTime.month(.wide).day().hour().minute()))
                                .aicOldFontStyle(.overlay)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.white)
                                .padding(8)
                                .background(.black.opacity(0.5))
                        }
                    
                    let validDate = event.onSaleDate == nil || (event.onSaleDate ?? .distantPast < .now && event.offSaleDate ?? .distantFuture > .now)
                    if event.isTicketed && event.isSalesButtonHidden == false && validDate {
                        Button(event.buttonText) {
                            handleTicketButton(for: event)
                        }
                        .padding(.bottom)
                    }
                    
                    if let caption = event.buttonCaption, caption.isEmpty == false {
                        Text(LocalizedStringKey(caption))
                            .aicOldFontStyle(.infoMenuText)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .padding(.vertical)
                    }
                    
                    Text(LocalizedStringKey(event.longDescription))
                        .aicOldFontStyle(.subtitle)
                        .requestTightLineHeight(points: leading)
                        .padding(.horizontal)
                        .padding(.bottom)
                    
                    VStack(alignment: .leading) {
                        Text(event.startDate.formatted(.dateTime.month(.wide).day().hour().minute()))
                        Text(event.locationText)
                    }
                    .padding(.horizontal)
                    .aicOldFontStyle(.subtitle).italic()
                }
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
            .background(.background)
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

extension EventDetailView {
    private func handleTicketButton(for event: AICEventModel) {
        if let url = event.eventUrl {
            AICAnalytics.sendEventRegisterLinkEvent(event: event)
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
