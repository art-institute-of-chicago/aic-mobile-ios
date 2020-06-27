//
//  PagedMessageCollectionViewCell.swift
//  aic
//
//  Created by Christopher Luu on 5/21/20.
//  Copyright © 2020 Art Institute of Chicago. All rights reserved.
//

import UIKit

protocol PagedMessageCollectionViewCellDelegate: AnyObject {
	func pagedMessageCollectionViewCellDidSelectPreviousPage(_ cell: PagedMessageCollectionViewCell)
	func pagedMessageCollectionViewCellDidSelectNextPage(_ cell: PagedMessageCollectionViewCell)
	func pagedMessageCollectionViewCell(_ cell: PagedMessageCollectionViewCell, didSelectAction action: URL)
	func pagedMessageCollectionViewCellDidSelectClose(_ cell: PagedMessageCollectionViewCell)
}

final class PagedMessageCollectionViewCell: UICollectionViewCell {
	// MARK: - Constants -
	static let reuseIdentifier = "pagedMessageCell"

	// MARK: - Properties -
	weak var delegate: PagedMessageCollectionViewCellDelegate?
	var message: AICMessageModel? = nil {
		didSet {
			guard let message = self.message else { return }

			titleLabel.text = message.translations?[Common.currentLanguage]?.title ?? message.title

			let attributedMessage = NSMutableAttributedString(
				attributedString: getAttributedString(
					forHTMLText: replaceMemberDetails(
						in: message.translations?[Common.currentLanguage]?.message ?? message.message
					),
					font: messageTextView.font ?? .aicPageTextFont,
					textColor: .white
				)
			)
			attributedMessage.enumerateAttributes(in: NSRange(0..<attributedMessage.length), options: .reverse) { (attributes, range, _) in
				if attributes[.link] != nil {
					attributedMessage.removeAttribute(.font, range: range)
					attributedMessage.addAttribute(.font, value: UIFont.aicPageLinkFont, range: range)
				}
			}
			messageTextView.attributedText = attributedMessage

			if let actionTitle =
					message.translations?[Common.currentLanguage]?.actionButtonTitle ?? message.actionButtonTitle,
				!actionTitle.isEmpty {
				actionButton.setTitle(actionTitle, for: .normal)
				actionButton.isHidden = false
			} else {
				actionButton.isHidden = true
			}
		}
	}
	var isFirstPage: Bool {
		get { return previousButton.isHidden }
		set { previousButton.isHidden = newValue }
	}
	var isLastPage: Bool {
		get { return nextButton.isHidden }
		set {
			nextButton.isHidden = newValue
			closeButton.isHidden = !newValue
		}
	}

	// MARK: - UI Properties -
	private let scrollView = UIScrollView()
	private let titleLabel = UILabel()
	private let dividerLine = UIView()
	private let messageTextView = UITextView()
	private let buttonStackView = UIStackView()
	private let actionButton = AICButton(isSmall: true)
	private let nextButton = AICButton(isSmall: true)
	private let previousButton = AICButton(isSmall: true)
	private let closeButton = AICButton(isSmall: true)

	// MARK: - Initializers -
	override init(frame: CGRect) {
		super.init(frame: .zero)

		setUpView()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("This init method shouldn't ever be used")
	}

	// MARK: - View -
	private func setUpView() {
		titleLabel.font = .aicPageTitleFont
		titleLabel.numberOfLines = 0
		titleLabel.textColor = .white
		titleLabel.textAlignment = .center

		dividerLine.backgroundColor = .aicDividerLineTransparentColor

		messageTextView.setDefaultsForAICAttributedTextView()
		messageTextView.textColor = .white
		messageTextView.font = .aicPageTextFont
		messageTextView.linkTextAttributes = [
			.font: UIFont.aicPageTextFont,
			.foregroundColor: UIColor.white
		]

		buttonStackView.axis = .vertical
		buttonStackView.spacing = 16
		buttonStackView.alignment = .center

		actionButton.setColorMode(colorMode: AICButton.greenBlueMode)
		actionButton.addTarget(self, action: #selector(showAction), for: .touchUpInside)

		nextButton.setTitle("Next Message", for: .normal)
		nextButton.setColorMode(colorMode: AICButton.greenBlueMode)
		nextButton.addTarget(self, action: #selector(nextPage), for: .touchUpInside)

		previousButton.setTitle("Previous Message", for: .normal)
		previousButton.setColorMode(colorMode: AICButton.greenBlueMode)
		previousButton.addTarget(self, action: #selector(previousPage), for: .touchUpInside)

		closeButton.setTitle("OK", for: .normal)
		closeButton.setColorMode(colorMode: AICButton.transparentMode)
		closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)

		contentView.addSubview(scrollView)
		scrollView.addSubview(titleLabel)
		scrollView.addSubview(dividerLine)
		scrollView.addSubview(messageTextView)
		scrollView.addSubview(buttonStackView)
		buttonStackView.addArrangedSubview(actionButton)
		buttonStackView.addArrangedSubview(nextButton)
		buttonStackView.addArrangedSubview(previousButton)
		buttonStackView.addArrangedSubview(closeButton)

		createViewConstraints()
	}

	private func createViewConstraints() {
		scrollView.autoPinEdgesToSuperviewEdges()

		titleLabel.autoMatch(.width, to: .width, of: scrollView, withOffset: -32)
		titleLabel.autoAlignAxis(.horizontal, toSameAxisOf: contentView, withMultiplier: 0.4)
		titleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
		titleLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)

		dividerLine.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 30)
		dividerLine.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
		dividerLine.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
		dividerLine.autoSetDimension(.height, toSize: 1)

		messageTextView.autoPinEdge(.top, to: .bottom, of: dividerLine, withOffset: 30)
		messageTextView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
		messageTextView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)

		buttonStackView.autoPinEdge(.top, to: .bottom, of: messageTextView, withOffset: 80)
		buttonStackView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 30)
		buttonStackView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
		buttonStackView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
	}

	private func replaceMemberDetails(in string: String) -> String {
		guard let member = MemberDataManager.sharedInstance.currentMemberCard else { return string }

		let memberIndex = MemberDataManager.sharedInstance.currentMemberNameIndex
		let dateFormatter = DateFormatter()
		dateFormatter.setLocalizedDateFormatFromTemplate("MM/dd/yyyy")

		return string.replacingOccurrences(of: "%CARD_ID%", with: member.cardId)
			.replacingOccurrences(of: "%ZIP_CODE%", with: member.memberZip)
			.replacingOccurrences(of: "%NAME%", with: member.memberNames[memberIndex])
			.replacingOccurrences(of: "%FIRST_NAME%",
								  with: member.memberNames[memberIndex].split(separator: " ").first ?? "")
			.replacingOccurrences(of: "%EXPIRATION_DATE%",
								  with: dateFormatter.string(from: member.expirationDate))
	}

	// MARK: - Interactions -
	@objc private func previousPage() {
		delegate?.pagedMessageCollectionViewCellDidSelectPreviousPage(self)
	}

	@objc private func nextPage() {
		delegate?.pagedMessageCollectionViewCellDidSelectNextPage(self)
	}

	@objc private func showAction() {
		guard let action = message?.action else { return }
		let actionString = replaceMemberDetails(in: action.absoluteString)

		delegate?.pagedMessageCollectionViewCell(self, didSelectAction: URL(string: actionString) ?? action)
	}

	@objc private func close() {
		delegate?.pagedMessageCollectionViewCellDidSelectClose(self)
	}
}
