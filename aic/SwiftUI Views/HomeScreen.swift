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

    @State private var scrollContentOffset: CGFloat = 0
    private let topSpacing = 60.0
    
    private var titleOpacity: Double {
        if scrollContentOffset > -1 * topSpacing {
            return 1
        } else {
            return 1 - abs((scrollContentOffset + topSpacing) / 50)
        }
    }
    
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
        .environment(\.locale, languageManager.currentLocale)
    }
}

extension HomeScreen {
    private var title: String {
        var resource = LocalizedStringResource("welcome_title", table: "Base")
        resource.locale = languageManager.currentLocale
        let translatedString = String(localized: resource)
        
        return translatedString
    }
}
