//
//  HomeMemberCardView.swift
//  aic
//
//  Created by Filippo Vanucci on 11/21/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

class HomeIntroView: UIView {
    let promptTextView: UITextView = UITextView()
    let accessMemberCardButton: UIButton = UIButton()
    
    var stackView = UIStackView()
    
    init() {
        super.init(frame: CGRect.zero)
        
        backgroundColor = .aicIntroTextBackgroundColor
        
        promptTextView.setDefaultsForAICAttributedTextView()
        promptTextView.font = .aicPageTextFont
        promptTextView.textColor = .aicDarkGrayColor
        promptTextView.textAlignment = .center
        promptTextView.dataDetectorTypes = .link
        promptTextView.linkTextAttributes = [
            .font: UIFont.aicPageTextFont,
            .foregroundColor: UIColor.aicHomeMemberPromptLinkColor
        ]
        
        accessMemberCardButton.backgroundColor = .clear
        accessMemberCardButton.titleLabel!.font = .aicPageTextFont
        accessMemberCardButton.setTitleColor(.aicHomeMemberPromptLinkColor, for: .normal)
        
        self.stackView = UIStackView(arrangedSubviews: [promptTextView, accessMemberCardButton])
        self.stackView.spacing = 16
        self.stackView.axis = .vertical
        
        // Add subviews
        self.addSubview(stackView)
        
        createConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updatePromptText(with updatedText: String) {
        let processedText = updatedText.trimmingCharacters(in: .whitespacesAndNewlines)
        promptTextView.text = processedText
        promptTextView.isHidden = processedText.isEmpty
    }
    
    private func createConstraints() {
        stackView.autoPinEdge(.top, to: .top, of: self, withOffset: 32)
        stackView.autoPinEdge(.leading, to: .leading, of: self, withOffset: 16.0)
        stackView.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -16.0)
        stackView.autoPinEdge(.bottom, to: .bottom, of: self, withOffset: -32)
    }
}
