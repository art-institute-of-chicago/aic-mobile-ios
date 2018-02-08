/*
Abstract:
Defines a data structure for AIC Audio Files,
which are associated with artworks and tours
*/

import Foundation

struct AICGeneralInfoModel {
	let nid: Int
	var translations: [Common.Language : AICGeneralInfoTranslationModel]
}

struct AICGeneralInfoTranslationModel {
	let museumHours: String
	let homeMemberPrompt: String
	let audioTitle: String
	let audioSubtitle: String
	let mapTitle: String
	let mapSubtitle: String
	let infoTitle: String
	let infoSubtitle: String
}

