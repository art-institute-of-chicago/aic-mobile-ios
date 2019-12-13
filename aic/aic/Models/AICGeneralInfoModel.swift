/*
Abstract:
Defines a data structure for AIC Audio Files,
which are associated with artworks and tours
*/

import Foundation

struct AICGeneralInfoModel {
	let nid: Int

	var museumHours: String { return translations[Common.currentLanguage]!.museumHours }

	var homeMemberPrompt: String { return translations[Common.currentLanguage]!.homeMemberPrompt }

	var seeAllToursIntro: String { return translations[Common.currentLanguage]!.seeAllToursIntro }

	var audioTitle: String { return translations[Common.currentLanguage]!.audioTitle }
	var audioSubtitle: String { return translations[Common.currentLanguage]!.audioSubtitle }

	var mapTitle: String { return translations[Common.currentLanguage]!.mapTitle }
	var mapSubtitle: String { return translations[Common.currentLanguage]!.mapSubtitle }

	var infoTitle: String { return translations[Common.currentLanguage]!.infoTitle }
	var infoSubtitle: String { return translations[Common.currentLanguage]!.infoSubtitle }

	var giftShopsTitle: String { return translations[Common.currentLanguage]!.giftShopsTitle }
	var giftShopsText: String { return translations[Common.currentLanguage]!.giftShopsText }

	var membersLoungeTitle: String { return translations[Common.currentLanguage]!.membersLoungeTitle }
	var membersLoungeText: String { return translations[Common.currentLanguage]!.membersLoungeText }

	var restroomsTitle: String { return translations[Common.currentLanguage]!.restroomsTitle }
	var restroomsText: String { return translations[Common.currentLanguage]!.restroomsText }

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
