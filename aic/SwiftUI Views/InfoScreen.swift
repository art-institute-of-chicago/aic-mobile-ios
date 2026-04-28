//
//  InfoScreen.swift
//  aic
//
//  Created by David Bireta on 2/11/26.
//  Copyright © 2026 Art Institute of Chicago. All rights reserved.
//

import SwiftUI

struct InfoScreen: View {
    @ObservedObject var language: LanguageManager
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var scrollContentOffset: CGFloat = 0
    
    var body: some View {
        ObservableScrollView(contentOffset: $scrollContentOffset) {
            VStack {
                Image(.iconInfo)
                    .opacity(titleOpacity)
                
                Text(AppDataManager.sharedInstance.app.generalInfo.infoTitle)
                    .aicOldFontStyle(.bigTitle)
                    .foregroundStyle(.white)
                    .opacity(titleOpacity)
                    .scaleEffect(titleOpacity)
                
                Text(AppDataManager.sharedInstance.app.generalInfo.infoSubtitle)
                    .aicOldFontStyle(.subtitle)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .opacity(titleOpacity)
                    .scaleEffect(titleOpacity)
                    .padding(.horizontal)
                
                VStack(spacing: 24) {
                    Text(.Info.purchaseTicketsPrompt)
                        .aicOldFontStyle(.infoMenuText)
                        .multilineTextAlignment(.center)
                        .padding(.top)
                    
                    Button(action: { handleBuyTickets() }) {
                        Text(.Info.buyTicketsAction)
                            .aicOldFontStyle(.actionButton)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 56)
                            .padding(.vertical)
                            .background(.infoBackground)
                    }
                    
                    Divider()
                    
                    Text(.Info.memberHeader)
                        .aicOldFontStyle(.title)
                    
                    VStack {
                        Text(.Info.memberPrompt)
                            .aicOldFontStyle(.infoMenuText)
                        
                        Button(.Info.memberJoinAction) { handleBuyTickets() }
                            .aicOldFontStyle(.infoMenuText)
                            .foregroundStyle(Color(uiColor: .aicInfoColor))
                    }
                    
                    Text(.Info.memberLogInHeader)
                        .aicOldFontStyle(.infoMenuText)
                    
                    NavigationLink(value: Destination.memberCard) {
                        Text(.Info.memberCardAction)
                            .aicOldFontStyle(.infoMenuText)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical)
                            .background(Color(uiColor: .aicInfoColor))
                    }
                    
                    Divider()
                    
                    NavigationLink(value: Destination.museumInfo) {
                        MenuItem(text: .Info.museumInfoAction)
                    }
                    .foregroundStyle(.primary)
                    
                    Divider()
                    
                    NavigationLink(value: Destination.languageSettings) {
                        MenuItem(text: .Info.languageSettings)
                    }
                    .foregroundStyle(.primary)
                    
                    Divider()
                    
                    NavigationLink(value: Destination.locationSettings) {
                        MenuItem(text: .Info.locationSettings)
                    }
                    .foregroundStyle(.primary)
                    
                    // Footer
                    VStack(alignment: .leading, spacing: 24) {
                        Image(.bloombergLogo)
                        
                        HStack {
                            Text(.Info.version(Bundle.versionNumber))
                            Text(.Info.designedBy)
                        }
                        .aicOldFontStyle(.overlay)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.top, 64)
                    .padding(.horizontal)
                    .background(.infoBackground)
                }
                .background(.background)
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .background(alignment: .top) {
            Image(.backgroundInfo)
                .resizable()
                .scaledToFit()
                .offset(y: -30)
                .opacity((scrollContentOffset + InfoScreen.topSpacing) / InfoScreen.topSpacing)
        }
        .scrollIndicators(.hidden)
        .background(.infoBackground)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.infoBackground, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationTitle(scrollContentOffset > -150 ? "" : AppDataManager.sharedInstance.app.generalInfo.infoTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Destination.self) { destination in
            switch destination {
                case .locationSettings:
                    LocationSettingsView()
                        .environment(\.locale, language.currentLocale)
                case .museumInfo:
                    MuseumInfoView(buildingHours: AppDataManager.sharedInstance.buildingHours!)
                        .environment(\.locale, language.currentLocale)
                case .languageSettings:
                    LanguageSettingsView(languageManager: LanguageManager.sharedInstance)
                        .environment(\.locale, language.currentLocale)
                case .memberCard:
                    MemberView()
                        .environment(\.locale, language.currentLocale)
            }
        }
        .environment(\.locale, language.currentLocale)
    }
}

extension InfoScreen {
    private static let topSpacing = 160.0
    
    private enum Destination {
        case memberCard, locationSettings, languageSettings, museumInfo
    }
    
    private var titleOpacity: Double {
        if scrollContentOffset >= 0 {
            return 1
        } else {
            return 1 - abs(scrollContentOffset / InfoScreen.topSpacing)
        }
    }
    
    private struct MenuItem: View {
        let text: LocalizedStringResource
        
        var body: some View {
            HStack {
                Text(text)
                    .aicOldFontStyle(.title)
                
                Spacer()
                
                Image(systemName: "chevron.right")
            }
            .padding(.horizontal)
        }
    }
    
    private func handleBuyTickets() {
        if let url = URL(string: AppDataManager.sharedInstance.app.dataSettings[.ticketsUrl] ?? "") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

#Preview {
    NavigationStack {
        InfoScreen(language: LanguageManager.sharedInstance)
    }
}
