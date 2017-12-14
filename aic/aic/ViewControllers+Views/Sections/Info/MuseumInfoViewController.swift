//
//  MuseumInfoViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 12/11/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

class MuseumInfoViewController : UIViewController {
	let pageView: InfoPageView
	
	init() {
		var text = Common.Info.museumInformationHours
		text += "\n\n" + Common.Info.museumInformationAddress
		text += "\n\n" + Common.Info.museumInformationPhoneNumber
		pageView = InfoPageView(title: Common.Info.museumInformationTitle, text: text)
		super.init(nibName: nil, bundle: nil)
		
		self.navigationItem.title = "Museum Information"
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func updateViewConstraints() {
		pageView.autoPinEdge(.top, to: .top, of: self.view)
		pageView.autoPinEdge(.leading, to: .leading, of: self.view)
		pageView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		
		super.updateViewConstraints()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = .white
		
		self.view.addSubview(pageView)
		
		let swipeRightGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(recognizer:)))
		swipeRightGesture.direction = .right
		self.view.addGestureRecognizer(swipeRightGesture)
	}
}

extension MuseumInfoViewController : UIGestureRecognizerDelegate {
	@objc private func swipeRight(recognizer: UIGestureRecognizer) {
		self.navigationController?.popViewController(animated: true)
	}
}
