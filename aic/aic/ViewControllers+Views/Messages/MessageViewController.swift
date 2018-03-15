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
    let iconImageView = UIImageView()
    let dividerLine = UIView()
	let titleLabel = UILabel()
	let messageLabel = UILabel()
	let buttonsView = UIView()
    let actionButton: AICButton = AICButton(isSmall: true)
    var cancelButton: AICButton? = nil
	
	let fadeInOutAnimationDuration = 0.4
	let contentViewFadeInOutAnimationDuration = 0.4
    
    let messageModel: AICMessageModel
	
	weak var delegate: MessageViewControllerDelegate? = nil
	
    init(message: AICMessageModel) {
        messageModel = message
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
		
		contentView.backgroundColor = .clear
        
        iconImageView.image = messageModel.iconImage
        iconImageView.frame.size = iconImageView.image!.size
		
		dividerLine.backgroundColor = .aicDividerLineTransparentColor
        
        titleLabel.font = .aicLanguageSelectionTitleFont
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        
        messageLabel.font = .aicLanguageSelectionTextFont
        messageLabel.numberOfLines = 0
        messageLabel.textColor = .white
        messageLabel.textAlignment = .center
		
		buttonsView.backgroundColor = .clear
		buttonsView.clipsToBounds = false
        
        actionButton.addTarget(self, action: #selector(buttonPressed(button:)), for: .touchUpInside)
        
        if (messageModel.cancelButtonTitle ?? "").isEmpty == false {
            cancelButton = AICButton(isSmall: true)
            cancelButton?.setColorMode(colorMode: AICButton.transparentMode)
            cancelButton?.addTarget(self, action: #selector(buttonPressed(button:)), for: .touchUpInside)
        }
		
		// Add subviews
        self.view.insertSubview(blurBGView, at: 0)
		self.view.addSubview(contentView)
        contentView.addSubview(iconImageView)
		contentView.addSubview(dividerLine)
        contentView.addSubview(titleLabel)
		contentView.addSubview(messageLabel)
		contentView.addSubview(buttonsView)
        buttonsView.addSubview(actionButton)
        if cancelButton != nil {
            buttonsView.addSubview(cancelButton!)
        }
		
		createViewConstraints()
        
		// Language
		NotificationCenter.default.addObserver(self, selector: #selector(updateLanguage), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
	}
	
	func createViewConstraints() {
		contentView.autoPinEdgesToSuperviewEdges()
        
        iconImageView.autoSetDimensions(to: iconImageView.image!.size)
        iconImageView.autoAlignAxis(.vertical, toSameAxisOf: contentView)
        iconImageView.autoAlignAxis(.horizontal, toSameAxisOf: dividerLine, withOffset: -65)
		
		dividerLine.autoPinEdge(.top, to: .top, of: contentView, withOffset: 153 + Common.Layout.safeAreaTopMargin)
		dividerLine.autoPinEdge(.leading, to: .leading, of: contentView, withOffset: 16)
		dividerLine.autoPinEdge(.trailing, to: .trailing, of: contentView, withOffset: -16)
		dividerLine.autoSetDimension(.height, toSize: 1)
        
        titleLabel.autoPinEdge(.top, to: .bottom, of: dividerLine, withOffset: 30)
        titleLabel.autoPinEdge(.leading, to: .leading, of: contentView, withOffset: 16)
        titleLabel.autoPinEdge(.trailing, to: .trailing, of: contentView, withOffset: -16)
        titleLabel.autoAlignAxis(.vertical, toSameAxisOf: contentView)
		
		messageLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 30)
		messageLabel.autoPinEdge(.leading, to: .leading, of: contentView, withOffset: 40)
		messageLabel.autoPinEdge(.trailing, to: .trailing, of: contentView, withOffset: -40)
		messageLabel.autoAlignAxis(.vertical, toSameAxisOf: contentView)
		
		buttonsView.autoPinEdge(.top, to: .bottom, of: contentView, withOffset: -Common.Layout.tabBarHeight - 166)
		buttonsView.autoPinEdge(.leading, to: .leading, of: contentView, withOffset: 16)
		buttonsView.autoPinEdge(.trailing, to: .trailing, of: contentView, withOffset: -16)
		buttonsView.autoSetDimension(.height, toSize: 100)
        
        actionButton.autoPinEdge(.top, to: .top, of: buttonsView)
        actionButton.autoAlignAxis(.vertical, toSameAxisOf: buttonsView)
        
        if cancelButton != nil {
            cancelButton?.autoPinEdge(.top, to: .bottom, of: actionButton, withOffset: 16)
            cancelButton?.autoAlignAxis(.vertical, toSameAxisOf: buttonsView)
        }
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		updateLanguage()
        
        contentView.alpha = 0.0
	}
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: self.contentViewFadeInOutAnimationDuration, animations: {
            self.contentView.alpha = 1.0
        })
    }
	
	@objc func updateLanguage() {
        titleLabel.text = messageModel.title.localized(using: "Messages")
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        let textAttrString = NSMutableAttributedString(string: messageModel.message.localized(using: "Messages"))
        textAttrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, textAttrString.length))
        messageLabel.attributedText = textAttrString
        messageLabel.textAlignment = .center
		
		actionButton.setColorMode(colorMode: AICButton.greenBlueMode)
        actionButton.setTitle(messageModel.actionButtonTitle.localized(using: "Messages"), for: .normal)
        
        if cancelButton != nil {
			cancelButton!.setColorMode(colorMode: AICButton.transparentMode)
            cancelButton?.setTitle(messageModel.cancelButtonTitle?.localized(using: "Messages"), for: .normal)
        }
    }
    
    @objc func buttonPressed(button: UIButton) {
        if button == actionButton {
            self.delegate?.messageViewActionSelected(messageVC: self)
        }
        else if button == cancelButton {
			actionButton.setColorMode(colorMode: AICButton.transparentMode)
			cancelButton!.setColorMode(colorMode: AICButton.greenBlueMode)
            self.delegate?.messageViewCancelSelected?(messageVC: self)
        }
    }
}
