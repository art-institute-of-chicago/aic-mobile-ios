/*
Abstract:
Defines a data structure for AIC Audio Files,
which are associated with artworks and tours
*/

import Foundation

struct AICGeneralInfoModel {
	let nid: Int
	var translations: [Common.Language : AICGeneralInfoTranslationModel]
	
	var availableLanguages: [Common.Language] {
		var languages: [Common.Language] = []
		for (key, translation) in translations {
			languages.append(key)
		}
		return languages
	}
}

struct AICGeneralInfoTranslationModel {
	let museumHours: String
	let homeMemberPrompt: String
	let seeAllToursIntro: String
	let audioTitle: String
	let audioSubtitle: String
	let mapTitle: String
	let mapSubtitle: String
	let infoTitle: String
	let infoSubtitle: String
	let diningTitle: String
	let giftShopsTitle: String
	let membersLoungeTitle: String
	let restroomsTitle: String
}

