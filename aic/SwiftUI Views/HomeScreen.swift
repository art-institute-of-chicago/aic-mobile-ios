//
//  HomeScreen.swift
//  aic
//
//  Created by David Bireta on 2/18/26.
//  Copyright © 2026 Art Institute of Chicago. All rights reserved.
//

import SwiftUI

struct HomeScreen: View {
    @ObservedObject var languageManager: LanguageManager
    @EnvironmentObject private var coordinator: HomeNavigationCoordinator

    @State private var selectedExhibition: AICExhibitionModel?
    @State private var selectedEvent: AICEventModel?
    @State private var selectedTour: AICTourModel?
    @State private var scrollContentOffset: CGFloat = 0
    private let topSpacing = 60.0
    
    var body: some View {
        ObservableScrollView(contentOffset: $scrollContentOffset) {
            VStack {
                Image(.iconHome)
                    .opacity((scrollContentOffset + topSpacing) / topSpacing)
                
                Text("welcome_title", tableName: "Base")
                    .aicOldFontStyle(.bigTitle)
                    .foregroundStyle(.white)
                    .opacity(titleOpacity)
                    .scaleEffect(titleOpacity)
                
                VStack {
                    Button {
                        coordinator.showMemberCard()
                    } label: {
                        Text(.Base.welcomeMemberCardAction)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                            .background(Color.gray.opacity(0.4))
                    }
                    .foregroundStyle(.primary)
                    .padding(.bottom)

                    // Tours
                    SwiftUI.Section {
                        ScrollView(.horizontal) {
                            HStack(alignment: .top, spacing: 16) {
                                ForEach(tours, id: \.nid) { tour in
                                    Button { selectedTour = tour } label: {
                                        BigCard(
                                            title: tour.title,
                                            subtitle: LocalizedStringKey(tour.shortDescription),
                                            imageURL: tour.imageUrl,
                                            bottomOverlay: HStack(spacing: 0) {
                                                Image(.homeTourStopIcon)
                                                Text("\(tour.stops.count) stops").padding(.trailing)
                                                
                                                Image(.homeTourClockIcon)
                                                Text("\(tour.durationInMinutes ?? "")")
                                            }
                                        )
                                        .frame(width: 300)
                                    }
                                    .foregroundStyle(.primary)
                                }
                            }
                            .requestScrollTargetLayout()
                        }
                        .requestScrollTargetBehavior()
                        .requestContentMargins()
                    } header: {
                        HStack {
                            Text(.Base.welcomeToursHeader)
                                .aicOldFontStyle(.sectionHeader)
                            Spacer()
                            NavigationLink(value: ContentType.tours) {
                                Text(.Base.welcomeSeeAllAction)
                                    .aicOldFontStyle(.overlay)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.vertical)
                    Divider()
                        .padding(.horizontal)
                        .padding(.bottom)

                    // Exhibitions
                    SwiftUI.Section {
                        ScrollView(.horizontal) {
                            HStack(alignment: .top, spacing: 16) {
                                ForEach(exhibitions, id: \.id) { exhibition in
                                    Button { selectedExhibition = exhibition } label: {
                                        BigCard(title: exhibition.title, subtitle: LocalizedStringKey(exhibition.shortDescription), imageURL: exhibition.imageUrl, bottomOverlay: EmptyView())
                                            .frame(width: 300)
                                    }
                                    .foregroundStyle(.primary)
                                }
                            }
                            .requestScrollTargetLayout()
                        }
                        .requestScrollTargetBehavior()
                        .requestContentMargins()
                    } header: {
                        HStack {
                            Text(.Base.welcomeOnViewHeader)
                                .aicOldFontStyle(.sectionHeader)
                            Spacer()
                            NavigationLink(value: ContentType.exhibitions) {
                                Text(.Base.welcomeSeeAllAction)
                                    .aicOldFontStyle(.overlay)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom)
                    Divider()
                        .padding(.horizontal)
                        .padding(.bottom)
                    
                    // Events
                    SwiftUI.Section {
                        ScrollView(.horizontal) {
                            HStack(alignment: .top, spacing: 16) {
                                ForEach(events, id: \.eventId) { event in
                                    Button {
                                        selectedEvent = event
                                    } label: {
                                        BigCard(title: event.title, subtitle: LocalizedStringKey(event.shortDescription), imageURL: smallerImage(for: event.imageUrl), bottomOverlay: Text(event.startDate.formatted(.dateTime.month().day().hour())))
                                            .frame(width: 300)
                                    }
                                    .foregroundStyle(.primary)
                                }
                            }
                            .requestScrollTargetLayout()
                        }
                        .requestScrollTargetBehavior()
                        .requestContentMargins()
                    } header: {
                        HStack {
                            Text(.Base.welcomeEventsHeader)
                                .aicOldFontStyle(.sectionHeader)
                            Spacer()
                            NavigationLink(value: ContentType.events) {
                                Text(.Base.welcomeSeeAllAction)
                                    .aicOldFontStyle(.overlay)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom)
                }
                .background(.background)
            }
            .padding(.top, 64)
            .ignoresSafeArea(edges: .bottom)
        }
        .background(alignment: .top) {
            Image(.backgroundHome)
                .resizable()
                .scaledToFit()
                .offset(y: -30)
                .opacity((scrollContentOffset + topSpacing) / topSpacing)
        }
        .scrollIndicators(.hidden)
        .background(Color.homeBackground)
        .navigationTitle(scrollContentOffset > -150 ? "" : title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.homeBackground, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(item: $selectedExhibition) { exhibition in
            ExhibitionDetailView(exhibition: exhibition)
                .environment(\.locale, languageManager.currentLocale)
        }
        .sheet(item: $selectedEvent) { event in
            EventDetailView(event: event)
        }
        .sheet(item: $selectedTour) { tour in
            TourDetailView(tour: tour)
        }
        .navigationDestination(for: ContentType.self) { content in
            switch content {
                case .exhibitions:
                    ExhibitionsGridView(exhibitions: AppDataManager.sharedInstance.exhibitions)
                        .environmentObject(coordinator)
                case .events:
                    EventsGridView(events: AppDataManager.sharedInstance.events)
                        .environmentObject(coordinator)
                case .tours:
                    ToursGridView(tours: AppDataManager.sharedInstance.getToursForSeeAll())
                        .environmentObject(coordinator)
            }
        }
        .environment(\.locale, languageManager.currentLocale)
    }
}

extension HomeScreen {
    enum ContentType {
        case tours, exhibitions, events
    }
    
    private var exhibitions: [AICExhibitionModel] {
        AppDataManager.sharedInstance.getExhibitionsForHome()
    }
    
    private var events: [AICEventModel] {
        AppDataManager.sharedInstance.getEventsForHome()
    }
    
    private var tours: [AICTourModel] {
        AppDataManager.sharedInstance.getToursForHome()
    }
    
    private func smallerImage(for url: URL) -> URL {
        url.updatingQueryItem(key: "w", value: "400").updatingQueryItem(key: "h", value: "225)")
    }
    
    private var title: String {
        var resource = LocalizedStringResource("welcome_title", table: "Base")
        resource.locale = languageManager.currentLocale
        let translatedString = String(localized: resource)
        
        return translatedString
    }
    
    private var titleOpacity: Double {
        if scrollContentOffset > -1 * topSpacing {
            return 1
        } else {
            return 1 - abs((scrollContentOffset + topSpacing) / 50)
        }
    }
}
