//
//  MemberCardView.swift
//  aic
//
//  Created by Filippo Vanucci on 2/13/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

class MemberCardView : UIView {
	let memberNameLabel: UILabel = UILabel()
	let membershipInfoLabel: UILabel = UILabel()
	let barcodeImageView = UIImageView()
	let changeInfoButton: AICButton = AICButton(color: .aicInfoColor, isSmall: false)
	let switchCardholderButton: AICButton = AICButton(color: .aicInfoColor, isSmall: false)
	
	init() {
		super.init(frame: CGRect.zero)
		
		memberNameLabel.text = "First Last"
		memberNameLabel.font = .aicMemberCardTitleFont
		memberNameLabel.textColor = .black
		memberNameLabel.numberOfLines = 1
		memberNameLabel.textAlignment = .left
		
		membershipInfoLabel.text = "Member\nExpires: "
		membershipInfoLabel.font = .aicTextFont
		membershipInfoLabel.textColor = .black
		membershipInfoLabel.numberOfLines = 2
		membershipInfoLabel.textAlignment = .left
		
		changeInfoButton.setTitle("Change Information", for: .normal)
		
		switchCardholderButton.setTitle("Switch Cardholder", for: .normal)
		
		// Add subviews
		self.addSubview(memberNameLabel)
		self.addSubview(membershipInfoLabel)
		self.addSubview(barcodeImageView)
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
		memberNameLabel.autoSetDimension(.width, toSize: 309)
		
		membershipInfoLabel.autoPinEdge(.top, to: .bottom, of: memberNameLabel, withOffset: -10)
		membershipInfoLabel.autoAlignAxis(.vertical, toSameAxisOf: self)
		membershipInfoLabel.autoSetDimension(.width, toSize: 309)
		
		barcodeImageView.autoPinEdge(.top, to: .bottom, of: membershipInfoLabel, withOffset: 20)
		barcodeImageView.autoAlignAxis(.vertical, toSameAxisOf: self)
		
		changeInfoButton.autoPinEdge(.top, to: .bottom, of: barcodeImageView, withOffset: 20)
		changeInfoButton.autoAlignAxis(.vertical, toSameAxisOf: self)
		
		switchCardholderButton.autoPinEdge(.top, to: .bottom, of: changeInfoButton, withOffset: 22)
		switchCardholderButton.autoAlignAxis(.vertical, toSameAxisOf: self)
	}
	
	func setContent(memberCard: AICMemberCardModel, memberNameIndex: Int) {
		memberNameLabel.text = memberCard.memberNames[memberNameIndex]
		
		// Expiration Date
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MM/dd/yyyy"
		dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
		let expirationDateString = dateFormatter.string(from: memberCard.expirationDate)
		
		membershipInfoLabel.text = memberCard.memberLevel + "\nExpires: " + expirationDateString
		
		// Barcode
		let data = String(memberCard.cardId).data(using: String.Encoding.ascii)
		let filter = CIFilter(name: "CICode128BarcodeGenerator")
		filter!.setValue(data, forKey: "inputMessage")
		let barcodeCIImage = filter!.outputImage!
		let barcodeImage = UIImage(ciImage: barcodeCIImage.transformed(by: CGAffineTransform(scaleX: 4.5,y: 4.5)))
		
		barcodeImageView.image = barcodeImage
	}
}

