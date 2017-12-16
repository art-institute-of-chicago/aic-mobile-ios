//
//  InfoViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 11/17/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit
import PureLayout

protocol InfoViewControllerDelegate : class {
	func museumInfoButtonPressed()
	func languageButtonPressed()
	func locationButtonPressed()
}

class InfoViewController : SectionViewController {
	let scrollView: UIScrollView = UIScrollView()
	let whiteBackgroundView: UIView = UIView()
	let becomeMemberView: InfoBecomeMemberView = InfoBecomeMemberView()
	let museumInfoButton: InfoButton = InfoButton()
	let languageButton: InfoButton = InfoButton()
	let locationButton: InfoButton = InfoButton()
	let footerView: InfoFooterView = InfoFooterView()
	
	let footerTopMargin: CGFloat = 15.0
	
	weak var delegate: InfoViewControllerDelegate? = nil
	
	override init(section: AICSectionModel) {
		super.init(section: section)
		
		scrollView.backgroundColor = .aicInfoColor
		scrollView.delegate = self
		
		whiteBackgroundView.backgroundColor = .white
		
		museumInfoButton.setTitle("Museum Information", for: .normal)
		museumInfoButton.addTarget(self, action: #selector(infoButtonPressed(button:)), for: .touchUpInside)
		
		languageButton.setTitle("Language", for: .normal)
		languageButton.addTarget(self, action: #selector(infoButtonPressed(button:)), for: .touchUpInside)
		
		locationButton.setTitle("Location Settings", for: .normal)
		locationButton.addTarget(self, action: #selector(infoButtonPressed(button:)), for: .touchUpInside)
		
		self.view.addSubview(scrollView)
		scrollView.addSubview(whiteBackgroundView)
		scrollView.addSubview(becomeMemberView)
		scrollView.addSubview(museumInfoButton)
		scrollView.addSubview(languageButton)
		scrollView.addSubview(locationButton)
		scrollView.addSubview(footerView)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.view.layoutIfNeeded()
		self.scrollView.contentSize.width = self.view.frame.width
		self.scrollView.contentSize.height = footerView.frame.origin.y + footerView.frame.height
		
		self.scrollDelegate?.sectionViewControllerWillAppearWithScrollView(scrollView: self.scrollView)
	}
	
	override func updateViewConstraints() {
		scrollView.autoPinEdge(.top, to: .top, of: self.view)
		scrollView.autoPinEdge(.leading, to: .leading, of: self.view)
		scrollView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		scrollView.autoPinEdge(.bottom, to: .bottom, of: self.view, withOffset: -Common.Layout.tabBarHeight)
		
		becomeMemberView.autoPinEdge(.top, to: .top, of: scrollView, withOffset: Common.Layout.navigationBarVerticalOffset)
		becomeMemberView.autoPinEdge(.leading, to: .leading, of: self.view)
		becomeMemberView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		
		museumInfoButton.autoPinEdge(.top, to: .bottom, of: becomeMemberView)
		museumInfoButton.autoPinEdge(.leading, to: .leading, of: self.view)
		museumInfoButton.autoPinEdge(.trailing, to: .trailing, of: self.view)
		
		languageButton.autoPinEdge(.top, to: .bottom, of: museumInfoButton)
		languageButton.autoPinEdge(.leading, to: .leading, of: self.view)
		languageButton.autoPinEdge(.trailing, to: .trailing, of: self.view)
		
		locationButton.autoPinEdge(.top, to: .bottom, of: languageButton)
		locationButton.autoPinEdge(.leading, to: .leading, of: self.view)
		locationButton.autoPinEdge(.trailing, to: .trailing, of: self.view)
		
		footerView.autoPinEdge(.top, to: .bottom, of: locationButton, withOffset: footerTopMargin)
		footerView.autoPinEdge(.leading, to: .leading, of: self.view)
		footerView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		footerView.autoSetDimension(.height, toSize: 250)
		
		whiteBackgroundView.autoPinEdge(.top, to: .top, of: self.view)
		whiteBackgroundView.autoPinEdge(.leading, to: .leading, of: self.view)
		whiteBackgroundView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		whiteBackgroundView.autoPinEdge(.bottom, to: .top, of: footerView)
		
		super.updateViewConstraints()
	}
	
	@objc func infoButtonPressed(button: UIButton) {
		if button == museumInfoButton {
			self.delegate?.museumInfoButtonPressed()
		}
		else if button == languageButton {
			self.delegate?.languageButtonPressed()
		}
		else if button == locationButton {
			self.delegate?.locationButtonPressed()
		}
	}
}

extension InfoViewController : UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		self.scrollDelegate?.sectionViewControllerDidScroll(scrollView: scrollView)
	}
}

