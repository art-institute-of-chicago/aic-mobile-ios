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
class NoResultsCell : UITableViewCell {
	static let reuseIdentifier = "noResultsCell"
	
	@IBOutlet weak var noResultsLabel: UILabel!
	@IBOutlet weak var visitWebsiteTextView: LinkedTextView!
	
	var contentLoaded: Bool = false
	
	static let cellHeight: CGFloat = 100.0
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		selectionStyle = UITableViewCellSelectionStyle.none
		
		self.backgroundColor = .aicDarkGrayColor
		
		noResultsLabel.text = "Not Found Text".localized(using: "Search")
		noResultsLabel.numberOfLines = 0
		noResultsLabel.lineBreakMode = .byWordWrapping
		noResultsLabel.textColor = .aicCardDarkTextColor
		
		let visitOurWebsiteAttrString = NSMutableAttributedString(string: "Not Found Website Link Text".localized(using: "Search"))
		let websiteURL = URL(string: Common.Search.museumWebsiteURL)!
		visitOurWebsiteAttrString.addAttributes([NSAttributedStringKey.link : websiteURL.absoluteString], range: NSMakeRange(0, visitOurWebsiteAttrString.string.count))
		
		visitWebsiteTextView.setDefaultsForAICAttributedTextView()
		visitWebsiteTextView.attributedText = visitOurWebsiteAttrString
		visitWebsiteTextView.textColor = .aicCardDarkLinkColor
		visitWebsiteTextView.linkTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue : UIColor.aicCardDarkLinkColor]
		visitWebsiteTextView.font = .aicSearchNoResultsWebsiteFont
		visitWebsiteTextView.delegate = self
	}
}

extension NoResultsCell : UITextViewDelegate {
	func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		return true
	}
}
