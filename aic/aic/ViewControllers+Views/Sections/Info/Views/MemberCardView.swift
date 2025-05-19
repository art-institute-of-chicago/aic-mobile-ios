//
//  MemberCardView.swift
//  aic
//
//  Created by Filippo Vanucci on 2/13/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

class MemberCardView: UIView {
	let memberNameLabel: UILabel = UILabel()
	let membershipInfoLabel: UILabel = UILabel()
	let barcodeImageView: UIImageView = UIImageView()
	let barcodeReciprocalBadgeImageView: UIImageView = UIImageView()
	let changeInfoButton: AICButton = AICButton(isSmall: false)
	let switchCardholderButton: AICButton = AICButton(isSmall: false)

	private let barcodeWidth: CGFloat = min(UIScreen.main.bounds.width - 10, 365)
    
    private let crashlyticsManager = CrashlyticsManager(
        service: FirebaseCrashlyticsService(),
        properties: [
            AnalyticsProperty.make(by: .appLanguage),
            AnalyticsProperty.make(by: .deviceLanguage),
            AnalyticsProperty.make(by: .membership)
        ]
    )

	init() {
		super.init(frame: CGRect.zero)

		memberNameLabel.text = "First Last"
		memberNameLabel.font = .aicTitleFont
		memberNameLabel.textColor = .black
		memberNameLabel.numberOfLines = 1
		memberNameLabel.textAlignment = .left

		membershipInfoLabel.text = "Member\nExpires: "
		membershipInfoLabel.font = .aicPageTextFont
		membershipInfoLabel.textColor = .black
		membershipInfoLabel.numberOfLines = 3
		membershipInfoLabel.textAlignment = .left

		barcodeReciprocalBadgeImageView.contentMode = .scaleAspectFill
		barcodeReciprocalBadgeImageView.image = #imageLiteral(resourceName: "reciprocal_logo")

		changeInfoButton.setColorMode(colorMode: AICButton.orangeMode)
		changeInfoButton.setTitle("Change Information", for: .normal)

		switchCardholderButton.setColorMode(colorMode: AICButton.orangeMode)
		switchCardholderButton.setTitle("Switch Cardholder", for: .normal)

		// Add subviews
		self.addSubview(memberNameLabel)
		self.addSubview(membershipInfoLabel)
		self.addSubview(barcodeImageView)
		self.addSubview(barcodeReciprocalBadgeImageView)
		self.addSubview(changeInfoButton)
		self.addSubview(switchCardholderButton)

		createConstraints()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func createConstraints() {
		memberNameLabel.autoPinEdge(.top, to: .top, of: self, withOffset: 23)
		memberNameLabel.autoAlignAxis(.vertical, toSameAxisOf: self)
		memberNameLabel.autoSetDimension(.width, toSize: barcodeWidth - 55)

		membershipInfoLabel.autoPinEdge(.top, to: .bottom, of: memberNameLabel, withOffset: 5)
		membershipInfoLabel.autoAlignAxis(.vertical, toSameAxisOf: self)
		membershipInfoLabel.autoSetDimension(.width, toSize: barcodeWidth - 55)

		barcodeReciprocalBadgeImageView.autoPinEdge(.top, to: .bottom, of: memberNameLabel, withOffset: 6)
		barcodeReciprocalBadgeImageView.autoSetDimensions(to: CGSize(width: 40, height: 40))
		barcodeReciprocalBadgeImageView.autoAlignAxis(.vertical, toSameAxisOf: self, withOffset: barcodeWidth * 0.5 - 20)

		barcodeImageView.autoPinEdge(.top, to: .bottom, of: membershipInfoLabel, withOffset: 20)
		barcodeImageView.autoSetDimensions(to: CGSize(width: barcodeWidth, height: 140))
		barcodeImageView.autoAlignAxis(.vertical, toSameAxisOf: self)

		changeInfoButton.autoPinEdge(.top, to: .bottom, of: barcodeImageView, withOffset: 20)
		changeInfoButton.autoAlignAxis(.vertical, toSameAxisOf: self)

		switchCardholderButton.autoPinEdge(.top, to: .bottom, of: changeInfoButton, withOffset: 22)
		switchCardholderButton.autoAlignAxis(.vertical, toSameAxisOf: self)
	}

	func setContent(memberCard: AICMemberCardModel, memberNameIndex: Int) {
        guard let memberNames = memberCard.memberNames[safeIndex: memberNameIndex] else {
            let report = GeneralCrashlyticsReport(error: GeneralError.general, log: "Unable to get member index \(memberNameIndex) from \(memberCard.memberNames.count) total indexes")
            crashlyticsManager.record(report)
            
            return
        }
        
		memberNameLabel.text = memberNames

		// Expiration Date
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MM/dd/yyyy"
		dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
		let expirationDateString = dateFormatter.string(from: memberCard.expirationDate)

		membershipInfoLabel.text = "ID: " + memberCard.cardId + "\n" + memberCard.memberLevel
		if memberCard.isLifeMembership == false {
			membershipInfoLabel.text =
				"member_card_member_id".localizedFormat(arguments: memberCard.cardId, using: "AccessCard")
				+ "\n"
				+ memberCard.memberLevel
				+ "\n"
				+ "member_card_expires".localizedFormat(arguments: expirationDateString, using: "AccessCard")
		}

		// Barcode
		let data = String(memberCard.cardId).data(using: String.Encoding.ascii)
		let filter = CIFilter(name: "CIPDF417BarcodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        if let barcodeCIImage = filter?.outputImage {
            let barcodeImage = UIImage(ciImage: barcodeCIImage.transformed(by: CGAffineTransform(scaleX: 4.5, y: 4.5)))
            
            barcodeImageView.image = barcodeImage
            
            switchCardholderButton.isHidden = memberCard.memberNames.count < 2
            switchCardholderButton.isEnabled = !switchCardholderButton.isHidden
            
            barcodeReciprocalBadgeImageView.isHidden = !memberCard.isReciprocalMember
        }
	}
}
