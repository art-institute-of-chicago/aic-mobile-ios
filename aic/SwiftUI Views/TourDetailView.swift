//
//
//  TourDetailView.swift
//  aic
//
//  Created by David Bireta on 2/19/26.
//  Copyright © 2026 Art Institute of Chicago. All rights reserved.
//

import SwiftUI

struct TourDetailView: View {
    let tour: AICTourModel

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var coordinator: HomeNavigationCoordinator
    @ScaledMetric private var leading = 20.0

    @State private var selectedLanguage = Common.Language.english

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text(tour.title)
                        .aicOldFontStyle(.title)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    RemoteImage(imageID: tour.nid.formatted(), imageURL: tour.imageUrl)
                        .clipped()
                        .overlay(alignment: .bottom) {
                            HStack(spacing: 0) {
                                Image(.homeTourStopIcon)
                                Text(.Base.tourStopCount(tour.stops.count.formatted()))
                                    .padding(.trailing)
                                
                                Image(.homeTourClockIcon)
                                Text("\(tour.durationInMinutes ?? "")")
                                
                                Spacer()
                                
                                Picker(selection: $selectedLanguage) {
                                    ForEach(tour.availableLanguages, id: \.self) { language in
                                        Text(language.display).tag(language)
                                    }
                                } label: {
                                    Text("Choose a language")
                                }
                                .tint(.white)
                            }
                            .aicOldFontStyle(.overlay)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(.black.opacity(0.5))
                        }
                    
                    Button(.Base.tourStartTourAction) {
                        handleStartTour(stopIndex: nil)
                    }
                    .buttonStyle(AICTealButtonStyle())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    
                    Text(tour.longerDescription(for: selectedLanguage))
                        .aicOldFontStyle(.subtitle)
                        .requestTightLineHeight(points: leading)
                        .padding(.horizontal)
                    
                    Divider()
                        .padding(.horizontal, 48)
                        .padding(.vertical)
                    
                    VStack {
                        // Tour Overview
                        Button {
                            handleStartTour(stopIndex: nil)
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(tour.title)
                                        .lineLimit(1)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text(tour.stops.first?.object.gallery.title ?? "")
                                        .foregroundStyle(.secondary)
                                }
                                
                                Image(systemName: "chevron.right")
                            }
                        }
                        .foregroundStyle(.primary)
                        
                        Divider()
                        
                        ForEach(Array(tour.stops.enumerated()), id: \.element.object.nid) { index, stop in
                            Button {
                                handleStartTour(stopIndex: index)
                            } label: {
                                HStack {
                                    RemoteImage(imageID: stop.object.nid.formatted(), imageURL: stop.object.thumbnailUrl, height: 48)
                                        .frame(width: 80)
                                    
                                    HStack(alignment: .top) {
                                        Text((1 + index).formatted() + ".")
                                        
                                        VStack(alignment: .leading) {
                                            Text(stop.object.title)
                                                .lineLimit(1)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            Text(stop.object.gallery.title)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    
                                    Image(systemName: "chevron.right")
                                }
                            }
                            .foregroundStyle(.primary)
                            
                            Divider()
                        }
                    }
                    .padding(.horizontal)
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
        .onAppear {
            selectedLanguage = Common.Language(rawValue: LanguageManager.sharedInstance.currentLanguage) ?? .english
        }
    }
}

extension TourDetailView {
    private func handleStartTour(stopIndex: Int?) {
        dismiss()
        coordinator.startTour(tour, selectedLanguage, stopIndex)
    }
}
