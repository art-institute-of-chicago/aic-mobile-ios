/*
Abstract:
This class represents an overlay message, i.e. Location Services are off
*/

import UIKit

struct AICMessageModel {
	// MARK: - Enums -
	enum MessageType {
		case launch(isPersistent: Bool)
		case memberExpiration(isPersistent: Bool, threshold: Int)
		case tourExit(isPersistent: Bool, tourNid: String)
	}

	// MARK: - Structs -

	// MARK: - Properties -
	let nid: String?
	let iconImage: UIImage?
	let messageType: MessageType?
	let title: String
	let message: String
	let actionButtonTitle: String?
	let action: String?
	let cancelButtonTitle: String?
	let translations: [Common.Language: AICMessageTranslationModel]?

	// MARK: - Initializers -
	init(nid: String? = nil,
		 iconImage: UIImage? = nil,
		 messageType: MessageType? = nil,
		 title: String,
		 message: String,
		 actionButtonTitle: String? = nil,
		 action: String? = nil,
		 cancelButtonTitle: String? = nil,
		 translations: [Common.Language: AICMessageTranslationModel]? = nil) {
		self.nid = nid
		self.iconImage = iconImage
		self.messageType = messageType
		self.title = title
		self.message = message
		self.actionButtonTitle = actionButtonTitle
		self.action = action
		self.cancelButtonTitle = cancelButtonTitle
		self.translations = translations
	}
}

struct AICMessageTranslationModel {
	let title: String
	let message: String
	let actionButtonTitle: String?
}
