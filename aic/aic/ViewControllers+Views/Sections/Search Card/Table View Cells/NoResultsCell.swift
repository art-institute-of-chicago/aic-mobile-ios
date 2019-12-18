//
//  NoResultsCell.swift
//  aic
//
//  Created by Filippo Vanucci on 2/21/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Kingfisher

/// NoResultsCell
///
/// UITableViewCell for list of Tour Stops or content results in Search
class NoResultsCell: UITableViewCell {
	static let reuseIdentifier = "noResultsCell"

	@IBOutlet weak var noResultsLabel: UILabel!
	@IBOutlet weak var visitWebsiteTextView: LinkedTextView!

	var contentLoaded: Bool = false

	static let cellHeight: CGFloat = 100.0

	override func awakeFromNib() {
		super.awakeFromNib()

		selectionStyle = .none

		self.backgroundColor = .aicDarkGrayColor

		noResultsLabel.font = .aicSearchNoResultsMessageFont
		noResultsLabel.numberOfLines = 0
		noResultsLabel.lineBreakMode = .byWordWrapping
		noResultsLabel.textColor = .aicCardDarkTextColor

		visitWebsiteTextView.setDefaultsForAICAttributedTextView()
		visitWebsiteTextView.delegate = self
	}

	func updateLanguage() {
		noResultsLabel.text = "Not Found Text".localized(using: "Search")

		let visitWebsiteLink = "Not Found Website Link".localized(using: "Search")
		let visitWebsiteText = "Not Found Website Text".localized(using: "Search") + " " + visitWebsiteLink
		let linkRange: NSRange = (visitWebsiteText as NSString).range(of: visitWebsiteLink)
		let visitOurWebsiteAttrString = NSMutableAttributedString(string: visitWebsiteText)
		let websiteURL = URL(string: AppDataManager.sharedInstance.app.dataSettings[.websiteUrl]!)!
		visitOurWebsiteAttrString.addAttributes([.link: websiteURL.absoluteString], range: NSRange(location: 0, length: visitOurWebsiteAttrString.string.count))
		visitOurWebsiteAttrString.addAttributes([.underlineStyle: NSUnderlineStyle.single], range: linkRange)

		visitWebsiteTextView.attributedText = visitOurWebsiteAttrString
		visitWebsiteTextView.textColor = .aicCardDarkLinkColor
		visitWebsiteTextView.linkTextAttributes = [.foregroundColor: UIColor.aicCardDarkLinkColor]
		visitWebsiteTextView.font = .aicSearchNoResultsWebsiteFont

		// Accessibility
		self.isAccessibilityElement = true
		self.accessibilityValue = visitWebsiteText
		self.accessibilityTraits = .link
	}
}

extension NoResultsCell: UITextViewDelegate {
	func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		return true
	}
}
