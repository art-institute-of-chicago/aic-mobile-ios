/*
Abstract:
Prompt to become a member or log in
*/

import UIKit

class InfoBecomeMemberView: BaseView {
	let titleLabel = UILabel()
	let joinPromptLabel = UILabel()
	let joinTextView = LinkedTextView()
	let accessPromptLabel = UILabel()
	let accessButton = AICButton(isSmall: false)
	let bottomDividerLine = UIView()

	private let titleLabelMarginTop: CGFloat = 20
	private let joinPromptMarginTop: CGFloat = 16
	private let joinTextMarginTop: CGFloat = 5
	private let accessPromptMarginTop: CGFloat = 28
	private let accessButtonMarginTop: CGFloat = 20
	private let accessButtonMarginBottom: CGFloat = 20

	var savedMember: AICMemberInfoModel? {
		didSet {
			//Configure view appropriately if a member signs in
			if savedMember != nil {
				titleLabel.text = Common.Info.becomeMemberExistingMemberTitle

				if joinPromptLabel.superview != nil {
					joinPromptLabel.removeFromSuperview()
				}
				if joinTextView.superview != nil {
					joinTextView.removeFromSuperview()
				}
				if accessPromptLabel.superview != nil {
					accessPromptLabel.removeFromSuperview()
				}
			} else if joinPromptLabel.superview == nil && joinTextView.superview == nil && accessPromptLabel.superview == nil {
				titleLabel.text = "info_member_header".localized(using: "Info")
				addSubview(joinPromptLabel)
				addSubview(joinTextView)
				addSubview(accessPromptLabel)
			}
		}
	}

	init() {
		super.init(frame: CGRect.zero)

		if savedMember == nil {
			//Prompt user to become a member
			titleLabel.text = "info_member_header".localized(using: "Info")
		} else {
			//Welcome back existing members
			titleLabel.text = Common.Info.becomeMemberExistingMemberTitle
		}

		titleLabel.font = .aicTitleFont
		titleLabel.textColor = .aicDarkGrayColor
		titleLabel.textAlignment = NSTextAlignment.center

		joinPromptLabel.numberOfLines = 0
		joinPromptLabel.text = "info_member_prompt".localized(using: "Info")
		joinPromptLabel.font = .aicPageTextFont
		joinPromptLabel.textColor = .aicDarkGrayColor
		joinPromptLabel.textAlignment = .center

		let joinAttrText = NSMutableAttributedString(string: "info_member_join_action".localized(using: "Info"))
		let joinURL = URL(string: AppDataManager.sharedInstance.app.dataSettings[.membershipUrl]!)!
		joinAttrText.addAttributes([.link: joinURL], range: NSRange(location: 0, length: joinAttrText.string.count))

		joinTextView.setDefaultsForAICAttributedTextView()
		joinTextView.attributedText = joinAttrText
		joinTextView.linkTextAttributes = [.foregroundColor: UIColor.aicInfoColor]
		joinTextView.textAlignment = NSTextAlignment.center
		joinTextView.font = .aicPageTextFont
		joinTextView.delegate = self

		accessPromptLabel.text = "info_member_log_in_header".localized(using: "Info")
		accessPromptLabel.font = .aicPageTextFont
		accessPromptLabel.textColor = .aicDarkGrayColor
		accessPromptLabel.textAlignment = NSTextAlignment.center

		accessButton.setColorMode(colorMode: AICButton.orangeMode)
		accessButton.setTitle("member_card_access_action".localized(using: "AccessCard"), for: .normal)

		bottomDividerLine.backgroundColor = .aicDividerLineColor

		// Add Subviews
		addSubview(titleLabel)

		// Only show join prompts if no member has been saved
		if savedMember == nil {
			addSubview(joinPromptLabel)
			addSubview(joinTextView)
			addSubview(accessPromptLabel)
		}

		addSubview(accessButton)
		addSubview(bottomDividerLine)

		// Set Delegates
		joinTextView.delegate = self

		// Accessibility
		joinTextView.accessibilityTraits = .link
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func updateConstraints() {
		if didSetupConstraints == false {
			titleLabel.autoPinEdge(.top, to: .top, of: self, withOffset: titleLabelMarginTop)
			titleLabel.autoPinEdge(.leading, to: .leading, of: self)
			titleLabel.autoPinEdge(.trailing, to: .trailing, of: self)

			joinPromptLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: joinPromptMarginTop)
			joinPromptLabel.autoPinEdge(.leading, to: .leading, of: self)
			joinPromptLabel.autoPinEdge(.trailing, to: .trailing, of: self)

			joinTextView.autoPinEdge(.top, to: .bottom, of: joinPromptLabel, withOffset: joinTextMarginTop)
			joinTextView.autoPinEdge(.leading, to: .leading, of: self)
			joinTextView.autoPinEdge(.trailing, to: .trailing, of: self)

			accessPromptLabel.autoPinEdge(.top, to: .bottom, of: joinTextView, withOffset: accessPromptMarginTop)
			accessPromptLabel.autoPinEdge(.leading, to: .leading, of: self)
			accessPromptLabel.autoPinEdge(.trailing, to: .trailing, of: self)

			accessButton.autoAlignAxis(.vertical, toSameAxisOf: self)
			accessButton.autoPinEdge(.top, to: .bottom, of: accessPromptLabel, withOffset: accessButtonMarginTop)

			bottomDividerLine.autoPinEdge(.top, to: .bottom, of: accessButton, withOffset: accessButtonMarginBottom)
			bottomDividerLine.autoSetDimension(.height, toSize: 1)
			bottomDividerLine.autoPinEdge(.leading, to: .leading, of: self, withOffset: 16)
			bottomDividerLine.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -16)

			self.autoPinEdge(.bottom, to: .bottom, of: bottomDividerLine)

			didSetupConstraints = true
		}

		super.updateConstraints()
	}
}

// Observe links for passing analytics
extension InfoBecomeMemberView: UITextViewDelegate {
	func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		// Log Analytics
		AICAnalytics.sendMiscLinkTappedEvent(link: AICAnalytics.MiscLink.MemberJoin)

		return true
	}
}
