/*
 Abstract:
 Data model for info received from member card API
*/

struct AICMemberCardModel {
	let cardId: String
	let memberNames: [String]
	let memberLevel: String
	let memberZip: String
	let expirationDate: Date
	let isReciprocalMember: Bool
	let isLifeMembership: Bool
}
