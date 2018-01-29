//
//  MessageViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 1/19/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Localize_Swift

@objc protocol MessageViewControllerDelegate: class {
	func messageViewActionSelected(messageVC: MessageViewController)
	@objc optional func messageViewCancelSelected(messageVC: MessageViewController)
}

class MessageViewController : UIViewController {
	
	let blurBGView:UIView = getBlurEffectView(frame: UIScreen.main.bounds)
	
	let contentView = UIView()
	let titleLabel = UILabel()
	let dividerLine = UIView()
	let subtitleLabel = UILabel()
	let buttonsView = UIView()
	
	let fadeInOutAnimationDuration = 0.4
	let contentViewFadeInOutAnimationDuration = 0.4
	
	weak var delegate: MessageViewControllerDelegate? = nil
	
	init() {
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = .clear
		
		let blurEffect = UIBlurEffect(style: .dark)
		let blurEffectView = UIVisualEffectView(effect: blurEffect)
		blurEffectView.frame = self.view.frame
		
		contentView.backgroundColor = .clear
		
		//		titleLabel.attributedText = getAttributedStringWithLineHeight(text: "Please Choose Your Preferred Language", font: .aicLanguageSelectionTitleFont, lineHeight: 32)
		titleLabel.text = "Tilte Label"
		titleLabel.font = .aicLanguageSelectionTitleFont
		titleLabel.numberOfLines = 1
		titleLabel.textColor = .white
		titleLabel.textAlignment = .center
		
		dividerLine.backgroundColor = .aicDividerLineTransparentColor
		
		buttonsView.backgroundColor = .clear
		buttonsView.clipsToBounds = false
		
		// Add subviews
		self.view.addSubview(blurBGView)
		self.view.addSubview(contentView)
		contentView.addSubview(titleLabel)
		contentView.addSubview(dividerLine)
		contentView.addSubview(subtitleLabel)
		contentView.addSubview(buttonsView)
		
		createViewConstraints()
		
		// Language
		NotificationCenter.default.addObserver(self, selector: #selector(updateLanguage), name: NSNotification.Name( LCLLanguageChangeNotification), object: nil)
	}
	
	func createViewConstraints() {
		contentView.autoPinEdgesToSuperviewEdges()
		
		titleLabel.autoAlignAxis(.vertical, toSameAxisOf: contentView)
		titleLabel.autoPinEdge(.leading, to: .leading, of: contentView, withOffset: 16)
		titleLabel.autoPinEdge(.trailing, to: .trailing, of: contentView, withOffset: -16)
		titleLabel.autoPinEdge(.top, to: .top, of: contentView, withOffset: 100 + Common.Layout.safeAreaTopMargin)
		
		dividerLine.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 30)
		dividerLine.autoPinEdge(.leading, to: .leading, of: contentView, withOffset: 16)
		dividerLine.autoPinEdge(.trailing, to: .trailing, of: contentView, withOffset: -16)
		dividerLine.autoSetDimension(.height, toSize: 1)
		
		subtitleLabel.autoPinEdge(.top, to: .bottom, of: dividerLine, withOffset: 30)
		subtitleLabel.autoPinEdge(.leading, to: .leading, of: contentView, withOffset: 40)
		subtitleLabel.autoPinEdge(.trailing, to: .trailing, of: contentView, withOffset: -40)
		subtitleLabel.autoAlignAxis(.vertical, toSameAxisOf: contentView)
		
		buttonsView.autoPinEdge(.top, to: .bottom, of: subtitleLabel, withOffset: 64)
		buttonsView.autoPinEdge(.leading, to: .leading, of: contentView, withOffset: 16)
		buttonsView.autoPinEdge(.trailing, to: .trailing, of: contentView, withOffset: -16)
		buttonsView.autoSetDimension(.height, toSize: 100)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		updateLanguage()
		
		// Fade in
		view.alpha = 0.0
		contentView.alpha = 0.0
		UIView.animate(withDuration: fadeInOutAnimationDuration, animations: {
			self.view.alpha = 1.0
		}) { (completed) in
			if completed == true {
				UIView.animate(withDuration: self.contentViewFadeInOutAnimationDuration, animations: {
					self.contentView.alpha = 1.0
				})
			}
		}
	}
	
	@objc func updateLanguage() {}
}
