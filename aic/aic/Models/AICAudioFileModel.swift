/*
Abstract:
 Defines a data structure for AIC Audio Files,
 which are associated with artworks and tours
*/

import Foundation

struct AICAudioFileModel {
    let nid: Int
	
	// Translated content
	var title: String { return self.translations[self.language]!.title }
	var url: URL { return self.translations[self.language]!.url }
	var transcript: String { return self.translations[self.language]!.transcript }
	
	var translations: [Common.Language : AICAudioFileTranslationModel]
	
	var language: Common.Language = .english {
		didSet {
			if availableLanguages.contains(language) == false {
				self.language = oldValue
			}
		}
	}
	
	var availableLanguages: [Common.Language] {
		var languages: [Common.Language] = []
		for (key, translation) in translations {
			languages.append(key)
		}
		return languages
	}
}

struct AICAudioFileTranslationModel {
	let title: String
	let url: URL
	let transcript: String
}
