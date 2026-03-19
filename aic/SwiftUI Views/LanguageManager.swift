//
//  LanguageManager.swift
//  aic
//
//  Created by David Bireta on 3/19/26.
//  Copyright © 2026 Art Institute of Chicago. All rights reserved.
//

import Foundation
import Localize_Swift

class LanguageManager: ObservableObject {
    @Published var currentLanguage: String = "en"
    @Published var currentLocale: Locale = Locale.current
    
    static var sharedInstance = LanguageManager()
    
    private init() {
        print("init")
        self.currentLanguage = Localize.currentLanguage()
        self.currentLocale = Locale(identifier: Localize.currentLanguage())
    }
    
    func setLanguage(to language: Common.Language) {
        Localize.setCurrentLanguage(language.appleLanguageCode)
        
        self.currentLanguage = language.appleLanguageCode
        self.currentLocale = Locale(identifier: language.appleLanguageCode)
    }
}
