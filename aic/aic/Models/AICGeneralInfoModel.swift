/*
Abstract:
Defines a data structure for AIC Audio Files,
which are associated with artworks and tours
*/

import Foundation

struct AICGeneralInfoModel {
	let nid: Int

	var museumHours: String {
		return translations[Common.currentLanguage]?.museumHours
			?? translations[.english]?.museumHours
			?? "museumHours"
	}

	var homeMemberPrompt: String {
		return translations[Common.currentLanguage]?.homeMemberPrompt
			?? translations[.english]?.homeMemberPrompt
			?? "homeMemberPrompt"
	}

	var seeAllToursIntro: String {
		return translations[Common.currentLanguage]?.seeAllToursIntro
			?? translations[.english]?.seeAllToursIntro
			?? "seeAllToursIntro"
	}

	var audioTitle: String {
		return translations[Common.currentLanguage]?.audioTitle
			?? translations[.english]?.audioTitle
			?? "audioTitle"
	}
	var audioSubtitle: String {
		return translations[Common.currentLanguage]?.audioSubtitle
			?? translations[.english]?.audioSubtitle
			?? "audioSubtitle"
	}

	var mapTitle: String {
		return translations[Common.currentLanguage]?.mapTitle
			?? translations[.english]?.mapTitle
			?? "mapTitle"
	}
	var mapSubtitle: String {
		return translations[Common.currentLanguage]?.mapSubtitle
			?? translations[.english]?.mapSubtitle
			?? "mapSubtitle"
	}

	var infoTitle: String {
		return translations[Common.currentLanguage]?.infoTitle
			?? translations[.english]?.infoTitle
			?? "infoTitle"
	}
	var infoSubtitle: String {
		return translations[Common.currentLanguage]?.infoSubtitle
			?? translations[.english]?.infoSubtitle
			?? "infoSubtitle"
	}

	var giftShopsTitle: String {
		return translations[Common.currentLanguage]?.giftShopsTitle
			?? translations[.english]?.giftShopsTitle
			?? "giftShopsTitle"
	}
	var giftShopsText: String {
		return translations[Common.currentLanguage]?.giftShopsText
			?? translations[.english]?.giftShopsText
			?? "giftShopsText"
	}

	var membersLoungeTitle: String {
		return translations[Common.currentLanguage]?.membersLoungeTitle
			?? translations[.english]?.membersLoungeTitle
			?? "membersLoungeTitle"
	}
	var membersLoungeText: String {
		return translations[Common.currentLanguage]?.membersLoungeText
			?? translations[.english]?.membersLoungeText
			?? "membersLoungeText"
	}

	var restroomsTitle: String {
		return translations[Common.currentLanguage]?.restroomsTitle
			?? translations[.english]?.restroomsTitle
			?? "restroomsTitle"
	}
	var restroomsText: String {
		return translations[Common.currentLanguage]?.restroomsText
			?? translations[.english]?.restroomsText
			?? "restroomsText"
	}

	var translations: [Common.Language: AICGeneralInfoTranslationModel]
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
	let giftShopsTitle: String
	let giftShopsText: String
	let membersLoungeTitle: String
	let membersLoungeText: String
	let restroomsTitle: String
	let restroomsText: String
}
