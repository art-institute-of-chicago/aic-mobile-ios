//
//  LanguageSettingsView.swift
//  aic
//
//  Created by David Bireta on 2/20/26.
//  Copyright © 2026 Art Institute of Chicago. All rights reserved.
//

import Localize_Swift
import SwiftUI

struct LanguageSettingsView: View {
    @ObservedObject var languageManager: LanguageManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text(.LocalizationUI.languageSettingsHeader)
                    .aicOldFontStyle(.audioButton)
                    .multilineTextAlignment(.center)
                
                Divider()
                
                Text(.LocalizationUI.languageSettingsBody)
                    .aicOldFontStyle(.infoMenuText)
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
                
                ForEach(Common.Language.allCases, id: \.self) { language in
                    Button {
                        languageManager.setLanguage(to: language)
                    } label: {
                        Text(language.display)
                            .frame(width: 200)
                            .padding(.vertical)
                            .foregroundStyle(language.appleLanguageCode == languageManager.currentLanguage ? .white : .orange)
                            .background(language.appleLanguageCode == languageManager.currentLanguage ? Color.orange : Color.white)
                            .border(.orange)
                    }
                }
            }
            .padding()
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .toolbarBackground(.infoBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

#Preview {
    LanguageSettingsView(languageManager: LanguageManager.sharedInstance)
}
